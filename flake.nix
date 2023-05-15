{
  description = "pw quick dev environments"; # for when i'm too lazy to setup a custom flake.nix
  nixConfig.bash-prompt = ''\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \[\033[00m\](\[\033[01;31m\]\[pwdev\]\[\033[00m\])\$ '';
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    #rust-overlay,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      #overlays = [(import rust-overlay)];
      #pkgs = import nixpkgs {inherit system overlays;};
      pkgs = import nixpkgs {inherit system;};
    in rec {
      # nix develop .#rust
      devShells.rust = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            openssl
            pkg-config
            cargo-watch
            cargo-bundle
            #rust-bin.stable.latest.default
            curl
            libiconv
            rustc
            cargo
            gcc
            clang
            llvmPackages.bintools
            rustfmt
            clippy
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            darwin.apple_sdk.frameworks.Security
            darwin.cctools
          ]);
        shellHook = ''
          echo "You're using the Rust default environment"
        '';
      };
      # nix develop .#ts18
      devShells.ts18 = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            nodejs-18_x
            autoconf
            mozjpeg
            libtool
            automake
            nasm
            libpng
            optipng
            pkg-config
            gcc
            dpkg
            (yarn.override {nodejs = nodejs-18_x;})
            nodePackages.typescript
            nodePackages.typescript-language-server
            nodePackages.diagnostic-languageserver
            nodePackages.eslint_d
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            darwin.apple_sdk.frameworks.Security
            darwin.cctools
          ]);
        shellHook = ''
          echo "You're using the TypeScript on Node 18 default environment"
        '';
      };
      # nix develop .#ts
      devShells.ts = devShells.ts18;
    });
}
