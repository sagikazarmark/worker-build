{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  wasm-bindgen-cli,
  binaryen,
}:

rustPlatform.buildRustPackage rec {
  pname = "worker-build";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "workers-rs";
    tag = "v${version}";
    hash = "sha256-qhqMGvjVFgTmYXXrsMF5pJJebARXPqD7q/KmUtG0zqQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-YJHcziwrdK0mlmGS46IYIwVfy/DCsKgCB3/aq14brt4=";

  buildAndTestSubdir = "worker-build";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/worker-build \
      --set WASM_BINDGEN_BIN ${wasm-bindgen-cli}/bin/wasm-bindgen \
      --set WASM_OPT_BIN ${binaryen}/bin/wasm-opt \
      --prefix PATH : ${
        lib.makeBinPath [
          wasm-bindgen-cli
          binaryen
        ]
      }
  '';

  meta = {
    description = "Tool to be used as a custom build command for a Cloudflare Workers `workers-rs` project";
    mainProgram = "worker-build";
    homepage = "https://github.com/cloudflare/workers-rs";
    license = with lib.licenses; [ asl20 ];
  };
}
