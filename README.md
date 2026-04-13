# Poly-Orchestrator: ECS vs Kubernetes Deployment (Terraform)

A production-style, side-by-side deployment of the same Dockerized "Quote of the Day" API on:
- AWS ECS (Fargate)
- Kubernetes (EKS via Terraform; Minikube optional for local testing)

The system runs at least two instances, self-heals on failure, and auto-scales when CPU exceeds 50%.

## Project Structure
```
poly-orchestrator/
  app/
  kubernetes/
  terraform/
    ecs/
    eks/
    state/
    modules/
      ecs/
      eks/
  README.md
```

## Application Overview
- Node.js Express API
- Endpoint: `GET /quote`
- Port: `3000`
- Health check: `GET /health`

## Architecture (High Level)
- **ECS Fargate**: ALB -> ECS Service -> Tasks (2+)
- **Kubernetes**: Service -> Deployment -> Pods (2+), with HPA

## Prerequisites
- Docker
- Node.js (for local run)
- AWS CLI configured with credentials
- Terraform (>= 1.5)
- kubectl
- EKS requirements (IAM permissions, VPC limits)
- Metrics Server (for Kubernetes HPA)

## Environment File
Create a local `.env` for the app (optional). An example is provided.
```bash
cp .env.example .env
```

## Remote State (S3 Lockfile)
This project uses remote state and S3-native locking for Terraform stacks.

### 1. Bootstrap the State Backend
```bash
cd terraform/state
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```
Take note of the `state_bucket_name` output.

### 2. Configure ECS Backend
```bash
cd terraform/ecs
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
```

### 3. Configure EKS Backend
```bash
cd terraform/eks
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
```

## 1. Build and Run Locally (Optional)
```bash
cd app
npm install
npm start
```
Test:
```bash
curl http://localhost:3000/quote
```

## 2. Build Docker Image
```bash
cd app
docker build -t quote-api:latest .
```
Note: `app/.dockerignore` is included to reduce build context size and avoid leaking local files.

## 3. ECS (Fargate) Deployment with Terraform

### 3.1 Provision Infrastructure
```bash
cd terraform/ecs
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
cp terraform.tfvars.example terraform.tfvars
terraform apply
```
Terraform outputs:
- `ecr_repository_url`
- `alb_dns_name`

### 3.2 Push the Image to ECR
```bash
aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com

docker tag quote-api:latest <ECR_REPOSITORY_URL>:latest

docker push <ECR_REPOSITORY_URL>:latest
```

### 3.3 Verify
```bash
curl http://<ALB_DNS_NAME>/quote
```
If a task stops or fails health checks, ECS replaces it automatically.

### 3.4 Auto Scaling
Auto scaling is configured in Terraform with a CPU target of `50%`, min `2`, max `4`.

## ECS CI/CD (Recommended)
This repo includes a GitHub Actions workflow that builds a Docker image, pushes it to ECR with an immutable tag (the commit SHA), registers a new ECS task definition, and updates the ECS service.

### 1. Create an OIDC Role for GitHub Actions
Create an IAM role that trusts GitHub OIDC and attach a policy with ECS + ECR permissions.

Example trust policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com" },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
        "StringLike": { "token.actions.githubusercontent.com:sub": "repo:<GITHUB_ORG>/<REPO>:ref:refs/heads/main" }
      }
    }
  ]
}
```

Example permissions policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "ecr:DescribeRepositories"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/<ECS_EXECUTION_ROLE>",
        "arn:aws:iam::<ACCOUNT_ID>:role/<ECS_TASK_ROLE>"
      ]
    }
  ]
}
```

### 2. Add GitHub Secrets and Variables
Add this secret:
`AWS_ROLE_ARN` (the role you created above)

Add these repository variables (optional overrides):
`AWS_REGION`, `ECR_REPOSITORY`, `ECS_CLUSTER`, `ECS_SERVICE`, `TASK_DEFINITION_FAMILY`, `CONTAINER_NAME`

Defaults used by the workflow:
- `AWS_REGION=us-east-1`
- `ECR_REPOSITORY=quote-api`
- `ECS_CLUSTER=poly-orchestrator-cluster`
- `ECS_SERVICE=poly-orchestrator-service`
- `TASK_DEFINITION_FAMILY=quote-api`
- `CONTAINER_NAME=quote-api`

### 3. Add GitHub Secrets and Variables (Security Scanning)
The security scan job requires one optional secret:
- `SEMGREP_APP_TOKEN` — only needed if using Semgrep Cloud dashboard. Remove the `env:` block from the workflow if unused.

### 4. Trigger a Deployment
Push to `main` and the workflow in `.github/workflows/ecs-deploy.yml` will deploy automatically.

## ECS CI/CD Security Scanning
The workflow runs a `security-scan` job before every deployment. The `deploy` job is gated on it passing.

| Step | Tool | Fails on |
|---|---|---|
| Dependency scan | `npm audit` | high/critical CVEs |
| Static analysis | Semgrep (`p/default`) | any finding |
| Image scan | Trivy | unfixed critical/high CVEs |

SARIF results from both Semgrep and Trivy are uploaded to the **GitHub Security → Code scanning** tab on every run (including failed runs), so findings are always visible.

The image is built locally inside the `security-scan` job for Trivy to scan — it is only pushed to ECR in the `deploy` job after all scans pass.

## 4. Kubernetes (EKS) Deployment with Terraform

### 4.1 Provision EKS
```bash
cd terraform/eks
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
cp terraform.tfvars.example terraform.tfvars
terraform apply
```

### 4.2 Configure kubectl
```bash
aws eks update-kubeconfig --region <REGION> --name <EKS_CLUSTER_NAME>
```

### 4.3 Install Metrics Server
- EKS: install Metrics Server before enabling HPA

### 4.4 Push Image to ECR (for EKS)
- Reuse the ECS ECR repo or create another repo.
- Update `kubernetes/deployment.yaml` with the full ECR image URI.

### 4.5 Apply Manifests
```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/hpa.yaml
```

### 4.6 Check Pods and Service
```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

### 4.7 Test Self-Healing
```bash
kubectl delete pod -l app=quote-api
kubectl get pods
```

## 5. Load Testing (Trigger Scaling)

### Kubernetes (from a busybox pod)
```bash
kubectl run -it --rm load --image=busybox -- /bin/sh
```
Inside the pod:
```bash
while true; do wget -q -O- http://quote-api/quote > /dev/null; done
```
Check HPA:
```bash
kubectl get hpa
kubectl get pods
```

### ECS (from local machine)
```bash
while true; do curl -s http://<ALB_DNS_NAME>/quote > /dev/null; done
```
Check ECS scaling in the console or via CLI.

## ECS vs Kubernetes: Comparison
- **Operational Model**
  - ECS: AWS-managed control plane, simpler for AWS-native workloads.
  - Kubernetes: portable and flexible, but more operational overhead.
- **Scaling**
  - ECS: Application Auto Scaling integrates with CloudWatch.
  - Kubernetes: HPA uses metrics-server and resource metrics.
- **Networking**
  - ECS: ALB + awsvpc, each task has its own ENI.
  - Kubernetes: Service + Pod networking with CNI.
- **Learning Curve**
  - ECS: easier to get started on AWS.
  - Kubernetes: broader ecosystem but steeper learning curve.

## Observations and Lessons Learned
- Keeping the container image identical ensures a fair comparison.
- Health checks are critical for both self-healing and load balancing.
- Autoscaling requires reliable CPU requests/limits (Kubernetes) and correct CloudWatch metrics (ECS).

## Files Included
- App: `app/package.json`, `app/server.js`, `app/Dockerfile`
- Kubernetes: `kubernetes/deployment.yaml`, `kubernetes/service.yaml`, `kubernetes/hpa.yaml`
- Terraform: `terraform/ecs/*.tf`, `terraform/eks/*.tf`, `terraform/state/*.tf`, `terraform/modules/*`
- CI/CD: `.github/workflows/ecs-deploy.yml`
  - `security-scan` job: npm audit, Semgrep, Trivy (SARIF → GitHub Security tab)
  - `deploy` job: ECR push, ECS task definition update, service rollout
