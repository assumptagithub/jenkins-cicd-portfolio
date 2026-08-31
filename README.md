Munjo Assumpta — DevOps CI/CD Portfolio

Project Overview

This project demonstrates a complete DevOps CI/CD workflow for deploying a containerized personal portfolio website.

The application is a static HTML portfolio website served using NGINX. The project uses Docker for containerization, Jenkins for continuous integration and continuous deployment, and Kubernetes running on Minikube for container orchestration.

The project demonstrates how source code changes can be automatically built, tested, packaged into a Docker image, pushed to Docker Hub, and deployed to a Kubernetes cluster.


Project Objectives

The main objectives of this project are to demonstrate:

* Git and GitHub source-code management
* Docker containerization
* Automated application testing
* Jenkins CI/CD pipeline
* Docker Hub image management
* Kubernetes deployment
* Kubernetes ConfigMaps and Secrets
* Kubernetes rolling updates
* Kubernetes health checks
* Kubernetes Ingress
* Deployment verification
* High availability using multiple replicas


Technologies Used

Technology	Purpose
HTML/CSS	Portfolio website
NGINX	Web server
Git	Version control
GitHub	Source-code repository
Docker	Application containerization
Docker Hub	Container image registry
Jenkins	CI/CD automation
Kubernetes	Container orchestration
Minikube	Local Kubernetes cluster
kubectl	Kubernetes management
ConfigMap	Application configuration
Secret	Sensitive environment variable
Ingress NGINX	HTTP routing
Bash	Automated tests and commands


Project Architecture

The project follows this workflow:

Developer
   |
   | git push
   v
GitHub Repository
   |
   | Jenkins detects/builds project
   v
Jenkins
   |
   +----------------------+
   |                      |
   v                      v
Build Docker Image       Run Tests
   |                      |
   +----------+-----------+
              |
              v
       Docker Hub
              |
              | Pull/Deploy image
              v
       Kubernetes / Minikube
              |
       +------+------+
       |             |
       v             v
   Pod Replica 1  Pod Replica 2
       |             |
       +------+------+
              |
              v
       Kubernetes Service
              |
              v
       NGINX Ingress
              |
              v
munjo-portfolio.local

Application

The portfolio website is a static HTML application served through NGINX.

The Dockerfile uses the lightweight NGINX Alpine image:

FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80

The application is exposed on port 80.


Docker

The application is packaged as a Docker image:

munjo185/munjo-portfolio:<BUILD_NUMBER>

For example:

munjo185/munjo-portfolio:18

Each Jenkins build receives a unique image tag using the Jenkins BUILD_NUMBER.

This prevents every build from using the same image tag and makes it possible to identify which build is deployed.


Automated Tests

The project contains a test.sh script that performs basic application validation.

The Jenkins pipeline executes:

chmod +x test.sh
./test.sh

The tests must pass before the Docker image is pushed and deployed.

Example successful output:

Running portfolio tests...
All portfolio tests passed!


Jenkins CI/CD Pipeline

Jenkins automates the complete CI/CD process.

The pipeline performs the following stages:

1. Checkout source code from GitHub
2. Build the Docker image
3. Run application tests
4. Push the Docker image to Docker Hub
5. Deploy the new image to Kubernetes
6. Wait for the Kubernetes rollout to complete

The Jenkins pipeline is defined in the Jenkinsfile.

Pipeline Flow

GitHub
   ↓
Checkout
   ↓
Build Docker Image
   ↓
Run Tests
   ↓
Push Image to Docker Hub
   ↓
Deploy to Kubernetes
   ↓
Verify Rollout


Jenkins Pipeline Configuration

The deployment stage uses the Kubernetes configuration stored in Jenkins:

export KUBECONFIG=/tmp/minikube-kubeconfig

Jenkins then updates the Kubernetes deployment with the new Docker image:

kubectl set image deployment/munjo-portfolio \
  munjo-portfolio=munjo185/munjo-portfolio:${BUILD_NUMBER}

Finally, Jenkins verifies that Kubernetes successfully completes the deployment:

kubectl rollout status deployment/munjo-portfolio --timeout=120s

A successful deployment produces:

deployment "munjo-portfolio" successfully rolled out


Kubernetes Deployment

The application runs inside a Kubernetes cluster using Minikube.

The Kubernetes Deployment is named:

munjo-portfolio

The application is configured to run 2 replicas:

replicas: 2

This means Kubernetes maintains two running application Pods.

Example:

munjo-portfolio-xxxxx   1/1   Running
munjo-portfolio-yyyyy   1/1   Running

Using two replicas improves availability and allows Kubernetes to perform rolling updates without taking the entire application offline.


Rolling Update Strategy

The deployment uses the Kubernetes RollingUpdate strategy:

strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1

This configuration ensures that Kubernetes keeps the existing Pods available while creating the new version.

The deployment can therefore be updated with minimal interruption.


Kubernetes Health Checks

The application has both liveness and readiness probes.

Liveness Probe

The liveness probe checks whether the application is still running:

HTTP GET /
Port: 80

Readiness Probe

The readiness probe checks whether the application is ready to receive traffic.

These probes help Kubernetes determine whether a Pod should remain in service.


Kubernetes ConfigMap

Application configuration is stored in:

k8s/configmap.yaml

The ConfigMap is named:

munjo-portfolio-config

The application environment is configured through the ConfigMap.

For example:

APP_ENV=development

The Deployment loads this value from the ConfigMap rather than hard-coding it directly into the container.


Kubernetes Secret

Sensitive configuration is stored in a Kubernetes Secret:

munjo-portfolio-secret

The Secret contains:

SITE_API_KEY

The Deployment loads the value from the Kubernetes Secret.

This demonstrates the use of Kubernetes Secrets for sensitive configuration instead of placing sensitive values directly inside the Deployment manifest.

The Secret was verified inside the running container without displaying the actual secret value:

kubectl exec <pod-name> -- sh -c \
'test -n "$SITE_API_KEY" && echo "SITE_API_KEY is set"'

Expected result:

SITE_API_KEY is set


Kubernetes Service

The application is exposed internally through a Kubernetes Service.

The Service forwards traffic to the portfolio Pods running on port 80.

This allows Kubernetes to distribute traffic between the two application replicas.


Kubernetes Ingress

The project uses the NGINX Ingress Controller.

The Ingress resource is:

munjo-portfolio

The configured hostname is:

munjo-portfolio.local

Traffic follows this path:

Browser
   ↓
munjo-portfolio.local
   ↓
NGINX Ingress
   ↓
Kubernetes Service
   ↓
Portfolio Pods

The Ingress was verified using:

kubectl get ingress

Example:

NAME              CLASS   HOSTS                   ADDRESS
munjo-portfolio   nginx   munjo-portfolio.local   192.168.49.2


Local Access

Because this project uses Minikube, the application is available locally.

The hostname:

munjo-portfolio.local

is mapped to the Minikube IP through the local /etc/hosts file.

Example:

192.168.49.2 munjo-portfolio.local

The application can then be accessed locally at:

http://munjo-portfolio.local

This is a local development/demo URL, not a publicly hosted production URL.


Deployment Verification

Several Kubernetes commands were used to verify the deployment.

Check Pods

kubectl get pods

The expected result is two healthy running Pods:

READY   STATUS
1/1     Running
1/1     Running

Check Deployment

kubectl get deployment munjo-portfolio

Expected:

READY   UP-TO-DATE   AVAILABLE
2/2     2            2

Check the Deployed Image

kubectl get deployment munjo-portfolio \
-o jsonpath='{.spec.template.spec.containers[0].image}'; echo

Example:

munjo185/munjo-portfolio:18

Check Pod Images

kubectl get pods \
-o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image

This confirms that the running Pods use the expected Docker image.

Verify Rollout

kubectl rollout status deployment/munjo-portfolio

Expected:

deployment "munjo-portfolio" successfully rolled out


Deployment Testing

The deployed website was tested through the Kubernetes Ingress using:

curl -s http://munjo-portfolio.local

Specific content was also verified using:

curl -s http://munjo-portfolio.local | grep -F "DevOps Engineer"

The website returned the expected portfolio content.


Jenkins and Kubernetes Integration

Jenkins runs inside a Docker container.

The Jenkins container has access to Docker through the Docker socket:

/var/run/docker.sock

Jenkins also has the Kubernetes command-line tool:

kubectl version --client

The Kubernetes cluster configuration is provided to Jenkins through:

/tmp/minikube-kubeconfig

Jenkins uses this configuration to communicate with the Minikube Kubernetes cluster.

The connection was successfully verified from inside Jenkins:

KUBECONFIG=/tmp/minikube-kubeconfig kubectl get nodes

Result:

NAME       STATUS   ROLES
minikube   Ready    control-plane

Jenkins was also able to verify the application deployment and Pods from inside the Jenkins container.


Repository Structure

jenkins-cicd-portfolio/
│
├── index.html
├── Dockerfile
├── Jenkinsfile
├── test.sh
├── README.md
│
└── k8s/
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    └── ingress.yaml



Complete CI/CD Process

The final workflow of the project is:

Step 1 — Developer makes a change

The portfolio source code is updated locally.

Step 2 — Code is pushed to GitHub

git add .
git commit -m "Update portfolio"
git push origin main

Step 3 — Jenkins checks out the repository

Jenkins retrieves the latest source code from GitHub.

Step 4 — Docker image is built

docker build -t munjo185/munjo-portfolio:${BUILD_NUMBER} .

Step 5 — Tests are executed

./test.sh

The pipeline continues only if the tests pass.

Step 6 — Image is pushed to Docker Hub

docker push munjo185/munjo-portfolio:${BUILD_NUMBER}

Step 7 — Kubernetes deployment is updated

kubectl set image deployment/munjo-portfolio \
munjo-portfolio=munjo185/munjo-portfolio:${BUILD_NUMBER}

Step 8 — Kubernetes performs a rolling update

Kubernetes creates the new Pod and gradually replaces the old version.

Step 9 — Jenkins verifies the rollout

kubectl rollout status deployment/munjo-portfolio

Step 10 — Application is available through Ingress

http://munjo-portfolio.local


Key DevOps Concepts Demonstrated

This project demonstrates practical knowledge of:

* Version control with Git
* GitHub repository management
* Docker image creation
* Docker image versioning
* Docker Hub
* Automated testing
* Jenkins pipelines
* CI/CD automation
* Jenkins credentials
* Kubernetes Deployments
* Kubernetes Services
* Kubernetes Pods
* Kubernetes ConfigMaps
* Kubernetes Secrets
* Kubernetes health probes
* Kubernetes rolling updates
* Kubernetes replicas
* Kubernetes Ingress
* Minikube
* kubectl
* Containerized application deployment
* Deployment verification


Project Result

The final project successfully demonstrates a working local CI/CD pipeline:

GitHub
  ↓
Jenkins
  ↓
Docker Build
  ↓
Automated Tests
  ↓
Docker Hub
  ↓
Kubernetes / Minikube
  ↓
Rolling Deployment
  ↓
NGINX Ingress
  ↓
Portfolio Website

The application was successfully deployed with 2 Kubernetes replicas, and Jenkins successfully automated the Docker build, testing, Docker Hub push, and Kubernetes deployment process.


Repository

GitHub Repository:

https://github.com/assumptagithub/jenkins-cicd-portfolio


Local Live Application

The application is available locally through the Minikube Ingress at:

http://munjo-portfolio.local

Note: This URL is intentionally a local URL because the Kubernetes environment is running on Minikube on the development machine. It is not publicly accessible from the internet.


Author

Munjo Assumpta

DevOps Engineer


