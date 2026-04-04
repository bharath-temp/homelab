# Homelab

GitOps-managed homelab for a k0s Kubernetes cluster, organized as a small internal platform.

The repo is split into:

- `bootstrap/` for node provisioning and cluster bootstrap
- `platform/` for shared capabilities like storage, ingress, auth, and databases
- `apps/` for workloads that consume those capabilities
- `clusters/` for Flux composition that decides what each cluster runs

Start here:

- [docs/homelab-platform-architecture.md](/Users/bharathpadmaraju/projects/homelab/docs/homelab-platform-architecture.md)
- [platform/README.md](/Users/bharathpadmaraju/projects/homelab/platform/README.md)
- [apps/README.md](/Users/bharathpadmaraju/projects/homelab/apps/README.md)
