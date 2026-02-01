# Peermetrics on Kubernetes

This directory contains Kubernetes manifests for running Peermetrics on a generic Kubernetes cluster using Kustomize overlays.

## Layout

- `k8s/base`: generic, reusable manifests
- `k8s/overlays/example`: example overlay with placeholder values
- `k8s/scripts`: helper scripts for secrets and Postgres image build/push

## What gets deployed

- `api` (Django) on port 8081
- `web` (Django) on port 8080
- `postgres` (StatefulSet) with `pg_trgm` enabled (custom image)
- `redis` (Deployment) with append-only persistence
- `Ingress` for `/api` and `/` routing
- `Job` to run database migrations and collect static assets

Static assets are served by Django for now (no shared volume or external CDN yet).

## Infrastructure requirements

- **Kubernetes**: 1.24+ recommended.
- **Ingress controller**: AWS Load Balancer Controller (ALB Ingress) or another controller. The provided manifests use ALB annotations.
- **Persistent storage**:
  - Postgres: ReadWriteOnce PVC (20Gi+), e.g. EBS gp3.
  - Redis: ReadWriteOnce PVC (10Gi+), e.g. EBS gp3.
- **Compute**:
  - Start with 2–3 general-purpose nodes (e.g., 2 vCPU / 4–8Gi each) and scale as needed.
  - Optional: isolate DB/Redis on a dedicated node group.
- **TLS termination**:
  - Ingress or external edge (CloudFront/ALB) should terminate TLS.
- **Secrets management**:
  - Provide a secure secret store (Kubernetes Secrets, or external secret operator).

## Images

- `peermetrics/api:latest`
- `peermetrics/web:latest`
- **Custom Postgres image** (required to enable `pg_trgm`):
  - Build from `Dockerfile.postgres` and push to your registry.
  - Update the overlay `images` section with your registry URL.

## Kustomize workflow

Create a local overlay by copying the example:

```sh
cp -R k8s/overlays/example k8s/overlays/your-env
```

Update `k8s/overlays/your-env/kustomization.yaml` with:
- host/domain values
- `API_ROOT`
- image references
- `URL_PREFIX` for the web app (only when deploying under a subpath like `/peermetrics`)

Create secrets:

```sh
cp k8s/overlays/your-env/secrets.env.example k8s/overlays/your-env/secrets.env
k8s/scripts/generate_secrets_env.sh --output k8s/overlays/your-env/secrets.env
```

Apply:

```sh
kubectl apply -k k8s/overlays/your-env
```

## Scripts

- `k8s/scripts/build_push_image.sh`: build/push images to ECR (web or postgres)
- `k8s/scripts/generate_secrets_env.sh`: generate `secrets.env`

## CloudFront path-based routing (agnostic guidance)

You can front the Ingress with CloudFront and route `/peermetrics` traffic to the cluster. Two common approaches:

### Option A: Rewrite at the edge (recommended with ALB)

- CloudFront behavior: `Path pattern` = `/peermetrics/*`
- Origin: ALB/Ingress endpoint
- Use a CloudFront Function or Lambda@Edge (viewer request) to strip the `/peermetrics` prefix before forwarding to ALB.
- Ingress only needs `/api/*` and `/` style paths, but ALB does not support server-side path rewrites.

### Option B: Rewrite inside the cluster (use NGINX Ingress)

- CloudFront behavior: `Path pattern` = `/peermetrics/*`
- Origin: NGINX Ingress endpoint
- Ingress can rewrite `/peermetrics/api` -> `/api` and `/peermetrics` -> `/` using annotations

### Notes

- Ensure your `API_ROOT` matches the external URL (e.g., `https://your-cloudfront-domain/peermetrics/api/v1`).
- If you want this pattern to be reusable across projects, keep `/peermetrics` as a behavior-specific path and strip it at the edge.
- ALB can route by path but cannot rewrite it. If you need rewrites, use NGINX Ingress or an edge function.
- If your API only serves `/v1`, keep the ingress path at `/v1` or strip `/api` at the edge so the app still sees `/v1`.

## Operational notes

- The migration Job runs once. Re-run it when you roll out schema changes.
- Default admin credentials should be changed before first production launch.
- For scale, increase replicas of `api` and `web` independently.
