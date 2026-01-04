# worker-build Nix Flake

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/sagikazarmark/worker-build/ci.yaml?style=flat-square)

Packaged [worker-build](https://github.com/cloudflare/workers-rs/tree/main/worker-build) from the Cloudflare [workers-rs](https://github.com/cloudflare/workers-rs) project in a Nix flake.

## Why?

`worker-build` is a tool used as a custom build command for Cloudflare Workers `workers-rs` projects. While `nixpkgs` includes the `worker-build` package, there are a few issues:

- The `nixpkgs` version doesn't bundle `wasm-bindgen-cli` and `wasm-opt` (binaryen), which are required dependencies for building workers-rs projects. (This could potentially be fixed upstream.)
- The `binaryen` (`wasm-opt`) package is not cached for Darwin platforms, resulting in long build times on macOS.

> [!NOTE]
> `worker-build` downloads `wasm-bindgen-cli` and `wasm-opt` (binaryen) when not found, but that isn't the nix way.

This flake provides a pre-configured `worker-build` package with all necessary dependencies bundled and cached for all supported platforms.

## Usage

Add this flake to your inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    worker-build = {
      url = "github:sagikazarmark/worker-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, worker-build }: {
    # Use worker-build.packages.${system}.default in your outputs
  };
}
```

### Using the Binary Cache

To avoid building `worker-build` and its dependencies (especially `binaryen` on Darwin), you can use the Cachix binary cache:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    worker-build = {
      url = "github:sagikazarmark/worker-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, worker-build }: {
    # Configure the binary cache
    nixConfig = {
      extra-substituters = [ "https://worker-build.cachix.org" ];
      extra-trusted-public-keys = [ "worker-build.cachix.org-1:CqMeH3Zil7P0EPsGgmZsuoUcz2zBCTSDWIT+6dGp7/Y=" ];
    };

    # Use worker-build.packages.${system}.default in your outputs
  };
}
```

Alternatively, you can configure the cache globally in your Nix configuration:

```nix
nix.settings = {
  substituters = [ "https://worker-build.cachix.org" ];
  trusted-public-keys = [ "worker-build.cachix.org-1:CqMeH3Zil7P0EPsGgmZsuoUcz2zBCTSDWIT+6dGp7/Y=" ];
};
```

## Supported Platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## License

The project is licensed under the [MIT License](LICENSE).
