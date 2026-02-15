# Why This Template Uses Podman

## TL;DR

**Podman is the recommended container tool for this template** because it's:
- ✅ **Rootless** - More secure (no daemon running as root)
- ✅ **Daemonless** - No background process needed
- ✅ **Docker-compatible** - Drop-in replacement (same commands)
- ✅ **Systemd integration** - Better for production services
- ✅ **Open source** - No vendor lock-in

**Docker still works perfectly** - just replace `podman` with `docker` in commands.

---

## Podman vs Docker: Key Differences

### 1. **Architecture**

**Docker:**
```
┌─────────────────────────────┐
│   Docker Client (CLI)       │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│   Docker Daemon (root)      │ ← Single point of failure
│   - Runs as root            │ ← Security concern
│   - Always running          │ ← Resource usage
└─────────────────────────────┘
```

**Podman:**
```
┌─────────────────────────────┐
│   Podman CLI                │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│   Direct container fork     │ ← No daemon
│   - Runs as your user       │ ← Rootless
│   - Only when needed        │ ← No background process
└─────────────────────────────┘
```

### 2. **Security**

| Feature | Podman | Docker |
|---------|--------|--------|
| **Rootless containers** | ✅ Default | ⚠️ Requires setup |
| **No daemon as root** | ✅ Yes | ❌ No |
| **User namespace support** | ✅ Built-in | ⚠️ Experimental |
| **SELinux integration** | ✅ Excellent | ⚠️ Basic |
| **Attack surface** | 🟢 Smaller | 🟡 Larger |

### 3. **Resource Usage**

**Docker:**
- Background daemon always running (~50-100MB memory)
- Daemon manages all containers
- Single process tree

**Podman:**
- No daemon (0MB when idle)
- Each container is independent
- Lower memory footprint

### 4. **Systemd Integration**

**Podman:**
```bash
# Generate systemd service automatically
podman generate systemd --new --name mycontainer > ~/.config/systemd/user/mycontainer.service
systemctl --user enable mycontainer
systemctl --user start mycontainer
```

**Docker:**
- Requires manual systemd unit files
- Daemon must be running first
- More complex setup

---

## Command Compatibility

Podman is designed as a **drop-in replacement** for Docker:

| Task | Docker | Podman |
|------|--------|--------|
| Run container | `docker run` | `podman run` |
| List containers | `docker ps` | `podman ps` |
| Build image | `docker build` | `podman build` |
| Compose up | `docker compose up` | `podman-compose up` or `podman compose up` |
| Pull image | `docker pull` | `podman pull` |
| Execute command | `docker exec` | `podman exec` |

**Alias trick** (if you prefer typing `docker`):
```bash
alias docker=podman
alias docker-compose=podman-compose
```

---

## Why Podman for This Template?

### 1. **Security First**

This template handles authentication and user data, so security is critical:
- Rootless containers mean a compromised container can't escalate to root
- No daemon running as root reduces attack surface
- Better isolation between containers and host

### 2. **Development Experience**

- No daemon to start/stop
- Faster startup (no daemon initialization)
- Less resource usage on your laptop
- Same commands as Docker (easy migration)

### 3. **Production Ready**

- Used by Red Hat, Fedora, CentOS Stream
- Better systemd integration for services
- Built-in support for Kubernetes YAML (podman play kube)
- rootless containers work in more restricted environments

### 4. **Future-Proof**

- Open Container Initiative (OCI) compliant
- No vendor lock-in
- Growing community and ecosystem
- Docker compatibility means you can switch anytime

---

## Installation

### Fedora / RHEL / CentOS Stream
```bash
sudo dnf install podman podman-compose
```

### Ubuntu / Debian
```bash
sudo apt update
sudo apt install podman
sudo apt install python3-pip
pip3 install podman-compose
```

### macOS
```bash
brew install podman podman-compose
podman machine init
podman machine start
```

### Windows
Download from: https://podman.io/getting-started/installation

---

## Migrating from Docker

If you're already using Docker, here's how to migrate:

### Option 1: Keep Both (Recommended for Learning)
- Install Podman alongside Docker
- Try Podman for new projects
- Keep Docker for existing projects

### Option 2: Full Migration
```bash
# Export Docker images
docker save myimage:tag | podman load

# Or rebuild with Podman
podman build -t myimage:tag .

# Update aliases
alias docker=podman
alias docker-compose=podman-compose
```

### Option 3: Use This Template with Docker
Everything works with Docker too:
```bash
# Replace 'podman' with 'docker' in commands
docker compose up -d
docker ps
docker logs poc-postgres
```

---

## Common Questions

### **Q: Do I need to learn new commands?**
**A:** No! Podman uses the same commands as Docker. Just replace `docker` with `podman`.

### **Q: Can I use Docker Hub images?**
**A:** Yes! Podman pulls from Docker Hub by default:
```bash
podman pull postgres:16-alpine  # Works!
```

### **Q: What about podman-compose vs podman compose?**
**A:** Both work:
- `podman-compose`: Separate Python tool (more mature)
- `podman compose`: Built-in (newer, improving rapidly)

Use whichever you prefer. This template supports both.

### **Q: Will my Docker Compose files work?**
**A:** Yes! Podman Compose reads the same `docker-compose.yml` files.

### **Q: Is Podman slower than Docker?**
**A:** No! Often faster because:
- No daemon overhead
- Direct process forking
- Better resource utilization

### **Q: What if I prefer Docker?**
**A:** Totally fine! All scripts and compose files work with Docker. Just:
1. Install Docker instead of Podman
2. Use `docker` instead of `podman` in commands
3. Everything else works the same

---

## Troubleshooting

### Podman-compose not found
```bash
# Install podman-compose
pip3 install podman-compose

# Or use built-in
podman compose up -d
```

### Permission errors
```bash
# Podman rootless needs proper user setup
podman system migrate
podman info  # Check for warnings
```

### Port conflicts
```bash
# Check what's running
podman ps

# Stop all containers
podman stop --all
```

### Slower on macOS
```bash
# Increase VM resources
podman machine stop
podman machine rm
podman machine init --cpus 4 --memory 8192 --disk-size 100
podman machine start
```

---

## Resources

- **Official Docs**: https://podman.io/
- **Tutorials**: https://github.com/containers/podman/tree/main/docs/tutorials
- **Migration Guide**: https://podman.io/getting-started/migration
- **Compose Docs**: https://github.com/containers/podman-compose

---

## Summary

| Aspect | Podman | Docker |
|--------|--------|--------|
| **Security** | 🟢 Rootless by default | 🟡 Requires setup |
| **Resource Usage** | 🟢 No daemon overhead | 🟡 Always-on daemon |
| **Compatibility** | 🟢 Docker-compatible | 🟢 Industry standard |
| **Systemd** | 🟢 Excellent integration | 🟡 Manual setup |
| **Learning Curve** | 🟢 Same as Docker | 🟢 Well-documented |
| **Production** | 🟢 Enterprise-ready | 🟢 Battle-tested |

**Recommendation**: Use Podman for new projects. It's more secure, uses fewer resources, and works exactly like Docker.

**Bottom line**: This template uses Podman because it's better for security and resources, but **Docker works perfectly too**. Choose what you're comfortable with!

---

**Ready to try Podman?**
```bash
./quickstart.sh
```

**Prefer Docker?**
Just use `docker` instead of `podman` - everything else is the same! 🚀
