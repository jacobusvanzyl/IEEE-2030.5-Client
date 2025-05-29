{ nixpkgs ? import <nixpkgs> {} }:
let

patchshebangs = import (builtins.fetchGit {
    url = "git@github.com:alrunner4/patchshebangs";
    ref = "main";
    rev = "5e7d9bfbe3fccd45dfee03c0a0af6844de16949c";
}) { inherit nixpkgs; };

SRC = "${./.}";

in
derivation {
    name = "ieee-2030.5-client";
    system = builtins.currentSystem;
    inherit SRC;
    builder = nixpkgs.writeShellScript "ieee-2030.5-client-builder" ''
        set -ex
        PATH+=:${nixpkgs.coreutils}/bin

        cp -r $SRC $TMP
        WORKDIR=$TMP/$(basename $SRC)
        cd $WORKDIR
        chmod -R +w .
        ${patchshebangs.default}/bin/patchshebangs ./build.sh
        chmod +x ./build.sh

        PATH+=:${nixpkgs.openssl_1_1}/bin
        PATH+=:${nixpkgs.gcc}/bin
        export C_INCLUDE_PATH+=:${nixpkgs.openssl_1_1.dev}/include
        export LIBRARY_PATH+=:${nixpkgs.openssl_1_1.out}/lib
        $WORKDIR/build.sh

        cp -r $WORKDIR/build $out
        '';
}
