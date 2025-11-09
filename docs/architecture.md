# Deployment Architecture

## File Structure

```
openflow-deployment/
├── kube.yaml              # Podman play kube configuration
├── docs/                  # Deployment documentation
│   ├── overview.md
│   ├── architecture.md
│   ├── installation.md
│   ├── integration.md
│   └── workflows.md
└── README.md
```

## Deployment Architecture

```mermaid
graph TB
    subgraph "Host Machine"
        subgraph "Podman Network: openflow-network"
            subgraph "Pod: openflow"
                BE[Backend Container<br/>Port 8080]
                FE[Frontend Container<br/>Port 3000]
            end
        end
    end
    
    User -->|:3000| FE
    FE -->|/api| BE
    BE -->|JDBC| DB[(H2 Database)]
    
    Ext[External Services] -->|:8080| BE
```

## Service Configuration

### Backend Service

**Container**: `openflow-backend:latest`
**Port**: 8080
**Environment Variables**:
- `SPRING_DATASOURCE_URL`: Database connection string
- `JWT_SECRET`: Secret key for JWT tokens
- `CORS_ALLOWED_ORIGINS`: Allowed CORS origins

**Resources**:
- Requests: 512Mi memory, 250m CPU
- Limits: 1Gi memory, 500m CPU

### Frontend Service

**Container**: `openflow-frontend:latest`
**Port**: 3000
**Environment Variables**:
- `VITE_API_BASE_URL`: Backend API base URL

**Resources**:
- Requests: 128Mi memory, 100m CPU
- Limits: 256Mi memory, 200m CPU

## Network Architecture

```mermaid
graph LR
    subgraph "External"
        Browser[Browser]
    end
    
    subgraph "Podman Network"
        FE[Frontend:3000]
        BE[Backend:8080]
    end
    
    Browser -->|http://localhost:3000| FE
    FE -->|http://openflow-backend:8080/api| BE
```

## Service Discovery

- Services communicate via container names
- Backend accessible as `openflow-backend` within network
- Frontend accessible as `openflow-frontend` within network
- External access via host ports

## Port Mapping

| Service | Container Port | Host Port | Protocol |
|---------|---------------|-----------|----------|
| Backend | 8080 | 8080 | HTTP |
| Frontend | 3000 | 3000 | HTTP |

## Resource Management

### Memory Limits
- Backend: 1Gi maximum
- Frontend: 256Mi maximum
- Total: ~1.25Gi per pod

### CPU Limits
- Backend: 500m (0.5 CPU cores)
- Frontend: 200m (0.2 CPU cores)
- Total: ~0.7 CPU cores per pod

## Deployment Flow

```mermaid
sequenceDiagram
    participant D as Developer
    participant P as Podman
    participant BE as Backend
    participant FE as Frontend
    
    D->>P: Build backend image
    P->>BE: Create image
    D->>P: Build frontend image
    P->>FE: Create image
    D->>P: Create network
    P->>P: Network created
    D->>P: podman play kube
    P->>BE: Start container
    P->>FE: Start container
    BE-->>P: Ready
    FE-->>P: Ready
    P-->>D: Deployment complete
```




