#!/bin/bash

# Yvanietec Django Deployment Script
# Run this script on your DigitalOcean droplet

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  🚀 Yvanietec Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create .env file first. Example:"
    echo "  cp env.example .env"
    echo "  nano .env"
    exit 1
fi

# Ask for database choice
echo -e "${YELLOW}Choose database:${NC}"
echo "1) SQLite (easier, good for small sites)"
echo "2) PostgreSQL (better for production)"
read -p "Enter choice (1 or 2) [1]: " db_choice
db_choice=${db_choice:-1}

# Update system
echo ""
echo -e "${GREEN}📦 Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install required packages
echo ""
echo -e "${GREEN}🔧 Installing required packages...${NC}"
if [ "$db_choice" == "2" ]; then
    sudo apt install -y python3 python3-pip python3-venv nginx postgresql postgresql-contrib git curl
else
    sudo apt install -y python3 python3-pip python3-venv nginx git curl
fi

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Set up Python virtual environment
echo ""
echo -e "${GREEN}🐍 Setting up Python virtual environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

# Install Python dependencies
echo ""
echo -e "${GREEN}📚 Installing Python dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

# Set up database
if [ "$db_choice" == "2" ]; then
    echo ""
    echo -e "${GREEN}🗄️ Setting up PostgreSQL database...${NC}"
    
    read -p "Enter database name [yvanietec_db]: " db_name
    db_name=${db_name:-yvanietec_db}
    
    read -p "Enter database user [yvanietec_user]: " db_user
    db_user=${db_user:-yvanietec_user}
    
    read -sp "Enter database password: " db_pass
    echo ""
    
    # Create database and user
    sudo -u postgres psql -c "CREATE DATABASE $db_name;" 2>/dev/null || echo "Database already exists"
    sudo -u postgres psql -c "CREATE USER $db_user WITH PASSWORD '$db_pass';" 2>/dev/null || echo "User already exists"
    sudo -u postgres psql -c "ALTER USER $db_user PASSWORD '$db_pass';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
    
    echo ""
    echo -e "${YELLOW}Update your .env file with:${NC}"
    echo "DATABASE_URL=postgresql://$db_user:$db_pass@localhost:5432/$db_name"
    read -p "Press Enter to continue..."
else
    echo ""
    echo -e "${GREEN}🗄️ Using SQLite database...${NC}"
    # Make sure db.sqlite3 directory is writable
    touch db.sqlite3 2>/dev/null || true
fi

# Run Django migrations
echo ""
echo -e "${GREEN}🔄 Running Django migrations...${NC}"
python manage.py migrate --settings=project.settings_production

# Create superuser
echo ""
echo -e "${GREEN}👤 Creating Django superuser...${NC}"
echo "Please create an admin account:"
python manage.py createsuperuser --settings=project.settings_production

# Collect static files
echo ""
echo -e "${GREEN}📦 Collecting static files...${NC}"
python manage.py collectstatic --settings=project.settings_production --noinput

# Create logs directory
echo ""
echo -e "${GREEN}📝 Setting up logging...${NC}"
mkdir -p logs
touch logs/django.log

# Set up Nginx
echo ""
echo -e "${GREEN}🌐 Setting up Nginx...${NC}"
sudo cp nginx.conf /etc/nginx/sites-available/yvanietec
sudo ln -sf /etc/nginx/sites-available/yvanietec /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
if sudo nginx -t; then
    echo -e "${GREEN}✓ Nginx configuration valid${NC}"
    sudo systemctl enable nginx
    sudo systemctl restart nginx
else
    echo -e "${RED}✗ Nginx configuration error${NC}"
    exit 1
fi

# Set up systemd service
echo ""
echo -e "${GREEN}⚡ Setting up systemd service...${NC}"
sudo cp yvanietec.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable yvanietec

# Set proper permissions
echo ""
echo -e "${GREEN}🔒 Setting proper permissions...${NC}"
sudo chown -R www-data:www-data logs
if [ -f "db.sqlite3" ]; then
    sudo chown www-data:www-data db.sqlite3
    sudo chmod 664 db.sqlite3
fi
sudo chown -R www-data:www-data staticfiles 2>/dev/null || true
sudo chown -R www-data:www-data media 2>/dev/null || true

# Start the service
echo ""
echo -e "${GREEN}▶️ Starting Yvanietec service...${NC}"
sudo systemctl start yvanietec

# Wait a moment for service to start
sleep 2

# Check service status
if sudo systemctl is-active --quiet yvanietec; then
    echo -e "${GREEN}✓ Service started successfully${NC}"
else
    echo -e "${RED}✗ Service failed to start${NC}"
    echo "Check logs: sudo journalctl -u yvanietec -n 50"
fi

# Configure firewall
echo ""
echo -e "${GREEN}🔥 Configuring firewall...${NC}"
sudo ufw allow 22 2>/dev/null || true
sudo ufw allow 80 2>/dev/null || true
sudo ufw allow 443 2>/dev/null || true
sudo ufw --force enable 2>/dev/null || echo "Firewall already configured"

# Final status check
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Service Status:${NC}"
sudo systemctl status yvanietec --no-pager -l | head -n 10
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Install SSL: ${BLUE}sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com${NC}"
echo "2. Visit: ${BLUE}http://your-domain.com${NC}"
echo "3. Admin: ${BLUE}http://your-domain.com/admin${NC}"
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo "  Check status: ${BLUE}sudo systemctl status yvanietec${NC}"
echo "  View logs:    ${BLUE}sudo journalctl -u yvanietec -f${NC}"
echo "  Restart:      ${BLUE}sudo systemctl restart yvanietec${NC}"
echo ""
echo -e "${GREEN}🎉 Your website should now be live!${NC}"
echo ""
