{
  description = "pw quick dev environments"; # for when i'm too lazy to setup a custom flake.nix
  #nixConfig.bash-prompt = ''\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \[\033[00m\](\[\033[01;31m\]\[pwdev\]\[\033[00m\])\$ '';
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
      python312Env = pkgs.python312.withPackages (ps:
        with ps; [
          accelerate
          datasets
          debugpy
          einops
          evaluate
          future
          ipykernel
          ipython
          nltk
          numpy
          openai
          optimum
          pandas
          pip
          portalocker
          pyarrow
          python-dotenv
          pytorch
          rouge-score
          sacrebleu
          scipy
          sentence-transformers
          setuptools
          sympy
          tenacity
          tokenizers
          torch
          pkgs.mpi
          transformers
        ]);
    in rec {
      # nix develop .#rust
      devShells.rust = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            openssl
            pkg-config
            cargo-watch
            cargo-bundle
            cargo-tauri
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
            darwin.cctools
          ]);
        shellHook = ''
          echo "You're using the Rust default environment"
          export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \[\033[00m\](\[\033[01;31m\]\[pwdev-rust\]\[\033[00m\])\$ "
        '';
      };
      # nix develop .#ts24
      devShells.ts24 = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            nodejs_24
            autoconf
            mozjpeg
            libtool
            automake
            nasm
            libpng
            optipng
            pkg-config
            gcc
            pnpm
            bun
            (yarn.override {nodejs = nodejs_24;})
            nodePackages.typescript
            nodePackages.typescript-language-server
            nodePackages.diagnostic-languageserver
            nodePackages.eslint_d
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            darwin.cctools
          ]);
        shellHook = ''
          echo "You're using the TypeScript on Node 24 default environment"
          export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \[\033[00m\](\[\033[01;31m\]\[pwdev-ts\]\[\033[00m\])\$ "
        '';
      };
      # nix develop .#ts
      devShells.ts = devShells.ts24;

      devShells.python312 = pkgs.mkShell {
        buildInputs = with pkgs; [
          libffi
          python312Env
        ];

        shellHook = ''
          export PIP_PREFIX=$(pwd)/_build/pip_packages #Dir where built packages are stored
          export PYTHONPATH="$PIP_PREFIX/${python312Env.sitePackages}:$PYTHONPATH"
          echo "home = $PIP_PREFIX/${python312Env.sitePackages}" > pyvenv.cfg
          echo "include-system-site-packages = false" >> pyvenv.cfg
          export PATH="$PIP_PREFIX/bin:$PATH"
          export JUPYTER_CONFIG_DIR="$PIP_PREFIX/jupyter"
          export PYTHONPATH="$PYTHONPATH:$(pwd)"
          unset SOURCE_DATE_EPOCH
          export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \[\033[00m\](\[\033[01;31m\]\[pwdev-python\]\[\033[00m\])\$ "
          echo "You're using the Python 3.12 default environment"
        '';
      };
      devShells.python = devShells.python312;
      devShells.all = pkgs.mkShell {
        buildInputs = devShells.ts.buildInputs ++ devShells.rust.buildInputs ++ devShells.python.buildInputs;
        shellHook =
          devShells.ts.shellHook
          + devShells.rust.shellHook
          + devShells.python.shellHook
          + ''
            export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \[\033[00m\](\[\033[01;31m\]\[pwdev-all\]\[\033[00m\])\$ "
          '';
      };
    });
}
