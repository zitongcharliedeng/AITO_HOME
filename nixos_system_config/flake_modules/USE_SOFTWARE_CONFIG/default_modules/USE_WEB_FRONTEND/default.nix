{ pkgs, ... }:

let
  aitoFrontendPage = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html>
    <head>
      <title>AITO - Digital Assistant</title>
      <style>
        body { font-family: sans-serif; background: #1a1a2e; color: #eee; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .container { text-align: center; }
        h1 { font-size: 4rem; margin-bottom: 0.5rem; }
        p { color: #888; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>AITO</h1>
        <p>Your Digital Assistant</p>
        <p>Web interface coming soon...</p>
      </div>
    </body>
    </html>
  '';
in
{
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      listen = [{ addr = "0.0.0.0"; port = 8080; }];
      root = aitoFrontendPage;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
