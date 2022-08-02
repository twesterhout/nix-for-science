{
  description = "A general-purpose library for parallel and massively-parallel computations";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      name = "arrayfire";
      version = "3.8.2";
      project = with pkgs; stdenv.mkDerivation rec {
        inherit name;
        inherit version;

        src = fetchurl {
          url = "https://github.com/arrayfire/arrayfire/releases/download/v${version}/arrayfire-full-${version}.tar.bz2";
          hash = "sha256-LQGzWtreJDMHj1fiIzhEZ5qr/bBqQeaZKmsnxlMC0/4=";
        };

        patches = [ ./no-download-forge.patch ];

        cmakeFlags = [
          "-DAF_BUILD_UNIFIED=ON"
          "-DAF_BUILD_CPU=ON"
          "-DAF_BUILD_CUDA=OFF"
          "-DAF_BUILD_OPENCL=OFF"
          "-DAF_BUILD_DOCS=OFF"
          "-DAF_BUILD_EXAMPLES=OFF"
          "-DBUILD_TESTING=OFF"
          "-DAF_COMPUTE_LIBRARY=FFTW/LAPACK/BLAS"
        ];

        nativeBuildInputs = [ cmake pkg-config ];
        strictDeps = true;
        buildInputs = [
          fftw fftwFloat
          blas lapack
          boost.out boost.dev
        ];

        fixupPhase = ''
          true
        '';

        meta = with lib; {
          description = "A general-purpose library for parallel and massively-parallel computations";
          longDescription = ''
            A general-purpose library that simplifies the process of developing software that targets parallel and massively-parallel architectures including CPUs, GPUs, and other hardware acceleration devices.";
          '';
          license = licenses.bsd3;
          homepage = "https://arrayfire.com/";
        };
      };
    in
      {
        packages.pkg = project;
        defaultPackage = self.packages.${system}.pkg;
        devShell = project;
      });
}
