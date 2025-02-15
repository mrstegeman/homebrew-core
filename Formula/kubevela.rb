class Kubevela < Formula
  desc "Application Platform based on Kubernetes and Open Application Model"
  homepage "https://kubevela.io"
  url "https://github.com/kubevela/kubevela.git",
      tag:      "v1.5.5",
      revision: "b6a7d8621fd515e2a861e90c8e79dd73a4d123d5"
  license "Apache-2.0"
  head "https://github.com/kubevela/kubevela.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b0b0ceed1a29ca6a79ff811a6ee9d78d4ddcfece1e7e81bc8cb2b670203705c8"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "b0b0ceed1a29ca6a79ff811a6ee9d78d4ddcfece1e7e81bc8cb2b670203705c8"
    sha256 cellar: :any_skip_relocation, monterey:       "db0ad3d85c0e6109d2317c01b0efb05362426f03bfa42fed58398e8f79baacf4"
    sha256 cellar: :any_skip_relocation, big_sur:        "db0ad3d85c0e6109d2317c01b0efb05362426f03bfa42fed58398e8f79baacf4"
    sha256 cellar: :any_skip_relocation, catalina:       "db0ad3d85c0e6109d2317c01b0efb05362426f03bfa42fed58398e8f79baacf4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "7a85fc761da0f1b8818bd06af8cdf006a6b2dccd09fff9759088b97302e99425"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/oam-dev/kubevela/version.VelaVersion=#{version}
      -X github.com/oam-dev/kubevela/version.GitRevision=#{Utils.git_head}
    ]

    system "go", "build", *std_go_args(output: bin/"vela", ldflags: ldflags), "./references/cmd/cli"
  end

  test do
    # Should error out as vela up need kubeconfig
    status_output = shell_output("#{bin}/vela up 2>&1", 1)
    assert_match "error: no configuration has been provided", status_output

    (testpath/"kube-config").write <<~EOS
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: test
          server: http://127.0.0.1:8080
        name: test
      contexts:
      - context:
          cluster: test
          user: test
        name: test
      current-context: test
      kind: Config
      preferences: {}
      users:
      - name: test
        user:
          token: test
    EOS

    ENV["KUBECONFIG"] = testpath/"kube-config"
    version_output = shell_output("#{bin}/vela version 2>&1")
    assert_match "Version: #{version}", version_output
  end
end
