## Apps

`apps/` is the self-service workload catalog. Each app owns its own manifests and exposes only one cluster overlay per environment.

Current convention:

```text
apps/
  <app-name>/
    base/
    homelab/
```

Rules:

- `base/` is the reusable app definition
- `homelab/` is the cluster-specific overlay
- `clusters/homelab/apps/*.yaml` is the list of apps Flux installs

To add a new app:

1. Copy `apps/_template/` to `apps/<app-name>/`.
2. Rename resources inside the new app directory.
3. Adjust image, ports, storage, and ingress in the overlay.
4. Add a Flux `Kustomization` in `clusters/homelab/apps/<app-name>.yaml`.

Reference example:

- `apps/whoami/`
