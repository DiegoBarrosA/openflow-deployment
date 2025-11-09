# OpenFlow Deployment Overview

## Project Summary

OpenFlow Deployment repository contains orchestration configurations and deployment documentation for integrating the OpenFlow backend and frontend services. It provides a unified deployment strategy using Podman and Kubernetes-compatible YAML.

## Goals

- Provide container orchestration configuration
- Document integration between backend and frontend
- Enable easy deployment of the complete stack
- Support CI/CD deployment workflows
- Maintain deployment best practices

## Key Features

### Container Orchestration
- Podman play kube configuration
- Service definitions
- Resource limits and requests
- Environment variable management

### Integration
- Network configuration
- Service discovery
- Port mapping
- Health checks

### Deployment
- Single-command deployment
- Environment-specific configurations
- Production-ready setup
- Documentation for operations

## Components

### Backend Service
- Spring Boot application
- Port 8080
- H2 database (development)
- JWT authentication

### Frontend Service
- React application served by Nginx
- Port 3000
- API proxy configuration
- Static file serving

### Network
- Podman network for service communication
- Internal service discovery
- External port exposure

## Technology Stack

- **Podman**: Container runtime
- **Kubernetes YAML**: Orchestration format
- **Nginx**: Frontend web server
- **H2/PostgreSQL**: Database options




