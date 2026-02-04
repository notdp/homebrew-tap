class Cliproxyapi < Formula
  desc "CLI Proxy API with credential-master support for multi-instance OAuth token coordination"
  homepage "https://github.com/notdp/CLIProxyAPI"
  version "6.7.20-credential-master"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/notdp/CLIProxyAPI/releases/download/v6.7.20-credential-master/cliproxyapi-darwin-arm64"
      sha256 "8ff427dd13939a961882804cb672a4dfc0430699414f35dee5d043f439c72490"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/notdp/CLIProxyAPI/releases/download/v6.7.20-credential-master/cliproxyapi-linux-amd64"
      sha256 "3fbb38c69bcc6fd04640d33280c68cdee3c5dfca81b61312078696694d52ae63"
    end
  end

  resource "config" do
    url "https://github.com/notdp/CLIProxyAPI/releases/download/v6.7.20-credential-master/config.example.yaml"
    sha256 "304ce36c229f080860e03aa8b1f40338806d84a0983ccc2019cc766de20d2ebb"
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "cliproxyapi-darwin-arm64" => "cliproxyapi"
    elsif OS.linux? && Hardware::CPU.intel?
      bin.install "cliproxyapi-linux-amd64" => "cliproxyapi"
    end

    resource("config").stage do
      etc.install "config.example.yaml" => "cliproxyapi.conf" unless (etc/"cliproxyapi.conf").exist?
    end
  end

  service do
    run [opt_bin/"cliproxyapi", "-config", etc/"cliproxyapi.conf"]
    keep_alive true
  end

  test do
    system "#{bin}/cliproxyapi", "--help"
  end
end
