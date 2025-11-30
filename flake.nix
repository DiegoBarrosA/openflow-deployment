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

          # Basic environment variables and deploy script
          shellHook = ''
            echo "� OpenFlow Development Environment"
            echo "==================================="

            # Set Java environment
            export JAVA_HOME="${pkgs.jdk17}"

            echo "🚀 Available tools:"
            echo "  kubectl, oci, mvn, npm, yarn, podman, awscli2, eksctl"
            echo ""

            # Deploy script for secret provisioning and deployment
            export DEPLOY_SCRIPT="deploy-openflow"
            cat > $DEPLOY_SCRIPT <<'EOF'
#!/usr/bin/env bash
set -e
echo "Creating oracle-wallet-secret from wallet files..."
kubectl create secret generic oracle-wallet-secret \
  --from-file=wallet/cwallet.sso \
  --from-file=wallet/ewallet.p12 \
  --from-file=wallet/ewallet.pem \
  --from-file=wallet/keystore.jks \
  --from-file=wallet/ojdbc.properties \
  --from-file=wallet/sqlnet.ora \
  --from-file=wallet/tnsnames.ora \
  --from-file=wallet/truststore.jks --dry-run=client -o yaml | kubectl apply -f -
echo "Applying kube.yaml manifest..."
kubectl apply -f kube.yaml
echo "Deployment complete."
EOF
            chmod +x $DEPLOY_SCRIPT
            echo "Run './deploy-openflow' to provision secrets and deploy."
          '';
        };

      in
      {
        # Development shell
        devShells.default = devShell;
      });
}