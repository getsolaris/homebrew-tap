class Copse < Formula
  desc "Copse - Git worktree manager with a TUI"
  homepage "https://github.com/getsolaris/copse"
  url "https://github.com/getsolaris/copse.git",
      tag:      "v1.0.3",
      revision: "28b2f9a5e577b875b51180fd218360f4e5a164a5"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  # Prevent Homebrew from cleaning files inside libexec
  skip_clean "libexec"

  def install
    system "bun", "install"

    # Gzip native dylibs so Homebrew's Mach-O relinking skips them.
    # @opentui ships dylibs whose headers are too small for install_name_tool.
    Dir.glob("node_modules/**/*.dylib").each { |f| system "gzip", f }

    libexec.install Dir["*"]

    # Launcher script decompresses gzipped dylibs on first run
    (bin/"copse").write <<~SH
      #!/bin/bash
      COPSE_LIBEXEC="#{libexec}"
      [ -f "$COPSE_LIBEXEC/.dylibs_ready" ] || {
        find "$COPSE_LIBEXEC/node_modules" -name '*.dylib.gz' -exec gunzip -f {} + 2>/dev/null
        touch "$COPSE_LIBEXEC/.dylibs_ready"
      }
      exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" run "$COPSE_LIBEXEC/src/index.ts" "$@"
    SH
    chmod 0755, bin/"copse"
  end

  test do
    assert_match "copse", shell_output("#{bin}/copse --version")
  end
end
