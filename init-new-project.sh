#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if project name provided
if [ -z "$1" ]; then
    print_error "Usage: ./init-new-project.sh <project-name>"
    echo ""
    echo "Example: ./init-new-project.sh my-awesome-app"
    echo ""
    echo "This will:"
    echo "  - Rename 'poc' to 'my-awesome-app' in all files"
    echo "  - Generate new SECRET_KEY"
    echo "  - Update Docker/Podman container names"
    echo "  - Update database names"
    echo "  - Clean up template-specific files"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '_' '-')
PROJECT_NAME_SNAKE=$(echo "$PROJECT_NAME_LOWER" | tr '-' '_')

print_header "Initializing New Project: $PROJECT_NAME"

# Confirm with user
print_warning "This will modify the project structure and configuration."
print_info "Project name (lowercase): $PROJECT_NAME_LOWER"
print_info "Database name: ${PROJECT_NAME_SNAKE}_db"
print_info "Container prefix: $PROJECT_NAME_LOWER"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    print_info "Initialization cancelled"
    exit 0
fi

echo ""
print_info "Starting initialization..."

# Step 1: Generate new SECRET_KEY
print_info "Generating new SECRET_KEY..."
if command -v openssl &> /dev/null; then
    NEW_SECRET_KEY=$(openssl rand -hex 32)
    print_success "Generated new SECRET_KEY"
else
    NEW_SECRET_KEY="change-this-secret-key-$(date +%s)-$(shuf -i 1000-9999 -n 1)"
    print_warning "OpenSSL not found, using basic SECRET_KEY. Regenerate in production!"
fi

# Step 2: Update .env files
print_info "Updating environment configuration..."

# Update backend/.env
if [ -f backend/.env ]; then
    sed -i "s/poc_user/${PROJECT_NAME_SNAKE}_user/g" backend/.env
    sed -i "s/poc_password/${PROJECT_NAME_SNAKE}_password/g" backend/.env
    sed -i "s/poc_auth_db/${PROJECT_NAME_SNAKE}_db/g" backend/.env
    sed -i "s/SECRET_KEY=.*/SECRET_KEY=$NEW_SECRET_KEY/" backend/.env
    print_success "Updated backend/.env"
else
    # Create new .env
    cat > backend/.env << EOF
DATABASE_URL=postgresql+psycopg://${PROJECT_NAME_SNAKE}_user:${PROJECT_NAME_SNAKE}_password@localhost:5432/${PROJECT_NAME_SNAKE}_db
SECRET_KEY=$NEW_SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF
    print_success "Created backend/.env"
fi

# Update backend/.env.example
if [ -f backend/.env.example ]; then
    sed -i "s/poc_user/your_db_user/g" backend/.env.example
    sed -i "s/poc_password/your_db_password/g" backend/.env.example
    sed -i "s/poc_auth_db/your_database_name/g" backend/.env.example
    print_success "Updated backend/.env.example"
fi

# Step 3: Update Docker Compose
print_info "Updating Docker Compose configuration..."
if [ -f docker-compose.yml ]; then
    sed -i "s/poc-postgres/${PROJECT_NAME_LOWER}-postgres/g" docker-compose.yml
    sed -i "s/poc-backend/${PROJECT_NAME_LOWER}-backend/g" docker-compose.yml
    sed -i "s/poc-frontend/${PROJECT_NAME_LOWER}-frontend/g" docker-compose.yml
    sed -i "s/poc_postgres_data/${PROJECT_NAME_SNAKE}_postgres_data/g" docker-compose.yml
    sed -i "s/poc-network/${PROJECT_NAME_LOWER}-network/g" docker-compose.yml
    sed -i "s/poc_user/${PROJECT_NAME_SNAKE}_user/g" docker-compose.yml
    sed -i "s/poc_password/${PROJECT_NAME_SNAKE}_password/g" docker-compose.yml
    sed -i "s/poc_auth_db/${PROJECT_NAME_SNAKE}_db/g" docker-compose.yml
    print_success "Updated docker-compose.yml"
fi

# Step 4: Update documentation
print_info "Updating documentation..."

# Update README.md title
if [ -f README.md ]; then
    sed -i "1s/.*/# $PROJECT_NAME/" README.md
    sed -i "s/proof-of-concept/$PROJECT_NAME_LOWER/g" README.md
    print_success "Updated README.md"
fi

# Update CLAUDE.md
if [ -f CLAUDE.md ]; then
    sed -i "s/proof of concept/$PROJECT_NAME/g" CLAUDE.md
    sed -i "s/proof-of-concept/$PROJECT_NAME_LOWER/g" CLAUDE.md
    print_success "Updated CLAUDE.md"
fi

# Update package.json
if [ -f frontend/package.json ]; then
    sed -i "s/\"name\": \"frontend\"/\"name\": \"${PROJECT_NAME_LOWER}-frontend\"/" frontend/package.json
    print_success "Updated frontend/package.json"
fi

# Step 5: Clean up existing database/containers
print_info "Cleaning up existing containers and volumes..."

if command -v podman &> /dev/null; then
    podman stop poc-postgres poc-backend poc-frontend 2>/dev/null || true
    podman rm poc-postgres poc-backend poc-frontend 2>/dev/null || true
    print_success "Cleaned up Podman containers"
elif command -v docker &> /dev/null; then
    docker stop poc-postgres poc-backend poc-frontend 2>/dev/null || true
    docker rm poc-postgres poc-backend poc-frontend 2>/dev/null || true
    print_success "Cleaned up Docker containers"
fi

# Step 6: Optional - Reset Git history
echo ""
print_warning "Do you want to reset Git history? (start fresh)"
print_info "This will create a new initial commit for your project"
read -p "Reset Git history? (y/n): " RESET_GIT

if [[ $RESET_GIT =~ ^[Yy]$ ]]; then
    rm -rf .git
    git init
    git add .
    git commit -m "Initial commit: $PROJECT_NAME

Based on React + FastAPI authentication template with:
- JWT authentication
- PostgreSQL database
- Docker Compose setup
- Database migrations with Alembic"
    print_success "Git history reset with new initial commit"
fi

# Step 7: Summary
echo ""
print_header "Initialization Complete!"
print_success "Project configured as: $PROJECT_NAME"
echo ""
print_info "Updated configurations:"
print_info "  ✓ Database: ${PROJECT_NAME_SNAKE}_db"
print_info "  ✓ DB User: ${PROJECT_NAME_SNAKE}_user"
print_info "  ✓ Container prefix: $PROJECT_NAME_LOWER"
print_info "  ✓ New SECRET_KEY generated"
echo ""
print_info "Next steps:"
print_info "  1. Review backend/.env file"
print_info "  2. Run ./quickstart.sh to start the project"
print_info "  3. Start customizing your application!"
echo ""
print_success "Happy coding! 🚀"
