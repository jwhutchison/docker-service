# Docker Service Manager

A powerful bash script for managing Docker Compose services with simplified commands, systemd integration, and developer-friendly features.

## Features

- 🚀 **Simple Commands**: Start, stop, restart services with easy-to-remember commands
- 🔍 **Service Discovery**: Automatically detects container names, images, and ports from your compose file
- 🏥 **Health Monitoring**: Built-in health checks and status reporting
- 🖥️ **Quick Access**: Open services in your browser with one command
- 📊 **System Integration**: Install as systemd user service for auto-start
- 🛠️ **Developer Tools**: Easy shell access, log tailing, and debugging
- 📦 **Path Management**: Automatic PATH setup for global access

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/jwhutchison/docker-service/main/install.sh | bash
```

Or with wget:
```bash
wget -qO- https://raw.githubusercontent.com/jwhutchison/docker-service/main/install.sh | bash
```

## Manual Installation

1. Download the script:
```bash
curl -o docker-service https://raw.githubusercontent.com/jwhutchison/docker-service/main/docker-service
chmod +x docker-service
```

2. Move to a directory in your PATH:
```bash
mv docker-service ~/.local/bin/
```

3. Or use the built-in PATH management:
```bash
./docker-service ensure-path
```

OR

1. Clone the repository:
```bash
git clone https://github.com/jwhutchison/docker-service.git
```

2. Link the `docker-service` binary to your PATH:
```bash
ln -s ~/path/to/docker-service/docker-service ~/.local/bin/docker-service
```

## Setup

### Creating Your First Service

1. **Create a docker-compose.yaml file** for your project:
```bash
mkdir ~/my-awesome-app
cd ~/my-awesome-app
```

2. **Add your compose configuration** (see [Docker Compose Setup](#docker-compose-setup) for examples)

3. **Choose your workflow**:

**Option A: Use an alias**
```bash
# Add to your shell profile (.bashrc, .zshrc, etc.)
alias my-app='COMPOSE_FILE=~/my-awesome-app/docker-compose.yaml docker-service'

# Usage
my-app start
my-app status
my-app logs
```

**Option B: Create a wrapper script**
```bash
# Create ~/bin/my-app
cat > ~/bin/my-app << 'EOF'
#!/bin/bash
export COMPOSE_FILE=~/my-awesome-app/docker-compose.yaml
exec docker-service "$@"
EOF
chmod +x ~/bin/my-app

# Usage
my-app start
my-app doctor
my-app install-service
```

**Option C: Use environment variable**
```bash
# Export in your current session
export COMPOSE_FILE=~/my-awesome-app/docker-compose.yaml

# Or add to your shell profile for permanent use
echo 'export COMPOSE_FILE=~/my-awesome-app/docker-compose.yaml' >> ~/.bashrc
```

## Usage

### Basic Commands

```bash
# Start your service
COMPOSE_FILE=/path/to/compose.yaml docker-service start

# Stop your service
COMPOSE_FILE=/path/to/compose.yaml docker-service stop

# Restart your service
COMPOSE_FILE=/path/to/compose.yaml docker-service restart

# Check status
COMPOSE_FILE=/path/to/compose.yaml docker-service status

# View logs (follow mode)
COMPOSE_FILE=/path/to/compose.yaml docker-service logs

# Open service in browser
COMPOSE_FILE=/path/to/compose.yaml docker-service open

# Get shell access
COMPOSE_FILE=/path/to/compose.yaml docker-service bash
```

### Advanced Commands

```bash
# Show detailed configuration and health info
COMPOSE_FILE=/path/to/compose.yaml docker-service doctor

# Update service image
COMPOSE_FILE=/path/to/compose.yaml docker-service update

# Show resolved compose configuration
COMPOSE_FILE=/path/to/compose.yaml docker-service config

# Install as systemd user service
COMPOSE_FILE=/path/to/compose.yaml docker-service install-service

# Remove systemd user service
COMPOSE_FILE=/path/to/compose.yaml docker-service uninstall-service

# Add script to PATH
docker-service ensure-path

# Show help
docker-service help
```

### Profile Support

Use Docker Compose profiles to run different configurations:

```bash
# Start with GPU profile
COMPOSE_FILE=/path/to/compose.yaml docker-service start gpu

# Start with CPU profile
COMPOSE_FILE=/path/to/compose.yaml docker-service start cpu

# Restart with different profile
COMPOSE_FILE=/path/to/compose.yaml docker-service restart gpu
```

## Configuration

### Environment Variables

- `COMPOSE_FILE`: Path to your docker-compose.yaml file (default: `./docker-compose.yaml`)

### Example Usage

```bash
# Use a specific compose file
COMPOSE_FILE=/path/to/my-compose.yaml docker-service start

# Or export it
export COMPOSE_FILE=/path/to/my-compose.yaml
docker-service start
```

## Docker Compose Setup

The script works with any Docker Compose file. Here's an example structure:

```yaml
services:
  your-app:
    container_name: your-app
    image: your-org/your-app:latest
    volumes:
      - ./data:/data
    ports:
      - "8080:8080"
    restart: unless-stopped
```

## Systemd Integration

Install your Docker service as a systemd user service for automatic startup:

```bash
# Install as user service
COMPOSE_FILE=/path/to/compose.yaml docker-service install-service

# The service will be named: docker-service-{container-name}
# Control with standard systemctl commands:
systemctl --user start docker-service-your-app
systemctl --user enable docker-service-your-app
systemctl --user status docker-service-your-app
```

## Requirements

- **Docker**: Latest version recommended
- **Docker Compose**: v2.x (plugin version)
- **yq**: YAML processor ([installation guide](https://github.com/mikefarah/yq))
- **Bash**: 4.0+ (standard on most systems)

### Installing yq

```bash
# Arch
sudo pacman -S go-yq

# Ubuntu/Debian
sudo apt install yq

# macOS with Homebrew
brew install yq

# Or download binary
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq
```

## Troubleshooting

### Check Configuration

Use the `doctor` command to diagnose issues:

```bash
COMPOSE_FILE=/path/to/compose.yaml docker-service doctor
```

This shows:
- Docker version
- Compose file location
- Environment file status
- Container information
- Runtime environment
- Service health status

### Common Issues

**Script not found in PATH**:
```bash
docker-service ensure-path
```

**Compose file not found**:
```bash
export COMPOSE_FILE=/path/to/your/docker-compose.yaml
```

**Permission denied**:
```bash
chmod +x /path/to/docker-service
```

**systemd service fails**:
- Check that Docker service is running: `systemctl status docker`
- Verify compose file path is absolute in the service file
- Check service logs: `journalctl --user -u docker-service-{container-name}`

## Examples

### Basic Web Service

```yaml
services:
  webapp:
    container_name: my-webapp
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

```bash
COMPOSE_FILE=./docker-compose.yaml docker-service start    # Start nginx
COMPOSE_FILE=./docker-compose.yaml docker-service open     # Open http://localhost:8080 in browser
COMPOSE_FILE=./docker-compose.yaml docker-service logs     # View nginx logs
COMPOSE_FILE=./docker-compose.yaml docker-service bash     # Get shell in container
```

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different Docker Compose configurations
5. Submit a pull request

### Testing

Test the script with various Docker Compose files:

```bash
# Test basic functionality
COMPOSE_FILE=./docker-compose.yaml docker-service doctor

# Test with different compose files
COMPOSE_FILE=./test-compose.yaml docker-service start

# Test systemd integration
COMPOSE_FILE=./docker-compose.yaml docker-service install-service
systemctl --user status docker-service-test-container
COMPOSE_FILE=./docker-compose.yaml docker-service uninstall-service
```

## License

GPL3 - see LICENSE file for details.

## Changelog

### v1.0.0
- Initial release
- Basic Docker Compose management
- Systemd integration
- PATH management
- Health monitoring
- Browser integration
