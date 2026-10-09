class Perch < Formula
  desc "Generate a macOS menu bar app from a YAML file"
  homepage "https://michaelbaker.tech/perch/"
  url "https://github.com/orochi235/perch/archive/refs/tags/v2.4.1.tar.gz"
  sha256 "44db4e56da54d69ed99173d83c2fdb8801d3b9cbd2a9e67a0870a24afa1f0dc8"
  license "MIT"
  head "https://github.com/orochi235/perch.git", branch: "main"

  depends_on "go" => :build
  depends_on :macos

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/perch"
  end

  def caveats
    <<~EOS
      perch compiles the Swift it emits, so it needs the Xcode command line tools:
        xcode-select --install
    EOS
  end

  test do
    (testpath/"menubar.yaml").write <<~YAML
      app: {name: probe, id: dev.example.probe, icon: circle, interval: 5s}
      menu:
        - {text: Quit, quit: true}
    YAML
    system bin/"perch", "build", "-C", testpath
    assert_path_exists testpath/"menubar/Generated/main.swift"
    assert_match "$schema", shell_output("#{bin}/perch schema")
  end
end
