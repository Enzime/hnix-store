{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, nixpkgs, systems, ... }: {
    overlays.default = final: prev: {
      haskellPackages = prev.haskellPackages.override (old: {
        overrides = prev.lib.composeManyExtensions [
          (old.overrides or (_: _: { }))
          (import ./overlay.nix prev null)
        ];
      });
    };

    packages = nixpkgs.lib.genAttrs (import systems) (system: let
      pkgs = (import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      });
    in {
      inherit (pkgs.haskellPackages)
        hnix-store-core
        hnix-store-db
        hnix-store-json
        hnix-store-nar
        hnix-store-readonly
        hnix-store-remote
        hnix-store-tests;
    });
  };
}
