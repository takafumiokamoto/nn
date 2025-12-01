Here’s a minimal but complete pattern you can copy‑paste and adapt.

It:
	•	Catches SIGINT/SIGTERM (Ctrl+C or kill)
	•	Cancels a context.Context
	•	Has workers that respect the context and exit cleanly
	•	Uses a sync.WaitGroup to wait for all goroutines to finish before exiting

package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

func main() {
	// Context that is canceled when we get an interrupt or SIGTERM signal.
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	var wg sync.WaitGroup

	// Start some example workers.
	workerCount := 3
	for i := 0; i < workerCount; i++ {
		wg.Add(1)
		go worker(ctx, &wg, i)
	}

	log.Println("app: started. Press Ctrl+C to stop.")

	// Block until a signal is received (ctx is canceled).
	<-ctx.Done()
	log.Println("app: shutdown signal received")

	// Optionally you can do other cleanup here (close channels, flush logs, etc.)

	// Wait for all goroutines to finish.
	wg.Wait()
	log.Println("app: all goroutines done. exiting.")
}

func worker(ctx context.Context, wg *sync.WaitGroup, id int) {
	defer wg.Done()

	log.Printf("worker %d: started", id)

	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			// Context cancelled -> time to shut down.
			log.Printf("worker %d: shutting down", id)
			return
		case t := <-ticker.C:
			// Simulate some periodic work.
			log.Printf("worker %d: tick at %v", id, t)
		}
	}
}

How to adapt this
	•	Replace the ticker loop inside worker with your actual work (HTTP requests, job processing, etc.).
	•	Make sure every long‑running goroutine:
	•	Accepts ctx context.Context
	•	Regularly checks <-ctx.Done() (or ctx.Err()).
	•	If you’re running an HTTP server, you’d typically call srv.Shutdown(ctxWithTimeout) after <-ctx.Done() and then wg.Wait().

If you show me roughly what your app does (HTTP server? workers with channels?) I can tweak this pattern to match it exactly.
Short answer: it expects a long‑running process, not necessarily a “busy” infinite loop.

In the example:

// main
<-ctx.Done()

This line blocks forever until a signal (SIGINT/SIGTERM) arrives. That’s the typical pattern for servers / daemons: “start everything, then wait until we’re told to shut down.”

The only actual loops are inside the workers:

for {
    select {
    case <-ctx.Done():
        // exit the loop and end the goroutine
        return
    case t := <-ticker.C:
        // do work
    }
}

Those are “infinite” in structure, but they stop as soon as ctx is canceled, so they’re really “run until shutdown” loops.

⸻

If your app is not a long‑running server

If you have a finite job (e.g. process a list of items and then exit), you’d typically:
	•	Still use context and WaitGroup for graceful shutdown
	•	But not block on <-ctx.Done() in main
	•	Instead: start your goroutines, do your finite work, then wg.Wait() and return.

Example sketch:

func main() {
    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer stop()

    var wg sync.WaitGroup

    // Kick off finite work
    wg.Add(1)
    go func() {
        defer wg.Done()
        processAllJobs(ctx) // returns when jobs done or ctx canceled
    }()

    // Wait for either:
    // - All work done
    // - Or signal (ctx canceled), after which workers should return quickly
    done := make(chan struct{})
    go func() {
        wg.Wait()
        close(done)
    }()

    select {
    case <-ctx.Done():
        log.Println("shutdown signal received")
        wg.Wait()
    case <-done:
        log.Println("all work completed normally")
    }
}

So:
	•	Server / daemon: block on <-ctx.Done() and let goroutines loop until shutdown.
	•	Batch / finite job: let work finish naturally, but still use ctx so you can interrupt it with a signal.
Yeah, let’s unpack that bit slowly — it’s a super common Go pattern, so it’s worth really understanding.

The code:

for {
    select {
    case <-ctx.Done():
        // exit the loop and end the goroutine
        return
    case t := <-ticker.C:
        // do work
    }
}

We’ll break this into pieces:

⸻

1. for { ... } — an intentional “run forever (until we return)” loop

In Go:
	•	for { ... } is a loop with no condition, so it repeats forever.
	•	The only ways to leave it are:
	•	return (leave the function)
	•	break (leave the loop)
	•	panic (crash out)

So this code says: “Keep doing this select over and over until one of the cases causes us to return.”

⸻

2. select { ... } — wait on multiple channels

select in Go is like switch, but for channel operations.

Basic rules:
	•	Each case must be a channel operation:
	•	receive: x := <-ch
	•	send: ch <- x
	•	select will block until at least one case is ready.
	•	When one or more cases are ready, it picks one (if multiple, it chooses one at random).
	•	Then it runs the code for that case and exits the select (and then the for loop does the next iteration).

So here:

select {
case <-ctx.Done():
    return
case t := <-ticker.C:
    // do work
}

We’re saying:

“Wait until EITHER
	•	the context is canceled (ctx.Done() is ready), OR
	•	the ticker fires (ticker.C receives a time value).
Then run the code for whichever happened.”

⸻

3. ctx.Done() — a channel that closes when you should stop

A context.Context has a method:

Done() <-chan struct{}

	•	This returns a read‑only channel.
	•	When the context is canceled (for example, when you get a signal and call cancel()), this channel is closed.
	•	When you do <-ctx.Done(), you are waiting until that channel is closed.

So:

case <-ctx.Done():
    return

means:

“If the context is canceled, this receive will unblock.
When that happens, return from the function and end the goroutine.”

Because this case doesn’t bind the value (we just write <-ctx.Done() and ignore it), we don’t care what is sent — we just care that the channel closed.

⸻

4. ticker.C — a channel that sends at intervals

A time.Ticker looks like this:

ticker := time.NewTicker(1 * time.Second)
defer ticker.Stop()

It has a field:

C <-chan time.Time

	•	Every period (here, every 1 second), the ticker sends the current time on ticker.C.
	•	When you do t := <-ticker.C, you block until the next tick value is sent.

So:

case t := <-ticker.C:
    // do work

means:

“Every time the ticker fires, receive the time value t and do some work.”

⸻

5. Putting it all together: step-by-step

Imagine time flowing:
	1.	We enter the for loop.
	2.	We hit select { ... }.
At this moment:
	•	ctx.Done() is not ready yet (no cancellation).
	•	ticker.C is also not ready yet (maybe we just created it).
→ select blocks, waiting.
	3.	After 1 second, ticker fires:
	•	ticker.C becomes ready.
	•	ctx.Done() is still not ready.
select chooses:

case t := <-ticker.C:
    // do work

We run the “do work” block, then reach the end of the for loop body.

	4.	Loop goes back to for { ... }, we hit select again.
	5.	This repeats: every tick, we do the work.

Now, suppose you press Ctrl+C or otherwise cancel the context:
	6.	Somewhere else (e.g. in main), we call the cancel function:

cancel() // or ctx is canceled because a signal was received

This causes ctx.Done() channel to close.

	7.	Now, back inside our goroutine:
	•	The next time the select runs, <-ctx.Done() is ready immediately.
	•	Even if ticker.C is also ready, Go will randomly pick one ready case; often when you cancel, ctx.Done() is the one that fires first.
	8.	When this case is chosen:

case <-ctx.Done():
    return

It executes return → the function ends → goroutine exits.

Thus the loop is “infinite” only in structure. In reality, it terminates:
	•	when ctx is canceled, or
	•	if you add some other condition and return/break.

⸻

6. A version with logging to see behavior

Here’s a toy version you could mentally simulate:

for {
    select {
    case <-ctx.Done():
        log.Println("context canceled, worker exiting")
        return
    case t := <-ticker.C:
        log.Println("tick at", t)
    }
}

	•	While running normally: you see a log every second: tick at ...
	•	When you cancel the context: next iteration prints context canceled, worker exiting and the goroutine stops.

⸻

7. Why this pattern is used for graceful shutdown

This loop is powerful because:
	•	It lets a goroutine do periodic or blocking work (via channels).
	•	At the same time, it can react quickly to shutdown signals (via ctx.Done()).
	•	It doesn’t busy-wait — it sleeps inside channel operations until something happens.

Any long-running goroutine that should be stoppable on shutdown can follow this pattern:

for {
    select {
    case <-ctx.Done():
        // cleanup if needed
        return
    case msg := <-someChannel:
        // process msg
    }
}

If you’d like, next I can show the same pattern but with:
	•	An HTTP server, or
	•	A worker that reads jobs from a channel instead of a ticker.
