args @ {...}: {
  nixpkgs = {
    overlays = let
      path = ./overlays;
    in
      with builtins;
        map (n: import (path + ("/" + n)) args)
        (filter (n:
          match ".*\\.nix" n
          != null
          || pathExists (path + ("/" + n + "/default.nix")))
        (attrNames (readDir path)));
  };

  imports = [
    ./modules
  ];
}
