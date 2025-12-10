# Graceful Shutdown in Go (Signals + Context + WaitGroup)

This note summarizes what we discussed: catching OS shutdown signals, canceling work via `context`, and waiting for goroutines/jobs to finish before exiting.

---

## 1) Goal

When your app receives a shutdown signal (commonly `SIGTERM` or Ctrl+C / `SIGINT`), you usually want to:

1. **Stop accepting new work**
2. **Let in-flight work complete** (and optionally drain queued work)
3. **Wait for goroutines to exit**
4. Exit cleanly

---

## 2) Catching OS signals with `signal.NotifyContext`

A simple modern pattern is to create a context that is canceled automatically when a signal arrives:

```go
ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
defer stop()

<-ctx.Done() // blocks until SIGINT/SIGTERM
```

That `<-ctx.Done()` does **not** “busy loop”—it just blocks until the signal arrives.

---

## 3) Waiting for goroutines with `sync.WaitGroup`

A `WaitGroup` lets `main()` wait until all started goroutines exit:

```go
var wg sync.WaitGroup

wg.Add(1)
go func() {
    defer wg.Done()
    // goroutine work...
}()

wg.Wait() // blocks until all Done() calls happen
```

---

## 4) Worker loop with shutdown (ticker example)

A common “run-until-shutdown” worker looks like:

```go
for {
    select {
    case <-ctx.Done():
        return
    case t := <-ticker.C:
        // do work
        _ = t
    }
}
```

### What `for` does
- `for { ... }` repeats forever **until you return/break**.

### What `select` does
- `select` waits on multiple channel operations.
- It **blocks** until at least one case is ready, then runs exactly one ready case.

### What `ctx.Done()` is
- `ctx.Done()` is a channel that is **closed when the context is canceled**.
- Receiving from a closed channel unblocks immediately.

### What `ticker.C` is
- `ticker.C` sends a value periodically (a `time.Time`).
- Receiving from it blocks until the next tick.

So this pattern means: **do periodic work, but exit quickly when shutdown is requested**.

---

## 5) Worker that reads jobs from a channel (instead of a ticker)

Channels can act like a queue:

- Producer: `jobs <- job` (enqueue)
- Worker: `job := <-jobs` (dequeue)
- `close(jobs)` means “no more jobs will ever come”

A worker that listens for shutdown *and* jobs:

```go
for {
    select {
    case <-ctx.Done():
        return
    case job, ok := <-jobs:
        if !ok {
            return // channel closed => no more jobs
        }
        handle(job)
    }
}
```

---

## 6) “Graceful” shutdown: two common choices

### A) Drain everything already accepted (in-flight + queued in memory)
On shutdown you:
- stop producers
- `close(jobs)`
- workers use `for job := range jobs` to drain remaining jobs and then exit

This is a very common “finish what we already took responsibility for” approach.

### B) Finish only in-flight jobs (do **not** start new work)
On shutdown you:
- stop producers
- stop workers from picking new jobs
- only let currently-running jobs finish

This is useful if queued/backlog work should be persisted elsewhere rather than drained during shutdown.

---

## 7) Full example: SIGTERM stops intake and drains queued jobs

Key idea: **the producer owns closing the channel**.

```go
package main

import (
    "context"
    "fmt"
    "log"
    "os"
    "os/signal"
    "sync"
    "syscall"
    "time"
)

type Job struct{ ID int }

func main() {
    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer stop()

    jobs := make(chan Job, 100)

    // Start workers
    var workers sync.WaitGroup
    for i := 0; i < 4; i++ {
        workers.Add(1)
        go worker(&workers, i, jobs)
    }

    // Producer: stops on ctx.Done() and closes jobs
    go producer(ctx, jobs)

    <-ctx.Done()
    log.Println("SIGTERM received: stopping intake and draining jobs...")

    // Wait for workers (drain complete), but avoid hanging forever
    if err := waitGroupTimeout(&workers, 25*time.Second); err != nil {
        log.Printf("shutdown timed out: %v (process will exit)", err)
        return
    }

    log.Println("all jobs finished; exiting cleanly")
}

func producer(ctx context.Context, jobs chan<- Job) {
    defer close(jobs) // signals “no more jobs”; workers exit after drain

    for id := 0; ; id++ {
        select {
        case <-ctx.Done():
            log.Println("producer: stopped")
            return
        case jobs <- Job{ID: id}:
            time.Sleep(200 * time.Millisecond) // simulate incoming jobs
        }
    }
}

func worker(wg *sync.WaitGroup, workerID int, jobs <-chan Job) {
    defer wg.Done()

    for job := range jobs { // ends when jobs is closed AND drained
        log.Printf("worker %d: start job %d", workerID, job.ID)
        time.Sleep(900 * time.Millisecond) // simulate work
        log.Printf("worker %d: done job %d", workerID, job.ID)
    }

    log.Printf("worker %d: exiting", workerID)
}

func waitGroupTimeout(wg *sync.WaitGroup, timeout time.Duration) error {
    done := make(chan struct{})
    go func() {
        defer close(done)
        wg.Wait()
    }()

    select {
    case <-done:
        return nil
    case <-time.After(timeout):
        return fmt.Errorf("waited %s", timeout)
    }
}
```

---

## 8) Notes and gotchas

- **Only one goroutine should close a channel.** A good rule is: *the sender/producer closes the channel*.
- `SIGKILL` **cannot** be caught (so graceful shutdown is impossible in that case).
- In Kubernetes/systemd, your process usually gets a grace period after `SIGTERM` before it may be force-killed, so a timeout is practical.

---

If you want, I can adapt this pattern to:
- an HTTP server (`http.Server.Shutdown`)
- a job system that must ack/nack messages (Kafka/SQS/RabbitMQ)
- a worker pool with “in-flight only” semantics
