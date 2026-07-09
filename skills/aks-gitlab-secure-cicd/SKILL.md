---
name: aks-gitlab-secure-cicd
description: 'Design and operate production-grade Azure Kubernetes Service (AKS) deployments with Docker, GitLab CI/CD or Azure DevOps pipelines, ACR, Key Vault, Application Insights and Monitor, secure container practices, and OWASP-aligned deployment hygiene. USE WHEN: containerize an app, write a Dockerfile, build a secure CI/CD pipeline, deploy to AKS, harden Kubernetes manifests or Helm charts, add image scanning or rollback, or integrate ACR, Key Vault, and Monitor. DO NOT USE FOR: application code design (use production-grade-engineering or fastapi-production-grade); Azure infrastructure unrelated to container delivery.'
argument-hint: 'Describe the app, container image, AKS target, GitLab or Azure DevOps pipeline needs, Azure services involved, and security or compliance requirements.'
user-invocable: true
disable-model-invocation: false
---

# AKS, Docker, GitLab, Azure DevOps, and Azure Ecosystem Secure CI/CD Workflow

## When to Use
- Deploy applications to Azure Kubernetes Service (AKS).
- Containerize applications with Docker using production-ready practices.
- Build secure GitLab CI/CD or Azure DevOps pipelines for build, test, image publishing, and deployment.
- Integrate Azure ecosystem services such as Azure Container Registry (ACR), Key Vault, Application Insights, Log Analytics, Azure Monitor, and Azure Service Bus.
- Apply OWASP and platform hardening guidance for Kubernetes, containers, and Azure-hosted delivery.

## Core Objective
Deliver secure, repeatable, and production-ready cloud deployments using Docker, AKS, GitLab, Azure DevOps, and the Azure ecosystem.

## Workflow

### 1. Define the deployment target and constraints
Start by identifying:
1. The application runtime and language.
2. The AKS cluster topology, namespace, and environment strategy.
3. The container image requirements and registry target.
4. The deployment promotion path across dev, test, and production.
5. Security, compliance, and access requirements.

Decision point:
- If the workload is public-facing, prioritize ingress, secrets handling, network policies, and image security.
- If the workload is internal, focus on reliability, observability, and operational simplicity.

### 2. Build production-ready container images
Use Docker best practices:
- Use a small, secure base image.
- Build in a multi-stage pipeline when possible.
- Run containers as a non-root user.
- Pin image versions and dependencies for reproducibility.
- Remove build tools and unnecessary packages from the final image.
- Use `.dockerignore` to reduce context size and exposure.

Decision point:
- If the image is security-sensitive, scan it for vulnerabilities before promotion.
- If the image is large or frequently rebuilt, optimize the layer structure and caching strategy.

### 3. Prepare AKS deployment assets
Define Kubernetes manifests or Helm charts for:
- Deployments and services.
- ConfigMaps and Secrets.
- Ingress or Gateway resources.
- HorizontalPodAutoscaler, probes, and resource limits.
- Namespace isolation and labels.

Recommended practices:
- Keep manifests declarative and environment-aware.
- Use resource requests and limits to avoid noisy-neighbor issues.
- Configure readiness and liveness probes for safe rollout behavior.
- Include annotations for monitoring, tracing, and operational tooling.

Decision point:
- If the environment is multi-stage, use separate namespaces or release names to isolate deployments.
- If the workload requires advanced traffic routing, prefer ingress or service mesh options that fit the platform.

### 4. Secure the deployment path
Apply secure-by-default deployment practices:
- Store secrets in Azure Key Vault or Kubernetes secret management, not in source code.
- Use least-privilege service accounts and RBAC.
- Restrict ingress and egress with network policies.
- Enable TLS for public endpoints.
- Use image scanning, provenance, and trusted registries.
- Validate manifests and avoid privileged containers unless absolutely required.

OWASP-aligned checks:
- Prevent injection and unsafe configuration through strict validation.
- Avoid exposed debug endpoints and unnecessary administrative permissions.
- Ensure secure defaults for authentication, secrets, and transport.

### 5. Design CI/CD for reliable delivery
Create a delivery pipeline that supports:
1. Build and test on every commit.
2. Container image build and vulnerability scan.
3. Promotion to a staging or test environment.
4. Approval and deployment to production AKS.
5. Post-deployment verification and rollback readiness.

Choose the delivery platform based on team needs:
- Use GitLab CI/CD when the organization wants Git-native pipelines, reusable templates, and strong release traceability.
- Use Azure DevOps Pipelines when the team needs Azure-native integration, approvals, environments, and tight Azure service integration.
- Use both when there are hybrid governance or migration requirements between platforms.

Suggested stages:
- `lint` and `test`
- `build-image`
- `security-scan`
- `deploy-staging`
- `approve-production`
- `deploy-production`

Decision point:
- If the team needs strong release control, add manual approval before production deployment.
- If the environment changes frequently, add canary or blue/green rollout strategies to reduce risk.

### 6. Use platform variables and Azure ecosystem controls
Keep pipeline configuration robust:
- Store registry credentials, Azure credentials, and environment values in GitLab CI/CD variables, Azure DevOps variable groups, or secret stores such as Azure Key Vault.
- Use environment-specific variables to avoid accidental cross-environment promotion.
- Tag images with immutable versions and commit metadata.
- Reuse pipeline templates for consistency across services.
- Integrate Azure components such as ACR, Key Vault, Application Insights, and Monitor for deployment and operational visibility.

Decision point:
- If the team manages many services, standardize the pipeline template and release workflow to reduce drift.
- If the environment is highly regulated, add audit logging and approval evidence to the deployment flow.

### 7. Verify deployment health and rollback readiness
After deployment, confirm:
- Pods are healthy and ready.
- Ingress and service endpoints respond as expected.
- Logs and metrics are available for troubleshooting.
- Rollback steps are documented and executable.

Decision point:
- If health checks fail, block promotion and investigate before proceeding.
- If the deployment is stable, keep the previous image version available for rapid rollback.

## Anti-Patterns to Avoid
- Running containers as root, using `latest` tags, or shipping build tools in the final image.
- Baking secrets or credentials into images, manifests, or pipeline YAML instead of Key Vault/secret stores.
- Deploying without resource requests/limits, readiness/liveness probes, or network policies.
- Skipping image vulnerability scans before promotion to production.
- Promoting straight to production with no staging, approval gate, or rollback path.
- Granting broad cluster roles instead of least-privilege RBAC and scoped service accounts.
- Reusing the same variables across environments, risking accidental cross-environment promotion.

## Decision Guide
- The application needs Kubernetes orchestration, scaling, and production-grade platform services.
- The team wants managed control-plane operations with Azure integration.

### Use Docker when
- The workload needs portability, repeatable builds, and consistent runtime packaging.
- The deployment target is container-based and should be easy to promote across environments.

### Use GitLab CI/CD when
- The team wants Git-native, codified release pipelines with approvals and environment promotion.
- The organization needs strong build-test-deploy traceability.

### Use Azure DevOps when
- The team needs Azure-native pipelines, service connections, environments, approvals, and release governance.
- The deployment workflow must align with Azure ecosystem tooling and existing Azure DevOps repos.

### Use Azure ecosystem services when
- The workload needs ACR for image storage, Key Vault for secrets, Application Insights or Azure Monitor for observability, and Azure networking or messaging integration.
- The platform must support centralized security, diagnostics, and operations across multiple services.

### Use OWASP security practices when
- The workload is internet-facing or handles sensitive data.
- The deployment path includes secrets, networking, or privileged operations.

## Quality Criteria
A production-ready AKS, GitLab, Azure DevOps, and Azure ecosystem deployment should:
- Use secure, minimal container images.
- Apply AKS hardening and least-privilege access controls.
- Run repeatable, reviewable CI/CD pipelines across GitLab or Azure DevOps.
- Integrate Azure services such as ACR, Key Vault, Monitor, and Application Insights appropriately.
- Support safe promotion, rollback, and verification.
- Follow OWASP-aligned secure deployment practices.

## Output Expectations
When used, this skill should help produce:
- A secure Docker and AKS deployment plan.
- A GitLab or Azure DevOps CI/CD pipeline design for build, scan, and deploy.
- An Azure ecosystem integration plan using ACR, Key Vault, Monitor, and related services.
- A checklist for secure deployment hygiene and production readiness.
- A rollout and rollback strategy for AKS environments.

## Example Prompts to Try
- Design a secure GitLab or Azure DevOps pipeline for deploying a Dockerized app to AKS.
- Harden this Docker image and AKS manifest set for production use.
- Create an OWASP-aligned deployment workflow for GitLab, Azure DevOps, and Kubernetes.
- Add staging and production promotion with rollback controls for AKS.
- Integrate Azure Container Registry, Key Vault, and Application Insights into the deployment flow.
