{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
        luvit-nix.url = "github:aiverson/luvit-nix";
    };

    outputs = {self, nixpkgs, luvit-nix}:
    let
        forEachSystem systems: callback: nixpkgs.lib.genAttrs systems (system:
            callback system nixpkgs.legacyPackages.${system});
        
        defaultSystems = ["aarch64-darwin" "x86_64-linux"];
    in
    {
        devShells = forEachSystem defaultSystems (system: pkgs: 
        let
            luvitPkgs = luvit-nix.packages.${system};
        in
        {
            default = pkgs.mkShell {
                packages = [
                    luvitPkgs.luvit
                    luvitPkgs.luvi
                    luvitPkgs.lit
                ];
            }
        })
    }
}