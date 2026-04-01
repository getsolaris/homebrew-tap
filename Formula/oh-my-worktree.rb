class OhMyWorktree < Formula
  desc "Git worktree manager with a beautiful TUI"
  homepage "https://github.com/getsolaris/oh-my-worktree"
  url "https://github.com/getsolaris/oh-my-worktree.git",
      tag:      "v0.1.1",
      revision: "228eb4bf7f82a4fdd830c43a9ec77039517125c7"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  skip_clean "libexec"

  def install
    system "bun", "install"
    libexec.install Dir["*"]
    (bin/"omw").write_env_script libexec/"src/index.ts", PATH: "#{Formula["oven-sh/bun/bun"].opt_bin}:${PATH}"
  end

  test do
    assert_match "oh-my-worktree", shell_output("#{bin}/omw --version")
  end
end
