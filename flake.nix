{
    inputs = {
	nixpkgs.url = "github:NixOS/nixpkgs";
	flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
	flake-utils.lib.eachSystem (flake-utils.lib.defaultSystems ++ [flake-utils.lib.system.aarch64-darwin]) (system:
            let pkgs = import nixpkgs { inherit system; };

                ghcPackages = pkgs.haskellPackages.ghcWithPackages (ps: [
		    ps.megaparsec
		    ps.hashable
                ]);

		haskellPackages = pkgs.haskellPackages;

		jailbreakUnbreak = pkg:
		  pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

		# DON'T FORGET TO PUT YOUR PACKAGE NAME HERE, REMOVING `throw`
		packageName = "jhash";
		cabalBuilds = haskellPackages.callCabal2nix packageName self rec {
		    # Dependency overrides go here
		};

            in rec {
		packages.${packageName} = cabalBuilds;
		defaultPackage = cabalBuilds;

		apps.jhash = { type = "app"; program = "${cabalBuilds}/bin/jhash"; };
		apps.default = apps.jhash;

		devShell = pkgs.mkShell {
		    buildInputs = [
                        ghcPackages
		    ];
		    inputsFrom = builtins.attrValues self.packages.${system};
		};
            });
}

