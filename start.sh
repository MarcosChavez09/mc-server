#!/bin/bash

# Minecraft Server Management Script
set -e

# Colors for output.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to start the server
start_server() {
    print_status "Starting Minecraft server..."
    docker compose up -d
    print_status "Server started! Check logs with: docker compose logs -f mc-server"
    print_status "Server will be accessible at: localhost_or_ip_server_address:8888"
}

# Function to stop the server
stop_server() {
    print_status "Stopping Minecraft server..."
    docker compose down
    print_status "Server stopped!"
}

# Function to restart the server
restart_server() {
    print_status "Restarting Minecraft server..."
    docker compose restart
    print_status "Server restarted!"
}

# Function to show server status
show_status() {
    print_status "Server status:"
    docker compose ps
}

# Function to show logs
show_logs() {
    print_status "Showing server logs (Ctrl+C to exit):"
    docker compose logs -f mc-server
}

# Function to backup the world
backup_world() {
    print_status "Creating world backup..."
    
    # Create backups directory if it doesn't exist
    mkdir -p backups
    
    # Stop the server for clean backup
    docker compose down
    
    # Create timestamped backup
    BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S)"
    docker run --rm -v minecraft-server_minecraft_data:/data -v $(pwd)/backups:/backup ubuntu tar czf /backup/$BACKUP_NAME.tar.gz -C /data .
    
    # Start the server
    docker compose up -d
    
    print_status "Backup created: ./backups/$BACKUP_NAME.tar.gz"
}

# Function to test server connectivity
test_server() {

    # Use first argument as host, default to localhost
    HOST="${1:-localhost}"
    PORT="${2:-8888}"

    print_status "Testing server connectivity..."
    
    # Check if Python and mcstatus are available
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 is not installed. Please install Python3 to run tests."
        return 1
    fi

     # Check if pip3 is available
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is not installed. Please install pip3 to run tests."
        return 1
    fi
    
    # Install mcstatus if not available
    if ! python3 -c "import mcstatus" &> /dev/null; then
        print_warning "mcstatus library not found. Installing..."
        pip3 install --user mcstatus
    fi
    
    # Run the test script
    python3 test_server.py "$HOST" "$PORT"
}

# Function to show help
show_help() {
    echo "Minecraft Server Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     - Start the Minecraft server"
    echo "  stop      - Stop the Minecraft server"
    echo "  restart   - Restart the Minecraft server"
    echo "  status    - Show server status"
    echo "  logs      - Show server logs"
    echo "  backup    - Create a world backup"
    echo "  test      - Test server connectivity"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs"
    echo "  $0 backup"
    echo "  $0 test (localhost) or $0 test <server_IP> <port>"
    echo ""
    echo "Server will be accessible at: localhost_or_server_IP:8888"
}

# Main script logic
case "${1:-help}" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        restart_server
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    backup)
        backup_world
        ;;
    test)
        shift
        test_server "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac 