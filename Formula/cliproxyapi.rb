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

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "cliproxyapi-darwin-arm64" => "cliproxyapi"
    elsif OS.linux? && Hardware::CPU.intel?
      bin.install "cliproxyapi-linux-amd64" => "cliproxyapi"
    end

    # 创建默认配置文件
    (etc/"cliproxyapi.conf").write default_config unless (etc/"cliproxyapi.conf").exist?
  end

  def default_config
    <<~YAML
      host: ""
      port: 8317
      remote-management:
        allow-remote: false
        secret-key: ""
      auth-dir: "#{var}/cliproxyapi/auths"
      api-keys:
        - changeme
      debug: false
      logging-to-file: true
      proxy-url: ""
      request-retry: 3
      # credential-master: "http://master-ip:8888"
    YAML
  end

  def post_install
    (var/"cliproxyapi/auths").mkpath
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"cliproxyapi", "-c", etc/"cliproxyapi.conf"]
    keep_alive true
    log_path var/"log/cliproxyapi.log"
    error_log_path var/"log/cliproxyapi.log"
    working_dir var/"cliproxyapi"
  end

  def caveats
    <<~EOS
      配置文件: #{etc}/cliproxyapi.conf
      Auth 目录: #{var}/cliproxyapi/auths
      日志文件: #{var}/log/cliproxyapi.log

      Credential-master 配置 (follower):
        credential-master: "http://master-ip:8888"
        remote-management:
          secret-key: "<与 master 相同的 hash>"

      启动: brew services start cliproxyapi
      停止: brew services stop cliproxyapi
    EOS
  end

  test do
    assert_match "CLIProxyAPI", shell_output("#{bin}/cliproxyapi --version 2>&1", 0)
  end
end
