{ ghc }:

with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d395190b24b27a65588f4539c423d9807ad8d4e7.tar.gz") {});

haskell.lib.buildStackProject {
    inherit ghc;
    name = "my_env";
    buildInputs = with pkgs; [zlib];
}
