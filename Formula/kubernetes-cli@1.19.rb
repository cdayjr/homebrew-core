class KubernetesCliAT119 < Formula
  desc "Kubernetes command-line interface (1.19)"
  homepage "https://kubernetes.io/"
  url "https://github.com/kubernetes/kubernetes.git",
      tag:      "v1.19.10",
      revision: "98d5dc5d36d34a7ee13368a7893dcb400ec4e566"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  keg_only :versioned_formula

  deprecate! date: "2021-04-18", because: :versioned_formula

  depends_on "bash" => :build
  depends_on "go" => :build

  uses_from_macos "rsync" => :build

  # ARM support, only officially available in 1.21+
  patch do
    url "https://github.com/kubernetes/kubernetes/commit/f719624654c68d143cad4e4af2f21cca0bfde8fd.patch?full_index=1"
    sha256 "3d40308a2f639c1a45a2105889776f0d02dd97000c188bc4cc78de739d5f0776"
  end

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Make binary
    system "make", "WHAT=cmd/kubectl"
    bin.install "_output/bin/kubectl"

    # Install bash completion
    output = Utils.safe_popen_read("#{bin}/kubectl", "completion", "bash")
    (bash_completion/"kubectl").write output

    # Install zsh completion
    output = Utils.safe_popen_read("#{bin}/kubectl", "completion", "zsh")
    (zsh_completion/"_kubectl").write output

    # Install man pages
    # Leave this step for the end as this dirties the git tree
    system "hack/generate-docs.sh"
    man1.install Dir["docs/man/man1/*.1"]
  end

  test do
    run_output = shell_output("#{bin}/kubectl 2>&1")
    assert_match "kubectl controls the Kubernetes cluster manager.", run_output

    version_output = shell_output("#{bin}/kubectl version --client 2>&1")

    if build.stable?
      assert_match stable.instance_variable_get(:@resource)
                         .instance_variable_get(:@specs)[:revision],
                   version_output
    end
  end
end
