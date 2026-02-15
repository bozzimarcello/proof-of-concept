#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
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

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Main script
print_header "React + FastAPI Authentication - Quick Start"

# Step 1: Check prerequisites
print_info "Checking prerequisites..."

MISSING_PREREQS=0

if command_exists podman; then
    print_success "Podman found"
    USE_PODMAN=true
elif command_exists docker; then
    print_warning "Docker found (Podman recommended)"
    USE_PODMAN=false
else
    print_error "Neither Podman nor Docker found"
    MISSING_PREREQS=1
fi

if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    print_success "Python found (version $PYTHON_VERSION)"
else
    print_error "Python 3 not found"
    MISSING_PREREQS=1
fi

if command_exists node; then
    NODE_VERSION=$(node --version)
    print_success "Node.js found (version $NODE_VERSION)"
else
    print_error "Node.js not found"
    MISSING_PREREQS=1
fi

if [ $MISSING_PREREQS -eq 1 ]; then
    print_error "Missing prerequisites. Please install missing tools and try again."
    exit 1
fi

echo ""

# Step 2: Choose setup method
print_info "Choose setup method:"
echo "1) Podman Compose (recommended - easiest)"
echo "2) Manual setup with Podman containers (more control)"
echo "3) Manual setup with local Python/Node (development)"
read -p "Enter choice (1-3): " SETUP_CHOICE

echo ""

# Step 3: Setup based on choice
case $SETUP_CHOICE in
    1)
        print_header "Setting up with Podman Compose"

        # Check if .env exists
        if [ ! -f backend/.env ]; then
            print_info "Creating backend/.env file..."

            # Generate SECRET_KEY
            if command_exists openssl; then
                SECRET_KEY=$(openssl rand -hex 32)
            else
                SECRET_KEY="dev-secret-key-$(date +%s)-change-in-production"
                print_warning "OpenSSL not found, using basic SECRET_KEY"
            fi

            cat > backend/.env << EOF
DATABASE_URL=postgresql+psycopg://poc_user:poc_password@postgres:5432/poc_auth_db
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF
            print_success "Created backend/.env"
        else
            print_warning "backend/.env already exists, skipping creation"
        fi

        # Start services
        print_info "Starting Podman Compose services..."
        if $USE_PODMAN; then
            podman-compose up -d 2>/dev/null || {
                print_info "podman-compose not found, trying podman compose..."
                podman compose up -d
            }
        else
            docker compose up -d
        fi

        print_success "Services started!"
        print_info "Waiting for database to be ready..."
        sleep 5

        # Check status
        if $USE_PODMAN; then
            podman-compose ps 2>/dev/null || podman compose ps 2>/dev/null || podman ps
        else
            docker compose ps
        fi

        echo ""
        print_success "Setup complete!"
        print_info "Frontend: http://localhost:3000"
        print_info "Backend API: http://localhost:8000"
        print_info "API Docs: http://localhost:8000/docs"
        print_info ""
        print_info "Default credentials:"
        print_info "  Username: admin"
        print_info "  Password: secret"
        print_info ""
        if $USE_PODMAN; then
            print_info "To stop: podman-compose down (or podman compose down)"
        else
            print_info "To stop: docker compose down"
        fi
        ;;

    2)
        print_header "Manual setup with Podman"

        # Create .env
        if [ ! -f backend/.env ]; then
            print_info "Creating backend/.env file..."
            SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || echo "dev-secret-key-$(date +%s)")
            cat > backend/.env << EOF
DATABASE_URL=postgresql+psycopg://poc_user:poc_password@localhost:5432/poc_auth_db
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF
            print_success "Created backend/.env"
        fi

        # Start Podman PostgreSQL
        print_info "Starting PostgreSQL container..."
        podman volume create poc_postgres_data 2>/dev/null || true

        if podman ps -a | grep -q poc-postgres; then
            print_info "Container exists, starting..."
            podman start poc-postgres
        else
            podman run -d \
                --name poc-postgres \
                -e POSTGRES_USER=poc_user \
                -e POSTGRES_PASSWORD=poc_password \
                -e POSTGRES_DB=poc_auth_db \
                -p 5432:5432 \
                -v poc_postgres_data:/var/lib/postgresql/data \
                postgres:16-alpine
        fi

        print_success "PostgreSQL started"
        sleep 3

        # Backend setup
        print_info "Setting up backend..."
        cd backend

        if [ ! -d venv ]; then
            print_info "Creating virtual environment..."
            python3 -m venv venv
        fi

        source venv/bin/activate
        pip install -q --upgrade pip
        pip install -q -r requirements.txt

        print_info "Running database migrations..."
        alembic upgrade head

        print_info "Seeding admin user..."
        python3 << 'PYTHON_EOF'
from database import SessionLocal
from models import User
from auth import get_password_hash

db = SessionLocal()
try:
    existing = db.query(User).filter(User.username == "admin").first()
    if not existing:
        admin = User(
            username="admin",
            hashed_password=get_password_hash("secret"),
            full_name="Admin User"
        )
        db.add(admin)
        db.commit()
        print("✓ Admin user created")
    else:
        print("⚠ Admin user already exists")
finally:
    db.close()
PYTHON_EOF

        cd ..

        # Frontend setup
        print_info "Setting up frontend..."
        cd frontend
        npm install
        cd ..

        print_success "Setup complete!"
        print_info ""
        print_info "To start the application:"
        print_info "  Terminal 1: cd backend && source venv/bin/activate && uvicorn main:app --reload"
        print_info "  Terminal 2: cd frontend && npm start"
        ;;

    3)
        print_header "Local development setup"

        print_info "This setup requires:"
        print_info "  - PostgreSQL running locally on port 5432"
        print_info "  - Or modify backend/.env to point to your database"
        print_info ""
        read -p "Continue? (y/n): " CONTINUE

        if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
            print_info "Setup cancelled"
            exit 0
        fi

        # Create .env
        if [ ! -f backend/.env ]; then
            print_info "Creating backend/.env file..."
            SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || echo "dev-secret-key-$(date +%s)")
            cat > backend/.env << EOF
DATABASE_URL=postgresql+psycopg://poc_user:poc_password@localhost:5432/poc_auth_db
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF
            print_success "Created backend/.env"
            print_warning "Edit backend/.env to match your database configuration"
        fi

        # Backend setup
        cd backend
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt

        print_info "To run migrations: alembic upgrade head"

        cd ../frontend
        npm install

        print_success "Dependencies installed"
        print_info "Configure your database, then run migrations"
        ;;

    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_header "Next Steps"
print_info "1. Open http://localhost:3000 in your browser"
print_info "2. Login with admin / secret"
print_info "3. Start building your application!"
print_info ""
print_info "Documentation: README.md"
print_info "API Documentation: http://localhost:8000/docs"
print_info ""
print_success "Happy coding! 🚀"
