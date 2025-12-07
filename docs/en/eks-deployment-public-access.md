# OpenFlow EKS Deployment & Public Access Documentation

## 1. Cluster Setup

- **Amazon EKS cluster**: `openflow-cluster` in VPC `vpc-0841edd1c8ff87fb7`
- **Kubernetes version**: 1.34
- **Node group**: Managed by EKS, running your workloads.

## 2. Application Deployment

- **Backend**: Spring Boot app, exposed on port 8080.
- **Frontend**: Nginx serving your React/Vite app, exposed on port 3000.

### Deployment YAML (`kube.yaml`)

- Two `Deployment` resources: `openflow-backend` and `openflow-frontend`.
- Each deployment uses a container image from GitHub Container Registry (GHCR).
- Environment variables and secrets are configured for database and JWT.

## 3. Service Exposure

- **Kubernetes Services** of type `LoadBalancer` created for both backend and frontend.
- **Initial Issue**: Services provisioned **internal-only** AWS Network Load Balancers (NLBs), not accessible from the public internet.

## 4. Troubleshooting & Fixes

### Pod Port Mismatch

- Frontend pod was listening on port 3000, but service was forwarding to port 80.
- Fixed by updating the service to use `targetPort: 3000`.

### Security Groups

- Ensured EKS node security group allowed inbound traffic on ports 80 and 8080 from `0.0.0.0/0`.

### Load Balancer Scheme

- Added annotation to both services:
  ```yaml
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  ```
- This requests **public-facing** NLBs from AWS.

## 5. How Public Access Works

- After applying the annotation, AWS provisions new NLBs with public DNS names.
- The `EXTERNAL-IP` field in `kubectl get svc` will show the public DNS.
- Traffic from the internet to the ELB/NLB on port 80 (frontend) or 8080 (backend) is routed to your pods.

## 6. Testing

- **Local testing**: Use `kubectl port-forward` to access services via `localhost`.
- **Public testing**: Use the public DNS name from `kubectl get svc` or AWS Console.
  - Example:  
    - Frontend: `http://<public-elb-dns>`
    - Backend: `http://<public-elb-dns>:8080`
- If the service is not reachable, check:
  - ELB health check status in AWS Console.
  - Pod logs for errors.
  - Security group rules.

## 7. Key YAML Snippets

**Frontend Service Example:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: openflow-frontend
  labels:
    app: openflow-frontend
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
spec:
  selector:
    app: openflow-frontend
  ports:
    - name: http
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

**Backend Service Example:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: openflow-backend
  labels:
    app: openflow-backend
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
spec:
  selector:
    app: openflow-backend
  ports:
    - name: http
      port: 8080
      targetPort: 8080
  type: LoadBalancer
```

## 8. Summary of Steps to Expose Services Publicly

1. Ensure pods are running and listening on the correct ports.
2. Update service YAMLs to match pod ports.
3. Add the `internet-facing` annotation for public AWS NLBs.
4. Apply changes and wait for new public DNS names.
5. Test access via browser or `curl`.

---

**For further troubleshooting:**
- Check ELB health check status in AWS Console.
- Ensure security groups allow inbound traffic on required ports.
- Confirm pods are healthy and listening on the expected addresses.