{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
        luvit-nix.url = "github:aiverson/luvit-nix";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = {self, nixpkgs, luvit-nix, flake-utils}:
        flake-utils.lib.eachDefaultSystem (system:
        let 
            pkgs = import nixpkgs { inherit system; };
            luvitPkgs = luvit-nix.packages.${system};
        in
        {
            devShells = {
                default = pkgs.mkShell {
                    packages = [
                        luvitPkgs.luvit
                        luvitPkgs.luvi
                        luvitPkgs.lit
                    ];
                };
            };
        });
}