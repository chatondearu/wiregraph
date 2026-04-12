{
  description = "wiregraph — Tauri 2 + Vue 3 PipeWire graph UI (dev shell + package)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./default.nix { };
          wiregraph = pkgs.callPackage ./default.nix { };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          gstPluginPath = pkgs.lib.makeSearchPath "lib/gstreamer-1.0" (
            with pkgs.gst_all_1; [
              gst-plugins-base
              gst-plugins-good
            ]
          );
        in
        {
          default = pkgs.mkShell {
            # Match default.nix build/runtime deps so `cargo tauri dev` links and WebKit loads GStreamer plugins.
            buildInputs = with pkgs; [
              gtk3
              webkitgtk_4_1
              libsoup_3
              openssl
            ];

            nativeBuildInputs = with pkgs; [
              rustc
              cargo
              clippy
              rustfmt
              rust-analyzer
              cargo-tauri
              pkg-config
              nodejs
            ];

            env.OPENSSL_NO_VENDOR = "1";

            shellHook = ''
              export GST_PLUGIN_SYSTEM_PATH_1_0="${gstPluginPath}"
              export PATH="${pkgs.lib.makeBinPath [ pkgs.pipewire pkgs.alsa-utils ]}''${PATH:+:$PATH}"
              echo "wiregraph dev shell (Rust + Node + Tauri / WebKitGTK)"
              echo "  deps:    npm install"
              echo "  app:     cd src-tauri && cargo tauri dev"
              echo "  web:     npm run dev   # if you only hack the Vite UI"
              echo "  release: nix build .#wiregraph"
            '';
          };
        }
      );
    };
}
