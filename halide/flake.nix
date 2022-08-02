{
  description = "C++ based language for image processing and computational photography";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      llvmPackages = pkgs.llvmPackages_14;
      project =
        llvmPackages.stdenv.mkDerivation rec {

        pname = "halide";
        version = "14.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "halide";
          repo = "Halide";
          rev = "v${version}";
          hash = "sha256-/7U2TBcpSAKeEyWncAbtW6Vk/cP+rp1CXtbIjvQMmZA=";
        };

        # clang fails to compile intermediate code because
        # of unused "--gcc-toolchain" option
        postPatch = ''
          sed -i "s/-Werror//" src/CMakeLists.txt
        '';

        fixupPhase = ''
          true
        '';

        cmakeFlags = [
          "-DWARNINGS_AS_ERRORS=OFF"
          "-DWITH_PYTHON_BINDINGS=OFF"
          "-DTARGET_WEBASSEMBLY=OFF"
        ];

        # Note: only openblas and not atlas part of this Nix expression
        # see pkgs/development/libraries/science/math/liblapack/3.5.0.nix
        # to get a hint howto setup atlas instead of openblas
        buildInputs = [
          llvmPackages.llvm
          llvmPackages.lld
          llvmPackages.openmp
          llvmPackages.libclang
        ];

        nativeBuildInputs = [ pkgs.cmake ];

        meta = with pkgs.lib; {
          description = "C++ based language for image processing and computational photography";
          homepage = "https://halide-lang.org";
          license = licenses.mit;
          platforms = platforms.all;
          maintainers = [ maintainers.ck3d ];
        };
      };
    in
      {
        packages.pkg = project;
        defaultPackage = self.packages.${system}.pkg;
        devShell = project;
      });
}
