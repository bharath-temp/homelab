# Homelab Platform Architecture

## Overview

This homelab is designed as a **GitOps-driven, platform-oriented Kubernetes environment**.

Instead of treating Kubernetes as raw infrastructure, we are building a **mini internal platform (PaaS-like layer)** that provides reusable capabilities:

* Auth (Authentik)
* Databases (CNPG/Postgres)
* Storage (Longhorn)
* Ingress / Exposure
* TLS / Certificates
* Standardized app deployment

Applications consume these capabilities declaratively rather than implementing them themselves.

---

## Core Principles

### 1. Platform > Infrastructure

We use `platform/` instead of `infrastructure/`.

* **Infrastructure** = low-level cluster setup
* **Platform** = reusable services apps build on

This system is a **self-service platform**, not just a cluster.

---

### 2. App-Agnostic Platform

Platform components:

* are reusable across apps
* contain no app-specific logic
* expose clean interfaces

Apps declare *what they need*, not *how it’s implemented*.

---

### 3. App-First Organization

We organize by **resource (app or platform component)**, not by layer.

Each unit has:

* `base/` → reusable definition
* `homelab/` → cluster-specific overlay

This keeps everything intuitive and easy to navigate.

---

### 4. GitOps-First

* All state lives in Git
* Flux reconciles continuously
* No manual drift

---

### 5. Progressive Platform Evolution

We are intentionally evolving toward a mini-PaaS:

1. Helm + Kustomize (today)
2. Standardized app interface
3. App CRD + controller
4. Optional GUI layer

---

## Repository Structure

```
homelab/
├─ bootstrap/
│  ├─ butane/
│  ├─ ignition/
│  └─ scripts/
│
├─ platform/
│  ├─ cilium/
│  │  ├─ base/
│  │  └─ homelab/
│  ├─ cert-manager/
│  │  ├─ base/
│  │  └─ homelab/
│  ├─ cnpg/
│  │  ├─ base/
│  │  └─ homelab/
│  ├─ authentik/
│  │  ├─ base/
│  │  └─ homelab/
│  ├─ ingress/
│  │  ├─ base/
│  │  └─ homelab/
│  ├─ app-chart/
│  │  └─ chart/
│  └─ docs/
│
├─ apps/
│  ├─ miniflux/
│  │  ├─ base/
│  │  └─ homelab/
│  ├─ linkding/
│  │  ├─ base/
│  │  └─ homelab/
│  └─ whoami/
│     ├─ base/
│     └─ homelab/
│
├─ clusters/
│  └─ homelab/
│     ├─ flux-system/
│     ├─ platform/
│     │  └─ kustomization.yaml
│     ├─ apps/
│     │  └─ kustomization.yaml
│     └─ kustomization.yaml
│
└─ docs/
```

---

## Layer Responsibilities

### `bootstrap/`

* OS provisioning (FCOS)
* Butane → Ignition
* Node bootstrap
  **(pre-Kubernetes)**

---

### `platform/`

#### Providers (cluster systems)

* Cilium
* cert-manager
* CNPG
* Authentik
* ingress controller

#### Interfaces (app-facing)

* shared app Helm chart
* auth integration
* exposure patterns
* database patterns

Platform = reusable + app-agnostic.

---

### `apps/`

Each app:

```
apps/<app>/
  base/
  homelab/
```

#### `base/`

* namespace
* HelmRelease
* default config

#### `homelab/`

* hostname
* storage sizing
* enable auth/db
* environment-specific overrides

---

### `clusters/`

Defines what runs in a cluster.

```
clusters/homelab/
  platform/
  apps/
```

* `platform/` → installs shared services
* `apps/` → installs workloads

This is the **composition layer**.

---

## Deployment Flow

1. Bootstrap nodes → k0s cluster
2. Install Flux
3. Flux watches `clusters/homelab/`
4. Cluster installs:

   * platform
   * apps
5. Continuous reconciliation

---

## App Model (v1)

Apps use a shared internal Helm chart:

```yaml
image:
  repository: ghcr.io/miniflux/miniflux
  tag: 2.2.5

service:
  port: 8080

exposure:
  enabled: true
  type: public
  hostname: rss.beeslab.me

auth:
  enabled: true
  provider: authentik

database:
  postgres:
    enabled: true
    provider: cnpg

persistence:
  enabled: false
```

This is the interface between apps and the platform.

---

## Benefits

### Reusability

Define once, use everywhere.

### Consistency

All apps follow the same patterns.

### Composability

Apps declare needs; platform fulfills them.

### GitOps-native

Fully declarative and reproducible.

### Evolvability

Natural path to CRDs, operators, GUI.

### Clear separation

| Layer     | Responsibility      |
| --------- | ------------------- |
| bootstrap | machines + OS       |
| platform  | shared capabilities |
| apps      | workloads           |
| clusters  | composition         |

---

## Summary

This homelab is evolving into:

**A GitOps-managed internal platform that enables self-service application deployment on Kubernetes with built-in auth, databases, storage, and exposure.**
