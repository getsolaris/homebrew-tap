class OhMyWorktree < Formula
  desc "Git worktree manager with a beautiful TUI"
  homepage "https://github.com/getsolaris/oh-my-worktree"
  url "https://github.com/getsolaris/oh-my-worktree.git",
      tag:      "v0.2.1",
      revision: "52786de3506e5315a55e81389604f54d01c68248"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  skip_clean "libexec"

  def install
    system "bun", "install"

    dylib_relative = "node_modules/@opentui/core-darwin-arm64/libopentui.dylib"
    dylib_backup = Pathname.new(Dir.tmpdir)/"omw-libopentui.dylib"

    if File.exist?(dylib_relative)
      FileUtils.mv dylib_relative, dylib_backup
    end

    libexec.install Dir["*"]

    if dylib_backup.exist?
      target = libexec/dylib_relative
      FileUtils.mv dylib_backup, target
    end

    (bin/"omw").write_env_script libexec/"src/index.ts", PATH: "#{Formula["oven-sh/bun/bun"].opt_bin}:${PATH}"
  end

  test do
    assert_match "oh-my-worktree", shell_output("#{bin}/omw --version")
  end
end