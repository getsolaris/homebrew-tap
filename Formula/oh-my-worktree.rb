class OhMyWorktree < Formula
  desc "[DEPRECATED] Renamed to copse"
  homepage "https://github.com/getsolaris/copse"
  url "https://github.com/getsolaris/copse.git",
      tag:      "v0.12.0",
      revision: "d24739f27db936f7a40eaf8db4ce4156b661bf76"
  license "MIT"

  deprecate! date: "2026-04-09",
             because: "renamed to copse. Run: brew uninstall oh-my-worktree && brew install getsolaris/tap/copse"

  depends_on "oven-sh/bun/bun"

  skip_clean "libexec"

  def install
    system "bun", "install"

    Dir.glob("node_modules/**/*.dylib").each { |f| system "gzip", f }

    libexec.install Dir["*"]

    (bin/"omw").write <<~SH
      #!/bin/bash
      OMW_LIBEXEC="#{libexec}"
      [ -f "$OMW_LIBEXEC/.dylibs_ready" ] || {
        find "$OMW_LIBEXEC/node_modules" -name '*.dylib.gz' -exec gunzip -f {} + 2>/dev/null
        touch "$OMW_LIBEXEC/.dylibs_ready"
      }
      exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" run "$OMW_LIBEXEC/src/index.ts" "$@"
    SH
    chmod 0755, bin/"omw"
  end

  test do
    assert_match "oh-my-worktree", shell_output("#{bin}/omw --version")
  end
end
