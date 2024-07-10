{
  description = "Minimal configuration to install specific versions of R, Python, Julia, and Go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # Current stable release
  };


  outputs = { self, nixpkgs }: let

    # Define the system architectures as a set
    systems = {
      x86_64-linux = "x86_64-linux";
      aarch64-linux = "aarch64-linux";
      aarch64-darwin = "aarch64-darwin";
      x86_64-darwin = "x86_64-darwin";
    };

    pkgsFor = system: import nixpkgs { inherit system; };

  in
  {
    # Define packages for each system

    packages = builtins.mapAttrs (system: _ : let
      pkgs = pkgsFor systems.${system};
    in {
      default = pkgs.buildEnv {
        name = "global-packages";
        paths = with pkgs; [

          R
          python312Packages.radian

          python312
          julia-bin
          go

        ];
      };
    }) systems;

    # Define development shells for each system
    devShells = builtins.mapAttrs (system: _ : let
      pkgs = pkgsFor systems.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [

          R
          python312Packages.radian
          python312
          julia-bin
          go

        ];

        # Optional: Set environment variables or run commands on shell start
        shellHook = ''
          echo "Welcome to the development shell for ${systems.${system}}"
          export PROJECT_VAR="some_value"
        '';
      };
    }) systems;
  };
}

