class OhMyWorktree < Formula
  desc "Git worktree manager with a beautiful TUI"
  homepage "https://github.com/getsolaris/oh-my-worktree"
  url "https://github.com/getsolaris/oh-my-worktree.git",
      tag:      "v0.3.0",
      revision: "c4519efd988ce12ac9cf512062adf913b2eaa022"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  skip_clean "libexec"

  def install
    system "bun", "install"

    Dir.glob("node_modules/**/*.dylib").each { |f| system "gzip", f }

    libexec.install Dir["*"]
    (bin/"omw").write_env_script libexec/"src/index.ts", PATH: "#{Formula["oven-sh/bun/bun"].opt_bin}:${PATH}"
  end

  def post_install
    Dir.glob("#{libexec}/node_modules/**/*.dylib.gz").each do |gz|
      cd File.dirname(gz) { system "gunzip", File.basename(gz) }
    end
  end

  test do
    assert_match "oh-my-worktree", shell_output("#{bin}/omw --version")
  end
end