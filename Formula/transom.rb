class Transom < Formula
  desc "Wall for AI-generated renders that forgets them unless you pin one"
  homepage "https://michaelbaker.tech/transom/"
  url "https://github.com/orochi235/transom/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "fd7c365ae1d0d3881224315c4e3feb6390167dd506d30e90d27260970370d3c6"
  license "MIT"
  head "https://github.com/orochi235/transom.git", branch: "main"

  depends_on :macos
  depends_on "node"

  def install
    libexec.install Dir["*"]
    cd libexec do
      system "npm", "ci", "--no-audit", "--no-fund"
      # The page the service's daemon serves. A checkout runs vite instead.
      system "npm", "run", "build"
    end
    (var/"log/transom").mkpath
    # Through opt, not the Cellar: transom writes this path into Claude's
    # settings, and the Cellar path dies on upgrade.
    (bin/"transom").write_env_script opt_libexec/"bin/transom", TRANSOM_HOME: opt_libexec
  end

  service do
    # Pinned: transom tells a keg from a checkout by this plist's name.
    name macos: "tech.michaelbaker.transom"
    run [opt_libexec/"node_modules/.bin/tsx", "server/index.ts"]
    working_dir opt_libexec
    # The daemon exits 0 when another transom already holds its port.
    keep_alive successful_exit: false
    environment_variables PATH: std_service_path_env, TRANSOM_PAGE: opt_libexec/"dist",
                          TRANSOM_LOGS: var/"log/transom"
    log_path var/"log/transom/daemon.log"
    error_log_path var/"log/transom/daemon.log"
  end

  def caveats
    <<~EOS
      Then open http://localhost:7750 on the monitor the wall lives on.

      A wall an earlier release started with `transom install` moves onto
      the service when that is run again.

      Point the Claude Code agents on this machine at it:
        transom wire

      HTML pages and 3D models are shot with Google Chrome, and video
      needs ffmpeg:
        brew install ffmpeg
    EOS
  end

  test do
    (testpath/"probe").mkpath
    cd testpath/"probe" do
      assert_equal "probe", shell_output("#{bin}/transom zone").strip
    end

    # Not the daemon: the test sandbox denies its file watcher. The runner loader
    # because the keg is read-only here and the default writes a temp config into it.
    cd libexec do
      system "node_modules/.bin/vite", "build", "--configLoader", "runner", "--logLevel", "warn",
             "--outDir", testpath/"dist", "--emptyOutDir"
    end
    assert_path_exists testpath/"dist/index.html"
  end
end
