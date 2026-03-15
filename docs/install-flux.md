# Install Fluxcd

## Links
### Official Docs
- Install Flux: https://fluxcd.io/flux/get-started/
- Flux mono-repo: https://fluxcd.io/flux/guides/repository-structure/
- Flux Github PAT: https://fluxcd.io/flux/installation/bootstrap/github/

## Install
`brew install fluxcd/tap/flux`

Create a PAT in github with the following permissions
```
Administration -> Access: Read-only
Contents -> Access: Read and write
Metadata -> Access: Read-only
```

Export the token and username
```
export GITHUB_TOKEN=<your-PAT-token>
export GITHUB_USER=<your-username>
```

Preflight check for flux
```
flux check --pre

► checking prerequisites
✔ Kubernetes 1.35.1+k0s >=1.33.0-0
✔ prerequisites checks passed
```

Bootstrap Fluxcd
`flux bootstrap github --token-auth --owner=$GITHUB_USER --repository=homelab --branch=master --path=./clusters/homelab --personal`
 