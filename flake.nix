{
  description = "Tool to be used as a custom build command for a Cloudflare Workers `workers-rs` project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        perSystem =
          { pkgs, ... }:
          rec {
            packages = rec {
              worker-build = pkgs.callPackage ./pkgs/worker-build.nix { };

              default = worker-build;
            };

            checks = packages;
          };
      }
    );
}
