# CredPal DevOps Assessment Application

This is a Node.js application designed to demonstrate a production-ready DevOps pipeline. It includes infrastructure provisioning with Terraform, containerization with Docker, and a CI/CD pipeline using GitHub Actions and AWS CodeDeploy.

## How to Run the Application Locally

### Prerequisites
- Node.js (v18+)
- Docker & Docker Compose
- PostgreSQL (if running without Docker Compose)

### Option 1: Using Docker Compose (Recommended)
This will start both the application and a local PostgreSQL database.

1.  **Configure Environment**
    Copy the example environment file:
    ```bash
    cp .env.example .env
    ```

2.  **Start Application**
    ```bash
    docker-compose up --build
    ```

The application will be available at `http://localhost:3000`.

### Option 2: Using Node.js directly
1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Set Environment Variables**
   Ensure you have a PostgreSQL instance running and set the `DATABASE_URL` environment variable.
   ```bash
   export PORT=3000
   export DATABASE_URL=postgresql://user:password@localhost:5432/dbname
   ```

3. **Start the Server**
   ```bash
   npm start
   ```

---

## Running Tests

The application includes a suite of integration tests using **Jest** and **Supertest** to ensure endpoint reliability.

### Run Tests Manually
```bash
npm test
```

This will:
1.  Start the application in test mode.
2.  Run integration tests against mocked endpoints.
3.  Report pass/fail status.

### CI Integration
Tests are automatically run on every pull request and push to main via GitHub Actions. Deployment to production only proceeds if all tests pass.

---

## Accessing the Application

Once running, the application exposes the following endpoints on port **3000**:

- **GET /health**
  - Health check endpoint.
  - Response: `{ "status": "healthy" }`
  
- **GET /status**
  - Application status key metrics.
  - Response: `{ "status": "running", "uptime": <seconds>, "timestamp": <date> }`

- **POST /process**
  - Simulates data processing.
  - Body: JSON object
  - Response: `{ "message": "Data processed successfully", "receivedData": ... }`

---

## How to Deploy the Application

The deployment is fully automated via GitHub Actions and AWS CodeDeploy.

### Workflow Overview
1.  **CI (Build & Test)**: On every push to `main`, the code is tested and dependencies are installed.
2.  **Container Build**: The Docker image is built and pushed to **Amazon Elastic Container Registry (ECR)**.
3.  **Deployment**: 
    - Deployment artifacts (`appspec.yml`, scripts) are uploaded to S3.
    - AWS CodeDeploy triggers a deployment to the **Auto Scaling Group**.
    - The deployment scripts pull the new Docker image from ECR and restart the container on the EC2 instances.

### Infrastructure Provisioning
Infrastructure is managed via **Terraform** in the `terraform/` directory.

To apply infrastructure changes:
```bash
cd terraform
terraform init
terraform apply
```

This provisions:
- VPC & Networking (Public/Private Subnets, Internet Gateway)
- Application Load Balancer (ALB)
- EC2 Auto Scaling Group with specific IAM roles
- ECR Repository & S3 Buckets for artifacts

---

## Key Architectural Decisions

### 1. Security
- **OIDC Authentication**: Used OpenID Connect (OIDC) for GitHub Actions to authenticate with AWS, eliminating the need for long-lived access keys.
- **Non-Root Container User**: The `Dockerfile` creates and switches to a non-root user (`appuser`) to practice least privilege.
- **Security Groups**: Granular security groups ensure minimal exposure. EC2 instances only accept traffic from the Load Balancer.
- **IAM Roles**: Instance profiles and service roles are scoped to necessary permissions (e.g., S3 read access, ECR pull access).

### 2. CI/CD Strategy
- **Zero-Downtime Deployment**: Utilized AWS CodeDeploy with a Rolling deployment strategy to ensure the application remains available during updates.
- **Immutable Artifacts**: Docker images are tagged with the Git SHA, ensuring specific versions are trackable and immutable.
- **Separation of Concerns**: CI (building/testing) is separated from CD (provisioning/deploying).

### 3. Infrastructure
- **Modular Terraform**: The infrastructure is broken down into reusable modules (`vpc`, `ec2`, `alb`, etc.) for maintainability and clarity.
- **High Availability**: deployed across multiple Availability Zones (us-east-1a, us-east-1b) with an Auto Scaling Group to handle load and provide redundancy.
