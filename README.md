# OpenFlow Deployment

Container orchestration and deployment configuration for the OpenFlow project management application.

## Quick Start

### Prerequisites

- Podman installed
- Backend and frontend images built

### Deploy Stack

```bash
# Deploy using Kubernetes YAML (exposes services on host ports 8080 and 3000)
podman play kube kube.yaml
```

## Documentation

Comprehensive documentation is available in the `/docs` directory:

- [Overview](docs/overview.md) - Project summary and goals
- [Architecture](docs/architecture.md) - Deployment architecture
- [Installation](docs/installation.md) - Setup instructions
- [Integration](docs/integration.md) - Integration guide for backend and frontend
- [Workflows](docs/workflows.md) - Deployment workflows

## Components

- **Backend**: Spring Boot API service (port 8080)
- **Frontend**: React application served by Nginx (port 3000)
- **Network**: Podman network for service communication

## Access

- Frontend: http://localhost:3000
- Backend API: http://localhost:8080/api
- H2 Console: http://localhost:8080/h2-console

## Integration

This repository integrates:

- [openflow-backend](https://github.com/DiegoBarrosA/openflow-backend)
- [openflow-frontend](https://github.com/DiegoBarrosA/openflow-frontend)

See [Integration Guide](docs/integration.md) for details.

## License

[Add license information]




