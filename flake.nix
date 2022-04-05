{
  description = "A very basic flake";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/release-21.11;
  inputs.cargo2nix.url = github:cargo2nix/cargo2nix;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.rust-overlay.url = github:oxalica/rust-overlay;
  outputs = { self, nixpkgs, cargo2nix, flake-utils, rust-overlay }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        overlays = [cargo2nix.overlay.${system} rust-overlay.overlay];
        inherit system;};

      rustPkgs = pkgs.rustBuilder.makePackageSet' {
        rustChannel = "1.59.0";
        packageFun = import ./Cargo.nix;
      };
    in
      {
        defaultPackage = (rustPkgs.workspace.circom {}).bin;
        devShell = pkgs.mkShell {
          buildInputs = [cargo2nix.defaultPackage.${system}];
        };
      }
  );
}
