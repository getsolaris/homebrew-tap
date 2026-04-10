class OhMyLemontree < Formula
  desc "[DEPRECATED] Renamed to copse"
  homepage "https://github.com/getsolaris/copse"
  url "https://github.com/getsolaris/copse.git",
      tag:      "v1.0.0",
      revision: "69e29a6344b0ccdb811b3fd00cbd80394e2e994f"
  license "MIT"

  deprecate! date: "2026-04-10",
             because: "renamed to copse. Run: brew uninstall oh-my-lemontree && brew install getsolaris/tap/copse"

  depends_on "oven-sh/bun/bun"

  skip_clean "libexec"

  def install
    system "bun", "install"

    Dir.glob("node_modules/**/*.dylib").each { |f| system "gzip", f }

    libexec.install Dir["*"]

    (bin/"oml").write <<~SH
      #!/bin/bash
      OML_LIBEXEC="#{libexec}"
      [ -f "$OML_LIBEXEC/.dylibs_ready" ] || {
        find "$OML_LIBEXEC/node_modules" -name '*.dylib.gz' -exec gunzip -f {} + 2>/dev/null
        touch "$OML_LIBEXEC/.dylibs_ready"
      }
      exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" run "$OML_LIBEXEC/src/index.ts" "$@"
    SH
    chmod 0755, bin/"oml"
  end

  test do
    assert_match "copse", shell_output("#{bin}/oml --version")
  end
end
