class Shellmux < Formula
  desc "Content-blind topic pub/sub broker in shell with a race-free deadline scheduler"
  homepage "https://github.com/bobbyrathoree/shellmux"
  url "https://github.com/bobbyrathoree/shellmux/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6fc0aaa66157d0c595a16ec2c2861acffc26c117fc50d59270f275387869cce4"
  license "MIT"
  version "0.1.0"

  # The real dependency set. shellmux is Linux-first; on macOS these brewed deps
  # supply what the base system lacks (flock, GNU timeout, bash >= 4). The wrapper
  # below puts them on PATH so the broker resolves them at runtime.
  depends_on "bash"        # macOS ships 3.2; the scheduler needs >= 4 for fractional read -t
  depends_on "socat"
  depends_on "coreutils"   # GNU timeout, mkfifo
  on_linux do
    depends_on "util-linux" # flock
  end
  on_macos do
    depends_on "flock"      # standalone flock formula on macOS
  end

  def install
    # Keep shellmux + sched.sh siblings (the broker resolves the scheduler as its
    # own dirname/sched.sh), then expose a PATH-fixed wrapper as the bin entry.
    libexec.install "src/shellmux", "src/sched.sh"
    (bin/"shellmux").write <<~SH
      #!/bin/bash
      export PATH="#{Formula["coreutils"].opt_libexec}/gnubin:#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:$PATH"
      exec "#{Formula["bash"].opt_bin}/bash" "#{libexec}/shellmux" "$@"
    SH
    chmod 0755, bin/"shellmux"

    # docs for  / offline reference
    pkgshare.install "README.md", "DEMO.md", "LICENSE"
  end

  test do
    assert_match "shellmux 0.1.0", shell_output("#{bin}/shellmux --version")
    # a real serve/sub/pub round-trip would need background processes + a socket;
    # the version smoke confirms the wrapper resolves bash + the libexec script.
  end
end
