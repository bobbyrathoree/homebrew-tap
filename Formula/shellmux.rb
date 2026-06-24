class Shellmux < Formula
  desc "Content-blind topic pub/sub broker in shell with a race-free deadline scheduler"
  homepage "https://github.com/bobbyrathoree/shellmux"
  url "https://github.com/bobbyrathoree/shellmux/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "fb8f8230192c5a34542e41f3f3c96af8647b4ab34a29477dc259843c43015baf"
  license "MIT"

  # The real dependency set. shellmux is Linux-first; on macOS these brewed deps
  # supply what the base system lacks (flock, GNU timeout, bash >= 4). The wrapper
  # below puts them on PATH so the broker resolves them at runtime.
  depends_on "bash"        # macOS ships 3.2; the scheduler needs >= 4 for fractional read -t
  depends_on "coreutils"   # GNU timeout, mkfifo
  depends_on "socat"
  on_macos do
    depends_on "flock"      # standalone flock formula on macOS
  end
  on_linux do
    depends_on "util-linux" # flock
  end

  def install
    # Keep shellmux + sched.sh siblings (the broker resolves the scheduler as its
    # own dirname/sched.sh), then expose a PATH-fixed wrapper as the bin entry.
    libexec.install "src/shellmux", "src/sched.sh"
    (bin/"shellmux").write <<~SH
      #!/bin/bash
      export PATH="#{formula_opt_libexec("coreutils")}/gnubin:#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:$PATH"
      exec "#{formula_opt_bin("bash")}/bash" "#{libexec}/shellmux" "$@"
    SH
    chmod 0755, bin/"shellmux"

    # docs for  / offline reference
    pkgshare.install "README.md", "DEMO.md", "LICENSE"
  end

  test do
    assert_match "shellmux 0.1.1", shell_output("#{bin}/shellmux --version")
    # a real serve/sub/pub round-trip would need background processes + a socket;
    # the version smoke confirms the wrapper resolves bash + the libexec script.
  end
end
