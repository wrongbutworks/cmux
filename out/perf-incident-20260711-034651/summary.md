# Incident: NIGHTLY TextBox crash

Symptom: Opening terminal TextBox crashed cmux NIGHTLY.
User impact: The entire macOS app terminated and relaunched.
Source: User report plus macOS unified log.
Target surface: macOS.
Build/version/tag: cmux NIGHTLY 0.64.17-nightly.2913072634601 (2913072634601).
Repro workload: Open terminal TextBox, which warms the file mention index for the workspace.
Expected bad behavior: A child `git check-ignore --stdin` process exits before cmux writes its probe batch, and Foundation raises an uncaught broken-pipe exception.

## Crash evidence

At 2026-07-11 03:46:51.124, PID 10549 logged `Encountered write failure 32 Broken pipe`.

At 2026-07-11 03:46:51.167, the app terminated with uncaught `NSFileHandleOperationException`: `-[NSConcreteFileHandle writeData:]: Broken pipe`.

First in-app frames:

1. `TextBoxMentionIndexStore.gitIgnoredRelativePaths(rootURL:relativePaths:)`
2. `TextBoxMentionIndexStore.scanDirectoryCandidateSeed(rootURL:)`
3. `TextBoxMentionIndexStore.scanFilesWithRipgrep(rootURL:)`
4. `TextBoxMentionIndexStore.scanFiles(rootURL:)`
5. TextBox file-index refresh task

The adjacent SwiftUI reentrant-layout and publish-during-update warnings did not terminate the process. The uncaught Foundation exception did.

## Owner and invariant

Owner: `TextBoxMentionIndexStore` owns the lifetime and standard input of its `git check-ignore` subprocess.

Invariant: A child process may close its standard-input pipe at any time; writing mention-index probes must return a recoverable empty ignore result instead of raising an Objective-C exception that terminates cmux.

Why the old path failed: It called the legacy nonthrowing `FileHandle.write(_:)`, which raises `NSFileHandleOperationException` on `EPIPE` and cannot be handled by Swift `do`/`catch`.

Fix shape: Use Foundation's throwing file-handle write API, close standard input on every path, and treat an early child exit as a failed best-effort ignore probe.

Proof that closes it: A behavior test uses a valid Git worktree with a deliberately corrupt index, causing `git check-ignore` to exit before reading its input. TextBox file suggestions must complete without terminating the test host.
