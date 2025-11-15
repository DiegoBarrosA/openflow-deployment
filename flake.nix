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

        # Development shell with tools
        devShell = pkgs.mkShell {
          name = "openflow-dev";

          # Build inputs - available in the shell
          buildInputs = with pkgs; [
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

            # AWS tools
            awscli2
            eksctl
          ];

          # Basic environment variables (no scripts)
          shellHook = ''
            echo "� OpenFlow Development Environment"
            echo "==================================="

            # Set Java environment
            export JAVA_HOME="${pkgs.jdk17}"

            echo "🚀 Available tools:"
            echo "  kubectl, oci, mvn, npm, yarn, podman, awscli2, eksctl"
            echo ""
          '';
        };

      in
      {
        # Development shell
        devShells.default = devShell;
      });
}