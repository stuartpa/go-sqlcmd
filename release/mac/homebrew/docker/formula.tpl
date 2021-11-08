# frozen_string_literal: true

# GO MSSQL TOOLS CLI, a multi-platform command line experience
class GoMssqlTools < Formula
  include Language::Python::Virtualenv

  desc "Microsoft SQL Server Tools"
  homepage "https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools"
  url "{{ upstream_url }}"
  version "{{ cli_version }}"
  sha256 "{{ upstream_sha }}"

{{ bottle_hash }}

  depends_on "freetds"
  depends_on "libpq"
  depends_on "Microsoft/homebrew-mssql-release/msodbcsql17"
  depends_on "Microsoft/homebrew-mssql-release/mssql-tools"
  depends_on "openssl@1.1"
  depends_on "python@3.8"
  depends_on "unixodbc"
  depends_on "zeromq"

{{ resources }}

  def install

    # Get the CLI components to install
    components = [
      buildpath/"sqlcmd",
    ]

    # Install CLI
    components.each do |item|
      cd item do
        venv.pip_install item
      end
    end

    (bin/"azdata").write <<~EOS
      #!/usr/bin/env bash
      #{libexec}/bin/python -m azdata.cli \"$@\"
    EOS

  end

  test do
    json_text = shell_output("#{bin}/sqlcmd --help")
    out = JSON.parse(json_text)
    # TODO: assert_equal out["stderr"], []
  end
end
