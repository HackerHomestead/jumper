# Jumper - SSH Jump Host

A minimal SSH jump host container image designed to run on MikroTik routers (using Podman) or any Docker/Podman host.

## Features

- Minimal Alpine-based image
- Key-based SSH authentication only
- Supports TCP forwarding for jump host functionality
- Pre-configured for secure operation

## Quick Start

### Build

```bash
docker build -t jumper:latest .
```

### Run

```bash
docker run -d -p 2222:22 jumper:latest
```

### Interactive Shell (for testing)

```bash
docker run -it -p 2222:22 jumper:latest /bin/bash
```

## Configuration

### Adding SSH Keys

Edit `authorized_keys` and add your public SSH keys, one per line.

### Password

The default password for `myuser` is set in the `shadow` file. **Change this before production use:**

```bash
# Generate a new shadow file
docker run --rm jumper:latest cat /etc/shadow > shadow
```

Then edit the shadow file to set your password, or rebuild the image.

### Custom SSH Config

Edit `sshd_config` to customize SSH settings. The default configuration:
- Key-based authentication only (`PasswordAuthentication no`)
- Permit root login with key only (`PermitRootLogin prohibit-password`)
- TCP forwarding enabled (`AllowTcpForwarding yes`)

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SSH_PORT` | SSH port | `22` |

## Usage Examples

### As a Jump Host

```bash
# From a client machine
ssh -J myuser@jump-host:2222 target-host
```

### MikroTik RouterOS (Podman)

```bash
# On MikroTik
/container/add name=jumper interface=bridge destination=0.0.0.0/0
```

## Security Notes

- Change the default password before production use
- Review `sshd_config` for your security requirements
- Only add trusted SSH keys to `authorized_keys`

## License

MIT License - see LICENSE file.
