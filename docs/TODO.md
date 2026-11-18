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
- **Give `Formula/hued.rb` a `test do` block.** It installs a hand-listed payload (both
  launchers, the shell hooks, the completions, and `src/huedmap`) and has no test, so a
  runtime file added upstream and missed here installs cleanly and fails only when used. A
  test should run `hued --version` against `version`, import `huedmap` through `hued-py`,
  and round-trip a scratch `.hued` inside the test's temp directory, never touching the
  user's shell config. Not added blind: it needs a `brew test` run to confirm. (filed
  2026-11-15 from automated review)
- **Check hued's install list against each release.** `Formula/hued.rb`'s `install` list is a second
  contract with hued's tree, kept in step by hand. hued's release workflow could unpack the
  tagged archive and fail when a shipped runtime file isn't named in the formula. (filed
  2026-11-15 from automated review)
