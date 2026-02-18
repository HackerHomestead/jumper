#!/bin/bash
set -e

IMAGE_NAME="jumper"
CONTAINER_NAME="jumper"
PORT=2222

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_authorized_keys() {
    if [[ ! -s authorized_keys ]]; then
        log_warn "authorized_keys is empty or missing!"
        log_info "Add your SSH public keys to authorized_keys before building."
        log_info "Example: cat ~/.ssh/id_rsa.pub >> authorized_keys"
        return 1
    fi
    log_info "Found $(wc -l < authorized_keys) SSH key(s) in authorized_keys"
}

build() {
    log_info "Building Docker image..."
    podman build --platform linux/amd64 -t "$IMAGE_NAME:latest" .
    log_info "Image built successfully!"
}

start() {
    log_info "Starting container on port $PORT..."
    podman run -d --name "$CONTAINER_NAME" -p "$PORT:22" "$IMAGE_NAME:latest"
    log_info "Container started!"
    log_info "Connect with: ssh -p $PORT myuser@localhost"
    log_info "Or as jump host: ssh -J myuser@localhost:$PORT target-host"
}

stop() {
    log_info "Stopping container..."
    podman stop "$CONTAINER_NAME" 2>/dev/null || true
    log_info "Container stopped."
}

remove() {
    log_info "Removing container..."
    podman rm "$CONTAINER_NAME" 2>/dev/null || true
    log_info "Container removed."
}

logs() {
    podman logs -f "$CONTAINER_NAME"
}

shell() {
    podman exec -it "$CONTAINER_NAME" /bin/bash
}

status() {
    if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        log_info "Container is running"
        podman ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Ports}}"
    elif podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        log_info "Container exists but is stopped"
    else
        log_info "Container does not exist"
    fi
}

usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  build    Build the Docker image"
    echo "  start    Start the container"
    echo "  stop     Stop the container"
    echo "  remove   Remove the container"
    echo "  logs     View container logs"
    echo "  shell    Get shell inside container"
    echo "  status   Show container status"
    echo "  clean    Stop and remove container"
    echo ""
    echo "Examples:"
    echo "  $0 build && $0 start"
    echo "  $0 logs"
    echo "  $0 clean"
}

case "${1:-}" in
    build)  build ;;
    start)  start ;;
    stop)   stop ;;
    remove) remove ;;
    logs)   logs ;;
    shell)  shell ;;
    status) status ;;
    clean)  stop && remove ;;
    *)      check_authorized_keys || true; usage ;;
esac
