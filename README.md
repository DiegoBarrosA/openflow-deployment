# OpenFlow

A modern, cloud-native project management application inspired by Trello, built with microservices architecture and deployed on AWS EKS with GitHub Container Registry.

## 🏗️ Architecture

OpenFlow consists of three main components:

- **Backend** (`openflow-backend/`): Spring Boot REST API with Oracle Autonomous Database
- **Frontend** (`openflow-frontend/`): React SPA with modern UI
- **Deployment** (`openflow-deployment/`): Kubernetes manifests and CI/CD pipelines

## 🚀 Quick Start

### Prerequisites

- **AWS Account** with EKS permissions
- **Oracle Cloud Account** with Autonomous Database
- **GitHub Repository** with Actions enabled
- **AWS CLI** and **eksctl** installed

### 1. Set Up AWS EKS Cluster

```bash
./setup-aws-eks.sh
```

This creates a free-tier EKS cluster with 1 t3.micro node.

### 2. Configure Oracle Autonomous Database

1. Create an Oracle Autonomous Database instance
2. Download the wallet files
3. Encode wallet files for GitHub Secrets:

```bash
./encode-wallet.sh
```

### 3. Configure GitHub Secrets

Add these secrets to your GitHub repository:

**AWS Credentials:**

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Oracle Database:**

- `ORACLE_DB_USERNAME`
- `ORACLE_DB_PASSWORD`
- `ORACLE_DB_URL`

**Application:**

- `JWT_SECRET`

**Oracle Wallet (Base64 encoded):**

- `ORACLE_WALLET_CWALLET`
- `ORACLE_WALLET_EWALLET`
- `ORACLE_WALLET_KEYSTORE`
- `ORACLE_WALLET_OJDBC`
- `ORACLE_WALLET_SQLNET`
- `ORACLE_WALLET_TNSNAMES`
- `ORACLE_WALLET_TRUSTSTORE`

### 4. Deploy

Push to GitHub or manually trigger the deployment workflow:

```bash
git add .
git commit -m "Deploy to AWS EKS"
git push origin main
```

The GitHub Actions workflow will automatically build and deploy to EKS.

## 📁 Project Structure

```
openflow/
├── openflow-backend/          # Spring Boot API
│   ├── src/main/java/com/openflow/
│   ├── src/main/resources/
│   ├── Dockerfile
│   └── pom.xml
├── openflow-frontend/         # React Frontend
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── openflow-deployment/       # Kubernetes & CI/CD
│   ├── kube.yaml
│   └── .github/workflows/
├── setup-aws-eks.sh          # EKS cluster setup
├── encode-wallet.sh          # Wallet encoding utility
└── README.md
```

## 🛠️ Development

### Local Development Environment

Use Nix for reproducible development:

```bash
# Install Nix (if not already installed)
curl -L https://nixos.org/nix/install | sh

# Enter development environment
cd openflow-backend
nix develop

# Run the application
mvn spring-boot:run
```

### Local Database Setup

For local development, you can use H2 (in-memory) or set up a local Oracle database.

## 📚 Documentation

Each component has comprehensive documentation:

- [Backend Documentation](openflow-backend/docs/)
- [Frontend Documentation](openflow-frontend/docs/)
- [Deployment Documentation](openflow-deployment/docs/)

## 🔧 Technology Stack

- **Backend**: Java 17, Spring Boot 3.2.0, Oracle Autonomous Database
- **Frontend**: React, Vite, Tailwind CSS
- **Infrastructure**: AWS EKS, Kubernetes, GitHub Actions
- **Container Registry**: GitHub Container Registry (GHCR)
- **Development**: Nix Flakes, Maven, npm

## 🌟 Features

- JWT-based authentication
- Real-time board management
- Drag-and-drop task organization
- Configurable status columns
- User isolation and security
- Cloud-native deployment
- CI/CD automation

## 📋 API

- **Base URL**: `http://<eks-service-url>/api`
- **Documentation**: See [API Docs](openflow-backend/docs/api.md)

Default users:

- `admin` / `admin123`
- `demo` / `demo123`

## 💰 Cost Optimization

**AWS Free Tier:**

- ✅ 750 hours t3.micro EC2 instances (EKS nodes)
- ✅ Basic load balancing (12 months free)
- ✅ AWS Secrets Manager (30-day trial)

**GitHub Free Tier:**

- ✅ Unlimited public packages
- ✅ 5GB private packages
- ✅ 10GB/month bandwidth

**Oracle ADB:**

- ✅ Always Free tier (2GB storage, basic performance)

**Estimated Monthly Cost:** $0-15 (data transfer + Oracle ADB usage)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## 📄 License

[Add license information]

---

**Need help?** Check the documentation in each component's `docs/` directory.
