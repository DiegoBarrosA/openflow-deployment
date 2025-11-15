{
  description = "OpenFlow - Oracle Autonomous Database Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Oracle Instant Client - for development and testing
        oracle-instantclient = pkgs.stdenv.mkDerivation {
          name = "oracle-instantclient";
          src = pkgs.fetchurl {
            url = "https://download.oracle.com/otn_software/linux/instantclient/1923000/instantclient-basic-linux.x64-19.23.0.0.0dbru.zip";
            sha256 = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; # Replace with actual hash
          };
          buildInputs = [ pkgs.unzip ];
          installPhase = ''
            mkdir -p $out
            cp -r * $out/
          '';
        };

        # Development shell with Oracle tools
        devShell = pkgs.mkShell {
          name = "openflow-oracle-dev";

          # Build inputs - available in the shell
          buildInputs = with pkgs; [
            # Oracle tools
            oracle-instantclient

            # Database tools
            sqlplus
            oracle-instantclient

            # Development tools
            git
            jq
            yq
            openssl
            curl
            wget

            # Kubernetes tools (for deployment)
            kubectl
            kubernetes-helm

            # OCI CLI
            oci-cli

            # Java development (for the backend)
            jdk17
            maven

            # Node.js (for frontend)
            nodejs
            yarn

            # Container tools
            podman
            docker-compose
            aws-cli
            eksctl
          ];

          # Basic environment variables (no scripts)
          shellHook = ''
            echo "🔐 OpenFlow Oracle ADB Development Environment"
            echo "=============================================="

            # Set Oracle environment variables
            export ORACLE_HOME="${oracle-instantclient}"
            export LD_LIBRARY_PATH="${oracle-instantclient}:$LD_LIBRARY_PATH"
            export PATH="${oracle-instantclient}:$PATH"

            # Set Java environment
            export JAVA_HOME="${pkgs.jdk17}"

            # Wallet directory (will be created if it doesn't exist)
            export TNS_ADMIN="$PWD/wallet"

            echo "📁 Wallet directory: $TNS_ADMIN"
            echo "🔑 Place your Oracle wallet files here"
            echo ""
            echo "🚀 Available tools:"
            echo "  sqlplus, oci, kubectl, mvn, npm, yarn, podman, aws-cli, eksctl"
            echo ""
          '';
        };

      in
      {
        # Development shell
        devShells.default = devShell;

        # Packages (for CI/CD)
        packages = {
          oracle-tools = pkgs.symlinkJoin {
            name = "oracle-tools";
            paths = [ oracle-instantclient ];
          };
        };
      });
}