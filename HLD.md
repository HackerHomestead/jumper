# High-Level Design Document (HDL)

## 1. Overview

**Project Name:** Jumper  
**Type:** Docker/Podman Container - SSH Jump Host  
**Purpose:** A minimal SSH jump host container that runs on MikroTik routers (via Podman) or any Docker/Podman host, enabling secure remote access to internal networks.  
**Target Users:** Network administrators, DevOps engineers, and users needing secure jump host functionality.

---

## 2. System Architecture

### 2.1 Container Overview

```
┌─────────────────────────────────────────┐
│           Jumper Container              │
│  ┌───────────────────────────────────┐  │
│  │         Alpine Linux             │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │     SSHD Service           │  │  │
│  │  │  (Port 22)                 │  │  │
│  │  └─────────────────────────────┘  │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │     User: myuser           │  │  │
│  │  │  + authorized_keys         │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
         │
    Host Port 2222
         │
         ▼
   External Client
```

### 2.2 Components

| Component | Description | Technology |
|-----------|-------------|------------|
| Base Image | Minimal Linux distribution | Alpine Linux |
| SSH Server | Secure shell daemon | OpenSSH |
| User Management | Non-root user for access | myuser |
| Authentication | Key-based SSH only | authorized_keys |
| Tools | tmux, screen for sessions | Alpine packages |

---

## 3. Functionality Specification

### 3.1 Core Features

1. **SSH Access**
   - Listen on port 22 (container), exposed on port 2222 (host)
   - Key-based authentication only (no password auth)
   - Permit root login with key only

2. **Jump Host Capabilities**
   - TCP forwarding enabled
   - Gateway ports disabled (security)
   - Agent forwarding enabled

3. **Security**
   - Non-root user for primary access
   - Public key authentication enforced
   - Minimal attack surface (Alpine base)

### 3.2 User Interactions

| Action | Method |
|--------|--------|
| Connect to jump host | `ssh -p 2222 myuser@host` |
| Use as jump host | `ssh -J myuser@host:2222 target` |
| TCP forwarding | `ssh -p 2222 myuser@host -L 8080:internal:80` |

### 3.3 Data Flow

```
Client → Host:2222 → Container:22 → SSHD → authorized_keys → Shell/Forward
```

---

## 4. Configuration

### 4.1 Files

| File | Purpose |
|------|---------|
| `authorized_keys` | SSH public keys for authentication |
| `sshd_config` | SSH daemon configuration |
| `shadow` | User password file (optional) |
| `Dockerfile` | Container build instructions |

### 4.2 Build Arguments

| Arg | Default | Description |
|-----|---------|-------------|
| `IMAGE_NAME` | jumper | Container image name |
| `IMAGE_TAG` | latest | Container image tag |
| `PORT` | 2222 | Host port mapping |

---

## 5. Deployment

### 5.1 Supported Platforms

- Docker (x86_64, ARM64)
- Podman (x86_64, ARM64, MikroTik RouterOS)
- Any Linux host with container runtime

### 5.2 Usage Commands

```bash
# Build
make build
# or
podman build -t jumper:latest .

# Run
make run
# or
podman run -d -p 2222:22 jumper:latest

# Interactive
make run-interactive
```

---

## 6. Security Considerations

- **Password authentication disabled** - Keys only
- **Root login restricted** - Keys only, no password
- **Minimal packages** - Reduced attack surface
- **Non-root user** - Primary access via unprivileged user

---

## 7. Future Enhancements

- Support for configurable user via build args
- Optional MFA/2FA support
- Audit logging
- Container health checks
- Automatic key rotation
