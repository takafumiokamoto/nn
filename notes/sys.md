Zap doesn’t ship a built-in “syslog sink/core”, so the usual pattern is:
	1.	create a log/syslog.Writer (local syslog), and
	2.	either (A) write a small custom zapcore.Core so you can map Zap levels → syslog severities, or (B) tee multiple cores (one per severity) if you don’t want to write a core.

Below are both options.

⸻

1) Connect to local syslog

log/syslog.Dial connects to syslog over unix socket / UDP / TCP; if network is empty it connects to the local syslog daemon.  ￼

import "log/syslog"

w, err := syslog.Dial("", "", syslog.LOG_USER, "myapp") // local syslog, facility=USER
if err != nil {
    // In containers/minimal OS images there may be no local syslog socket.
    // Handle or fallback to stderr/file/etc.
}
defer w.Close()

Note: on Unix, the stdlib syslog client typically tries local sockets like /dev/log (Linux) or /var/run/syslog (macOS/BSD); if they don’t exist you’ll get delivery errors.  ￼

⸻

2A) Recommended: custom zapcore.Core (clean severity mapping)

This keeps one encoder and maps each Entry.Level to the matching syslog call (Debug/Info/Warning/Err/Crit/Alert/Emerg).

package zapsyslog

import (
	"log/syslog"
	"sync"

	"go.uber.org/zap/zapcore"
)

type Core struct {
	enc   zapcore.Encoder
	enab  zapcore.LevelEnabler
	w     *syslog.Writer
	mu    sync.Mutex // be conservative; protects w
}

func NewCore(enc zapcore.Encoder, w *syslog.Writer, enab zapcore.LevelEnabler) zapcore.Core {
	return &Core{enc: enc, w: w, enab: enab}
}

func (c *Core) Enabled(lvl zapcore.Level) bool { return c.enab.Enabled(lvl) }

func (c *Core) With(fields []zapcore.Field) zapcore.Core {
	enc := c.enc.Clone()
	for i := range fields {
		fields[i].AddTo(enc)
	}
	return &Core{enc: enc, w: c.w, enab: c.enab}
}

func (c *Core) Check(ent zapcore.Entry, ce *zapcore.CheckedEntry) *zapcore.CheckedEntry {
	if c.Enabled(ent.Level) {
		return ce.AddCore(ent, c)
	}
	return ce
}

func (c *Core) Write(ent zapcore.Entry, fields []zapcore.Field) error {
	buf, err := c.enc.EncodeEntry(ent, fields)
	if err != nil {
		return err
	}
	msg := buf.String()
	buf.Free()

	c.mu.Lock()
	defer c.mu.Unlock()

	// Zap -> syslog severity mapping:
	switch ent.Level {
	case zapcore.DebugLevel:
		return c.w.Debug(msg)
	case zapcore.InfoLevel:
		return c.w.Info(msg)
	case zapcore.WarnLevel:
		return c.w.Warning(msg)
	case zapcore.ErrorLevel:
		return c.w.Err(msg)
	case zapcore.DPanicLevel:
		return c.w.Crit(msg)
	case zapcore.PanicLevel:
		return c.w.Alert(msg)
	case zapcore.FatalLevel:
		return c.w.Emerg(msg)
	default:
		return c.w.Info(msg)
	}
}

func (c *Core) Sync() error { return nil } // syslog doesn't really "sync"

Usage:

encCfg := zapcore.EncoderConfig{
	TimeKey:        "ts",
	LevelKey:       "level",
	MessageKey:     "msg",
	EncodeTime:     zapcore.ISO8601TimeEncoder,
	EncodeLevel:    zapcore.LowercaseLevelEncoder,
}
enc := zapcore.NewJSONEncoder(encCfg)

sysw, _ := syslog.Dial("", "", syslog.LOG_USER, "myapp")

core := zapsyslog.NewCore(enc, sysw, zapcore.InfoLevel)
logger := zap.New(core)


⸻

2B) Alternative: tee multiple cores (no custom Core, but more wiring)

syslog.Writer.Write([]byte) logs at the fixed priority you created it with. So if you want per-level severity mapping without a custom core, you can create one syslog writer per severity and filter each core to exactly one Zap level.

Conceptually:
	•	Debug core → syslog writer with LOG_DEBUG
	•	Info core → LOG_INFO
	•	Warn core → LOG_WARNING
	•	Error core → LOG_ERR
	•	etc.

Downside: more connections/writers.

⸻

Severity mapping cheat-sheet (Zap → syslog)

A practical mapping many teams use:
	•	Debug → LOG_DEBUG
	•	Info → LOG_INFO
	•	Warn → LOG_WARNING
	•	Error → LOG_ERR
	•	DPanic → LOG_CRIT
	•	Panic → LOG_ALERT
	•	Fatal → LOG_EMERG

If you tell me your target (rsyslog, journald/systemd, macOS logd, remot
e syslog server, etc.), I can tweak the mapping/facility/tagging conventions so it shows up exactly how you expect in that environment.

Sure — 1A (a custom zapcore.Core) is the cleanest way to get real syslog severity mapping without juggling multiple writers.

Below is a more “production-ready” version, plus the why behind each method.

⸻

What you’re implementing

Zap routes everything through the zapcore.Core interface: it embeds a LevelEnabler, and you must implement With, Check, Write, and Sync.  ￼

Syslog’s stdlib Writer gives you severity-specific methods (Debug, Info, Warning, Err, Crit, Alert, Emerg, plus Notice) and Dial("", "", ...) connects to the local syslog daemon when network is empty.  ￼

Also important: the syslog writer’s severity-specific methods ignore the severity you passed to New/Dial (that priority’s severity part is ignored for those calls). That’s exactly what we want: we’ll pass a facility once, then choose severity per entry.  ￼

⸻

A solid syslog Core implementation

Key improvements vs the minimal snippet
	•	Uses a sync.Mutex to serialize calls into syslog.Writer (conservative + avoids interleaving).
	•	Removes the trailing newline from encoded output (some encoders include it; syslog already frames lines).
	•	Maps Zap levels to syslog severities (and optionally uses NOTICE for Info if you prefer).
	•	Provides a Close() helper you can call on shutdown (Zap doesn’t have a “Close hook” built in).

package zapsyslog

import (
	"log/syslog"
	"strings"
	"sync"

	"go.uber.org/zap/zapcore"
)

type Core struct {
	enc   zapcore.Encoder
	enab  zapcore.LevelEnabler
	w     *syslog.Writer
	mu    sync.Mutex
}

func NewCore(enc zapcore.Encoder, w *syslog.Writer, enab zapcore.LevelEnabler) *Core {
	return &Core{enc: enc, w: w, enab: enab}
}

// Enabled is required because Core embeds LevelEnabler.  [oai_citation:3‡Go Packages](https://pkg.go.dev/go.uber.org/zap/zapcore)
func (c *Core) Enabled(lvl zapcore.Level) bool {
	return c.enab.Enabled(lvl)
}

// With must return a new Core with additional structured context.  [oai_citation:4‡Go Packages](https://pkg.go.dev/go.uber.org/zap/zapcore)
func (c *Core) With(fields []zapcore.Field) zapcore.Core {
	enc := c.enc.Clone()
	for i := range fields {
		fields[i].AddTo(enc)
	}
	return &Core{enc: enc, w: c.w, enab: c.enab}
}

// Check decides whether to log and adds this core to CheckedEntry.  [oai_citation:5‡Go Packages](https://pkg.go.dev/go.uber.org/zap/zapcore)
func (c *Core) Check(ent zapcore.Entry, ce *zapcore.CheckedEntry) *zapcore.CheckedEntry {
	if c.Enabled(ent.Level) {
		return ce.AddCore(ent, c)
	}
	return ce
}

// Write must *always* write: no filtering logic here (that belongs in Check).  [oai_citation:6‡Go Packages](https://pkg.go.dev/go.uber.org/zap/zapcore)
func (c *Core) Write(ent zapcore.Entry, fields []zapcore.Field) error {
	buf, err := c.enc.EncodeEntry(ent, fields)
	if err != nil {
		return err
	}
	msg := strings.TrimRight(buf.String(), "\n")
	buf.Free()

	c.mu.Lock()
	defer c.mu.Unlock()

	switch ent.Level {
	case zapcore.DebugLevel:
		return c.w.Debug(msg)   // LOG_DEBUG  [oai_citation:7‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	case zapcore.InfoLevel:
		// Pick one:
		// return c.w.Info(msg)   // LOG_INFO  [oai_citation:8‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
		return c.w.Notice(msg) // LOG_NOTICE  [oai_citation:9‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	case zapcore.WarnLevel:
		return c.w.Warning(msg) // LOG_WARNING  [oai_citation:10‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	case zapcore.ErrorLevel:
		return c.w.Err(msg)     // LOG_ERR  [oai_citation:11‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	case zapcore.DPanicLevel:
		return c.w.Crit(msg)    // LOG_CRIT  [oai_citation:12‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	case zapcore.PanicLevel:
		return c.w.Alert(msg)   // LOG_ALERT  [oai_citation:13‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	case zapcore.FatalLevel:
		return c.w.Emerg(msg)   // LOG_EMERG  [oai_citation:14‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	default:
		return c.w.Info(msg)    // fallback  [oai_citation:15‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
	}
}

// Sync is for flushing buffered logs. syslog.Writer doesn't expose flush semantics,
// so this is typically a no-op.  [oai_citation:16‡Go Packages](https://pkg.go.dev/go.uber.org/zap/zapcore)
func (c *Core) Sync() error { return nil }

// Not part of zapcore.Core, but handy for shutdown.
func (c *Core) Close() error {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.w.Close() //  [oai_citation:17‡Go Packages](https://pkg.go.dev/github.com/shogo82148/std/log/syslog)
}


⸻

Wiring it up (local syslog + JSON or console)

sysw, err := syslog.Dial("", "", syslog.LOG_USER, "myapp")
if err != nil {
	// no local syslog socket/daemon available; fallback to stderr/file etc.
}

Dial("", "", ...) uses local syslog when network is empty.  ￼

Encoder choice tips
	•	JSON encoder if you want syslog to carry structured payloads as JSON text.
	•	Console encoder if humans read syslog directly.

Example JSON encoder:

encCfg := zapcore.EncoderConfig{
	TimeKey:        "ts",
	LevelKey:       "level",
	MessageKey:     "msg",
	NameKey:        "logger",
	CallerKey:      "caller",
	StacktraceKey:  "stacktrace",
	EncodeTime:     zapcore.ISO8601TimeEncoder,
	EncodeLevel:    zapcore.LowercaseLevelEncoder,
	EncodeCaller:   zapcore.ShortCallerEncoder,
}
enc := zapcore.NewJSONEncoder(encCfg)
core := zapsyslog.NewCore(enc, sysw, zapcore.InfoLevel)

logger := zap.New(core,
	zap.AddCaller(),              // populates Entry.Caller so encoder can write it
	zap.AddStacktrace(zapcore.ErrorLevel),
)
defer core.Close()


⸻

A couple of “gotchas” you’ll hit in real environments

1) Facility vs severity

You set facility once in Dial (e.g., LOG_USER, LOG_LOCAL0…), and severity is chosen per message using methods like w.Warning, w.Err, etc.  ￼

2) Local syslog may not exist (containers)

Many minimal images don’t run a syslog daemon or don’t have /dev/log. If Dial fails, you’ll need a fallback core (stderr/file/OTel).

3) What about Notice?

Syslog has Notice as a distinct severity.  ￼
A common convention is:
	•	Info → Notice
	•	Debug → Debug
…but if your org treats notice differently, just switch Notice back to Info.

⸻

If you tell me your target runtime (Linux w/ rsyslog, systemd-journald, macOS, k8s container), I can show the best Dial(...) settings (socket vs UDP/TCP) and the encoder format that plays nicest with that syslog backend.


On Ubuntu you can verify your Zap→syslog core in two places:
	1.	systemd journal (journald) via journalctl
	2.	classic syslog files like /var/log/syslog (if rsyslog is installed/running and configured)

Ubuntu commonly runs systemd-journald, which collects “simple system log messages via the libc syslog() call”  ￼, and many setups also forward them to rsyslog//var/log/syslog depending on config  ￼.

⸻

0) First: confirm your syslog “tag” (identifier)

In your Go code you likely did:

syslog.Dial("", "", syslog.LOG_USER, "myapp")

That "myapp" is the syslog identifier/tag you’ll filter on in the journal and in /var/log/syslog.

⸻

1) Verify via journalctl (recommended on Ubuntu)

Tail live logs for your tag

sudo journalctl -f -t myapp

journalctl -t/--identifier=SYSLOG_IDENTIFIER filters by syslog identifier/tag.  ￼

Show recent logs (last 10 minutes)

sudo journalctl -t myapp --since "10 minutes ago"

If your app runs as a systemd service, you can also filter by unit:

sudo journalctl -u myapp.service --since "10 minutes ago"


⸻

2) Verify via /var/log/syslog (rsyslog path)

Tail syslog and grep for your tag

sudo tail -f /var/log/syslog | grep -F myapp

On many Ubuntu installs, /var/log/syslog is where general syslog ends up, but the exact routing rules come from rsyslog config (commonly /etc/rsyslog.d/50-default.conf).  ￼

If /var/log/syslog does not exist

That usually means rsyslog isn’t installed/running or isn’t writing that file on your setup. (rsyslog is typically what creates /var/log/syslog.)  ￼
In that case, journalctl is still the best way to verify.

⸻

3) Sanity-check your “syslog pipeline” before testing Zap

Use the logger command to emit a known message to syslog with the same tag:

logger -t myapp "syslog test from logger"

logger is the standard CLI tool to write to syslog, and -t sets the tag.  ￼

Then check:

sudo journalctl -t myapp --since "2 minutes ago"
# and/or
sudo tail -n 50 /var/log/syslog | grep -F myapp

If you see the logger message but not your Go app’s message, the issue is in your app/core (tag, dial error, filtering, etc.). If you see neither, syslog/journald routing is the issue.

⸻

4) Verify your severity mapping

In your Zap→syslog core, you mapped Zap levels to syslog methods (Debug/Info/Warning/Err/...). Those should show up as priorities in journald.

Try emitting one log at each level (debug/info/warn/error), then view with a verbose journal output:

sudo journalctl -t myapp --since "10 minutes ago" -o verbose

Look for fields like PRIORITY= and confirm it changes with your log level.

⸻

If you tell me:
	•	your Ubuntu version (e.g., 22.04 / 24.04), and
	•	whether your Go app runs as a systemd service or from a shell,

…I can give you the most direct journalctl command to isolate only your process logs (service unit + identifier + time window).
