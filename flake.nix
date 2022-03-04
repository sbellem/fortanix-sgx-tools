{
  description = ''
    Tools for building and running enclaves for the Fortanix SGX ABI.";
    This contains `ftxsgx-runner` to run generic `x86_64-fortanix-unknown-sgx`
    enclaves, as well as `ftxsgx-elf2sgxs`, which is used in the build process
    for the `x86_64-fortanix-unknown-sgx` target.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        nativeBuildInputs = with pkgs; [
          clang_11
          llvmPackages_11.libclang.lib
          pkg-config
          protobuf
          rust-bin.nightly."2021-11-04".default
        ];

        buildInputs = with pkgs; [
          openssl.dev
        ];
      in
      with pkgs;
      {
        defaultPackage = rustPlatform.buildRustPackage rec {
          inherit buildInputs nativeBuildInputs;
          pname = "fortanix-sgx-tools";
          version = "0.5.0";

          src = fetchCrate {
            inherit pname version;
            sha256 = "sha256-npG6s9HQuBtMRTB7f3aD1hCV9lEr5JriGsYWArg3yfA=";
          };

          cargoSha256 = "sha256-t+ASUOQZpG+O/plldyA8EcCslcRHvwPZZzyIgP2vr8g=";
        };

        devShell = mkShell {
          inherit nativeBuildInputs;
          buildInputs = [
            openssl.dev
            # for dev purposes
            exa
            unixtools.whereis
            which
          ];
          shellHook = ''
            alias ls=exa
            alias find=fd

            export RUST_BACKTRACE=1
          '';
        };
      }
    );
}
