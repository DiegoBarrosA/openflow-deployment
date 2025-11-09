# Installation Guide

## Prerequisites

### Required Software
- **Podman**: Container runtime (rootless)
- **Git**: Version control (optional)

### System Requirements
- **Operating System**: Linux (recommended), macOS, or Windows with WSL2
- **Memory**: Minimum 2GB RAM
- **Disk Space**: ~2GB for images and containers
- **Network**: Internet access for pulling base images

## Installation Steps

### Step 1: Install Podman

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install podman

# Fedora
sudo dnf install podman

# Arch Linux
sudo pacman -S podman
```

#### macOS
```bash
brew install podman
podman machine init
podman machine start
```

### Step 2: Clone Deployment Repository

```bash
git clone https://github.com/DiegoBarrosA/openflow-deployment.git
cd openflow-deployment
```

### Step 3: Build Backend Image

```bash
cd ../openflow-backend
podman build -t openflow-backend:latest .
```

### Step 4: Build Frontend Image

```bash
cd ../openflow-frontend
podman build -t openflow-frontend:latest .
```

### Step 5: Create Network

```bash
podman network create openflow-network
```

### Step 6: Deploy Stack

```bash
cd openflow-deployment
podman play kube --network openflow-network --publish 8080:8080 --publish 3000:3000 kube.yaml
```

## Verification

### Check Pod Status
```bash
podman pod ps
```

### Check Container Status
```bash
podman ps
```

### Test Backend
```bash
curl http://localhost:8080/api/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Test Frontend
```bash
curl http://localhost:3000
```

### View Logs
```bash
# Backend logs
podman logs openflow-backend

# Frontend logs
podman logs openflow-frontend

# All pod logs
podman pod logs openflow
```

## Configuration

### Environment Variables

Edit `kube.yaml` to modify environment variables:

```yaml
env:
  - name: SPRING_DATASOURCE_URL
    value: "jdbc:h2:mem:openflowdb"
  - name: JWT_SECRET
    value: "your-secret-key"
  - name: CORS_ALLOWED_ORIGINS
    value: "http://localhost:3000"
```

### Port Configuration

Modify port mappings in `podman play kube` command:
```bash
podman play kube --publish 8081:8080 --publish 3001:3000 kube.yaml
```

### Resource Limits

Modify in `kube.yaml`:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

## Troubleshooting

### Pod Won't Start
```bash
# Check pod status
podman pod ps -a

# Inspect pod
podman pod inspect openflow

# Check logs
podman pod logs openflow
```

### Containers Not Communicating
```bash
# Verify network
podman network inspect openflow-network

# Check container network
podman inspect openflow-backend | grep NetworkMode
```

### Port Conflicts
```bash
# Find process using port
lsof -i :8080
lsof -i :3000

# Use different ports
podman play kube --publish 8081:8080 --publish 3001:3000 kube.yaml
```

### Image Not Found
```bash
# List images
podman images

# Rebuild if needed
cd ../openflow-backend && podman build -t openflow-backend:latest .
cd ../openflow-frontend && podman build -t openflow-frontend:latest .
```

## Cleanup

### Stop and Remove Pod
```bash
podman pod stop openflow
podman pod rm openflow
```

### Remove Network
```bash
podman network rm openflow-network
```

### Remove Images (Optional)
```bash
podman rmi openflow-backend:latest
podman rmi openflow-frontend:latest
```

## Production Deployment

### Considerations
- Use persistent database (PostgreSQL/MySQL)
- Set secure JWT secret
- Configure proper CORS origins
- Set up monitoring and logging
- Configure backup strategy
- Use secrets management
- Enable HTTPS/TLS

### Production kube.yaml Example
```yaml
# Use production database
env:
  - name: SPRING_DATASOURCE_URL
    value: "jdbc:postgresql://db-host:5432/openflow"
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: jwt-secret
        key: secret
```




