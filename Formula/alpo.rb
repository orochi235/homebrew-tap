class Alpo < Formula
  desc "Serve a library from its local checkout until a release carries what you need"
  homepage "https://github.com/orochi235/alpo"
  url "https://registry.npmjs.org/@msb235/alpo/-/alpo-0.3.0.tgz"
  sha256 "c8d3eae160a892e32837db3dcae515e843e5383fef52b8141940c8bcf8b6d59f"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  def caveats
    <<~EOS
      The vite plugin is not part of this install: a repository that serves a
      linked library through vite takes @msb235/alpo as a dev dependency.
    EOS
  end

  test do
    ENV["ALPO_HOME"] = testpath/".alpo"
    assert_match "serve a library from its checkout", shell_output("#{bin}/alpo --help")
    assert_equal "nothing has joined yet", shell_output("#{bin}/alpo ls").strip
  end
end
