class HelmAT34 < Formula
  desc "Kubernetes package manager (3.4)"
  homepage "https://helm.sh/"
  url "https://github.com/helm/helm.git",
      tag:      "v3.4.2",
      revision: "23dd3af5e19a02d4f4baa5b2f242645a1a3af629"
  license "Apache-2.0"

  keg_only :versioned_formula

  deprecate! date: "2021-01-13", because: :deprecated_upstream

  depends_on "go@1.15" => :build

  def install
    # See https://github.com/helm/helm/pull/9486, remove with next release (3.5.4)
    on_linux do
      system "go", "mod", "tidy"
    end

    system "make", "build"
    bin.install "bin/helm"

    mkdir "man1" do
      system bin/"helm", "docs", "--type", "man"
      man1.install Dir["*"]
    end

    output = Utils.safe_popen_read({ "SHELL" => "bash" }, bin/"helm", "completion", "bash")
    (bash_completion/"helm").write output

    output = Utils.safe_popen_read({ "SHELL" => "zsh" }, bin/"helm", "completion", "zsh")
    (zsh_completion/"_helm").write output
  end

  test do
    system "#{bin}/helm", "create", "foo"
    assert File.directory? "#{testpath}/foo/charts"

    version_output = shell_output("#{bin}/helm version 2>&1")
    assert_match "Version:\"v#{version}\"", version_output
    if build.stable?
      assert_match stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision], version_output
    end
  end
end
