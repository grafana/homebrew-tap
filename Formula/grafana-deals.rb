class GrafanaDeals < Formula
  desc "iDotMatrix 64x64 LED display client for Grafana deal celebrations"
  homepage "https://github.com/grafana/deal-celebration-display"
  head "https://github.com/grafana/deal-celebration-display.git", branch: "main"

  depends_on "python@3.11"
  depends_on "portaudio"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    ["bleak", "Pillow", "SpeechRecognition", "pyaudio"].each do |pkg|
      venv.pip_install pkg
    end

    libexec.install "deal_display.py"
    libexec.install "PressStart2P-Regular.ttf" if (buildpath/"PressStart2P-Regular.ttf").exist?

    (bin/"grafana-deals").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/python3" "#{libexec}/deal_display.py" "$@"
    EOS
    chmod 0755, bin/"grafana-deals"
  end

  def post_install
    system bin/"grafana-deals", "--bootstrap"
  rescue StandardError
    # bootstrap needs a token - user will run --set-token first
  end

  def caveats
    <<~EOS
      Run `grafana-deals --set-token` to add your GitHub token (skip if you use gh CLI).
      Then run `grafana-deals --demo` to test your display.

      To start automatically at login:
        brew services start grafana/tap/grafana-deals
    EOS
  end
end
