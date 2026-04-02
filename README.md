# GKE Blue/Green CI/CD (Google-native) — Repo-per-microservice template

This repository is a **complete, ready-to-clone template** for deploying a **single Java microservice** to **GKE** using an **industry-grade CI/CD** pipeline with **blue/green deployments**.

## What you get
- **Simple Spring Boot Java app** (Hello + Actuator health endpoints)
- **Container build** (Docker multi-stage)
- **Kubernetes manifests** implementing **Blue/Green** using **Service selectors** (`active` service + `preview` service)
- **Cloud Build CI pipelines**:
  - PR pipeline: tests + SAST + SCA + secret scanning + K8s policy checks
  - Release pipeline: build image → push to Artifact Registry → **Blue/Green deploy to GKE** (deploy inactive color, smoke test via preview svc, cutover active svc)

## Blue/Green model (how traffic switches)
- Two Deployments exist: `${APP}-blue` and `${APP}-green`
- Two Services exist:
  - `${APP}` (ACTIVE): routes user traffic to the **active color**
  - `${APP}-preview` (PREVIEW): routes smoke-test traffic to the **inactive color**
- The pipeline determines the current active color by reading `${APP}` Service selector and deploys to the **inactive** color.

> This approach relies on Kubernetes **labels/selectors** and the Service selector switch for near-instant cutover and rollback.

## Prerequisites (assumed existing)
- GKE cluster(s) already exist
- Artifact Registry repository already exists
- Cloud Build is enabled
- Cloud Build service account has the required IAM roles:
  - `roles/cloudbuild.builds.editor`
  - `roles/artifactregistry.writer`
  - `roles/container.developer` (or tighter RBAC via GKE RBAC)
  - `roles/container.clusterViewer` (optional)
  - `roles/logging.logWriter`

## Configure Cloud Build triggers (per microservice repo)
Create triggers in Cloud Build:
1. **PR Trigger**
   - Event: Pull request
   - Build config: `cloudbuild/pr.yaml`
2. **Release Trigger**
   - Event: Push to `main` (or your release branch)
   - Build config: `cloudbuild/release-bluegreen.yaml`
   - Substitutions (example):
     - `_SERVICE=sample-api`
     - `_REGION=us-central1`
     - `_AR_REPO=my-ar-repo`
     - `_CLUSTER=dev-gke-cluster`
     - `_CLUSTER_REGION=us-central1`
     - `_NAMESPACE=dev`
     - `_REPLICAS=2`

## First deployment
On first run, the pipeline applies the manifests (namespace + deployments + services). By default, the ACTIVE service points to **blue**.

## Rollback
Rollback is instant (switch service selector back):
```bash
kubectl -n <namespace> patch svc <app> -p '{"spec":{"selector":{"app":"<app>","color":"blue"}}}'
# or "green" depending on which was last stable
```

## Local build/run
```bash
mvn -q clean package
java -jar target/sample-api.jar
curl http://localhost:8080/
curl http://localhost:8080/actuator/health
```

---

## Notes
- The security scanners included are popular open-source options. In a regulated enterprise, you can swap these steps for your org-approved tools.
- The K8s policy checks (OPA/Conftest) are intentionally minimal but enforce common guardrails.
