#!/bin/bash


set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    print_error "Ansible is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y ansible
fi

# Check if required files exist
if [ ! -f "playbook.yml" ]; then
    print_error "playbook.yml not found in current directory"
    exit 1
fi

if [ ! -f "inventory.ini" ]; then
    print_error "inventory.ini not found in current directory"
    exit 1
fi

# Load environment variables if .env file exists
if [ -f ".env" ]; then
    print_info "Loading environment variables from .env file"
    export $(grep -v '^#' .env | xargs)
fi

# Set default values if not provided
export DOMAIN_NAME=${DOMAIN_NAME:-"localhost"}
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"secure_root_pass_$(openssl rand -hex 8)"}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-"secure_wp_pass_$(openssl rand -hex 8)"}
export WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-"admin_pass_$(openssl rand -hex 8)"}
export WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-"admin@example.com"}

print_info "=========================================="
print_info "WordPress Deployment Configuration"
print_info "=========================================="
print_info "Domain Name: ${DOMAIN_NAME}"
print_info "WordPress Admin Email: ${WP_ADMIN_EMAIL}"
print_info "=========================================="

# Test SSH connectivity
print_info "Testing SSH connectivity to target hosts..."
if ! ansible wordpress_servers -m ping -i inventory.ini > /dev/null 2>&1; then
    print_error "Cannot connect to target hosts. Please check:"
    print_error "1. Your inventory.ini file has correct IPs"
    print_error "2. SSH keys are properly configured"
    print_error "3. Target hosts are accessible"
    exit 1
fi
print_info "SSH connectivity test passed!"

# Run Ansible playbook
print_info "Starting deployment..."
ansible-playbook -i inventory.ini playbook.yml \
  --become \
  --become-method=sudo \
  --become-user=root

if [ $? -eq 0 ]; then
    print_info "=========================================="
    print_info "Deployment completed successfully!"
    print_info "=========================================="
    print_info "Access your WordPress site at: https://${DOMAIN_NAME}"
    print_info "Access PHPMyAdmin at: https://pma.${DOMAIN_NAME}"
    print_info "WordPress Admin User: admin"
    print_info "WordPress Admin Password: ${WP_ADMIN_PASSWORD}"
    print_info "=========================================="
    print_warning "Note: Self-signed SSL certificates are used."
    print_warning "You may need to accept security warnings in your browser."
    print_info "=========================================="
else
    print_error "Deployment failed. Check the output above for errors."
    exit 1
fi