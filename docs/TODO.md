# TODO

- **Test what the installed formulae actually run, not only what they generate.**
  `Formula/perch.rb`'s test checks that `perch build` emits Swift and that `perch schema`
  prints a schema, but never compiles that Swift, which is the step that needs the Xcode
  command line tools the caveat names. `Formula/transom.rb`'s test runs `transom zone` and a
  Vite build, not the `tsx server/index.ts` the service runs, so a runtime dependency missing
  from the keg passes. Add bounded probes where the Homebrew sandbox allows them (a `swiftc`
  typecheck of the generated file; loading the server module without starting its file
  watcher), and leave anything that needs macOS permissions, Chrome, or ffmpeg out of
  `test do`. (filed 2026-11-15 from automated review)
