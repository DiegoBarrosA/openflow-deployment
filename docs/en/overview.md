# OpenFlow Deployment Overview

## Project Summary

OpenFlow Deployment repository contains Kubernetes orchestration configurations and CI/CD pipelines for deploying the OpenFlow kanban board application to AWS EKS (Elastic Kubernetes Service). The deployment integrates Spring Boot backend and React frontend services with Oracle Autonomous Database.

## Architecture

### Deployment Model

OpenFlow uses a cloud-native microservices architecture deployed on AWS EKS:

```
┌─────────────────────────────────────────────────┐
│              AWS EKS Cluster                    │
│                                                 │
│  ┌──────────────┐      ┌──────────────┐       │
│  │   Frontend   │      │   Backend    │       │
│  │   (Nginx)    │──────│ (Spring Boot)│       │
│  │   Port 80    │      │  Port 8080   │       │
│  └──────┬───────┘      └──────┬───────┘       │
│         │                      │                │
│         │                      │                │
│  ┌──────▼──────────────────────▼──────┐        │
│  │   AWS LoadBalancer (ELB)            │        │
│  └─────────────────────────────────────┘        │
└─────────────────────────────────────────────────┘
         │                      │
         │                      │
         ▼                      ▼
   Internet Users        Oracle Autonomous
                         Database (Cloud)
```

### Components

#### Backend Service
- **Technology**: Spring Boot 3.2.0, Java 17
- **Port**: 8080
- **Database**: Oracle Autonomous Database
- **Authentication**: JWT-based
- **Container Registry**: GitHub Container Registry (GHCR)

#### Frontend Service
- **Technology**: React 18, Vite, Tailwind CSS
- **Web Server**: Nginx (Alpine)
- **Port**: 80
- **API Proxy**: Routes `/api/*` to backend service
- **Container Registry**: GitHub Container Registry (GHCR)

#### Infrastructure
- **Orchestration**: Kubernetes (EKS)
- **Container Registry**: GitHub Container Registry
- **CI/CD**: GitHub Actions
- **Load Balancing**: AWS Application Load Balancer
- **Secrets Management**: Kubernetes Secrets (from GitHub Secrets)

## Goals

- Provide production-ready Kubernetes deployment configuration
- Enable automated CI/CD via GitHub Actions
- Integrate with Oracle Autonomous Database
- Support scalable, cloud-native architecture
- Maintain security best practices

## Key Features

### Container Orchestration
- Kubernetes Deployment manifests
- Service definitions with LoadBalancer type
- Resource limits and requests
- Environment variable management
- Secret management

### CI/CD Integration
- Automated deployment on code push
- GitHub Actions workflows
- Image building and pushing to GHCR
- Kubernetes secret creation from GitHub Secrets
- Rollout status monitoring

### Database Integration
- Oracle Autonomous Database connection
- Wallet-based authentication
- TNS configuration
- Secure credential management

### Security
- Kubernetes Secrets for sensitive data
- GitHub Secrets for CI/CD
- Image pull secrets for GHCR
- Wallet file encryption

## Technology Stack

- **Orchestration**: Kubernetes (AWS EKS)
- **Container Runtime**: Docker (via EKS)
- **CI/CD**: GitHub Actions
- **Container Registry**: GitHub Container Registry (GHCR)
- **Load Balancing**: AWS Application Load Balancer
- **Database**: Oracle Autonomous Database
- **Frontend Web Server**: Nginx
- **Backend Framework**: Spring Boot

## Deployment Flow

1. **Code Push** → GitHub repository
2. **GitHub Actions** → Builds container images
3. **GHCR** → Images pushed to registry
4. **Deployment Workflow** → Triggered (manual or automatic)
5. **Kubernetes Secrets** → Created from GitHub Secrets
6. **Deployments** → Applied to EKS cluster
7. **LoadBalancers** → Provisioned by AWS
8. **Application** → Available via LoadBalancer URLs

## Repository Structure

```
openflow-deployment/
├── .github/
│   └── workflows/
│       └── deploy-on-image-update.yml  # Main deployment workflow
├── docs/
│   ├── installation.md                 # EKS deployment guide
│   ├── github-secrets-setup.md         # Secrets configuration
│   ├── architecture.md                  # Architecture details
│   └── workflows.md                     # Workflow documentation
├── kube.yaml                           # Kubernetes manifests
├── setup-aws-eks.sh                    # Optional EKS setup script
├── encode-wallet.sh                    # Wallet encoding utility
└── README.md                           # Main documentation
```

## Environment Configuration

### Staging Environment
- Default environment for testing
- Same configuration as production
- Can be used for pre-production validation

### Production Environment
- Production-ready configuration
- Requires explicit selection in workflow
- Should use production database credentials

## Monitoring and Operations

### Health Checks
- Kubernetes liveness and readiness probes (can be added)
- Application health endpoints
- Service status monitoring

### Logging
- Container logs via `kubectl logs`
- Application logs in container stdout/stderr
- Can be integrated with CloudWatch Logs

### Scaling
- Horizontal Pod Autoscaling (can be configured)
- Manual scaling via `kubectl scale`
- Resource limits prevent resource exhaustion

## Security Considerations

- Secrets stored in Kubernetes Secrets (not in code)
- GitHub Secrets for CI/CD credentials
- Wallet files encrypted and stored securely
- CORS configuration for API access control
- Image pull secrets for private registry access

## Cost Optimization

- Free-tier EKS node (t3.micro, 750 hours/month)
- Oracle Autonomous Database Always Free tier
- GitHub Container Registry free tier
- AWS LoadBalancer (12 months free for new accounts)

## Next Steps

- Review [Installation Guide](installation.md) for deployment steps
- See [GitHub Secrets Setup](github-secrets-setup.md) for configuration
- Check [Architecture Documentation](architecture.md) for detailed design
- Read [Workflow Documentation](workflows.md) for CI/CD details
