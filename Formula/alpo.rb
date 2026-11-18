class Alpo < Formula
  desc "Serve a library from its local checkout until a release carries what you need"
  homepage "https://github.com/orochi235/alpo"
  url "https://registry.npmjs.org/@msb235/alpo/-/alpo-0.1.0.tgz"
  sha256 "c3f58f43520aa2ec3c45c5778c1e94518bc88ea6777cedf76ee501786ae5f900"
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
