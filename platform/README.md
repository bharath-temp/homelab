## Platform

`platform/` contains shared, app-agnostic capabilities. Apps should consume these services through stable patterns instead of each app reinventing them.

Current convention:

```text
platform/
  <capability>/
    <provider>/
      base/
      homelab/
```

Examples:

- `platform/storage/longhorn/`
- `platform/auth/authentik/`
- `platform/data/cnpg/`
- `platform/networking/ingress-nginx/`

Rules:

- `base/` contains the reusable install definition
- `homelab/` contains cluster-specific values or patches
- `clusters/homelab/platform/*.yaml` is the install list Flux reconciles

How to add a new platform service:

1. Create `platform/<capability>/<provider>/base/` and `platform/<capability>/<provider>/homelab/`.
2. Put the reusable manifests or HelmRelease in `base/`.
3. Put cluster-specific patches in `homelab/`.
4. Add a Flux `Kustomization` in `clusters/homelab/platform/<provider>.yaml`.

Current live platform service:

- `storage/longhorn`
