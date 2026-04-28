class E11h < Formula
  desc "Keyboard-driven TUI for Elasticsearch and OpenSearch"
  homepage "https://github.com/getsolaris/e11h"
  url "https://github.com/getsolaris/e11h.git",
      tag:      "v0.1.0",
      revision: "0000000000000000000000000000000000000000"
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
    (bin/"e11h").write <<~SH
      #!/bin/bash
      E11H_LIBEXEC="#{libexec}"
      [ -f "$E11H_LIBEXEC/.dylibs_ready" ] || {
        find "$E11H_LIBEXEC/node_modules" -name '*.dylib.gz' -exec gunzip -f {} + 2>/dev/null
        touch "$E11H_LIBEXEC/.dylibs_ready"
      }
      exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" run "$E11H_LIBEXEC/src/index.tsx" "$@"
    SH
    chmod 0755, bin/"e11h"
  end

  test do
    assert_match "e11h", shell_output("#{bin}/e11h --version")
  end
end
