class Hued < Formula
  desc "Change terminal colors declaratively by directory"
  homepage "https://github.com/orochi235/hued"
  url "https://github.com/orochi235/hued/archive/refs/tags/v4.4.0.tar.gz"
  sha256 "5e4bd4d8735bb8b7ff4a0df614bfc7817e3cdfbfaa21b5e18480c3224458692e"
  license "MIT"

  depends_on "python@3.12"

  def install
    bin.install "bin/hued"
    bin.install "bin/hued-py"
    share.install "hued.sh"
    share.install "hued-names.sh"
    share.install "hued.fish"
    bash_completion.install "completions/hued.bash"
    zsh_completion.install "completions/_hued"
    fish_completion.install "completions/hued.fish"
    (libexec/"hued").install "src/huedmap"
  end

  def caveats
    <<~EOS
      Add to your shell config:

      Zsh (~/.zshrc):
        source #{share}/hued.sh
        precmd_functions+=(_hued_apply)

      Bash (~/.bashrc):
        source #{share}/hued.sh
        PROMPT_COMMAND="_hued_apply${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

      Fish:
        cp #{share}/hued.fish ~/.config/fish/conf.d/hued.fish
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hued --version")
    # Reaches huedmap through hued-py and libexec, which the install list has to get right.
    assert_match "usage: hued map", shell_output("#{bin}/hued map --help")
    system bin/"hued", "set", "bg=#191970"
    assert_match "background=#191970", (testpath/".hued").read
  end
end
