#!/bin/bash

# Yvanietec Update Script
# Run this script to update your deployed application

set -e

echo "🔄 Starting Yvanietec update..."

# Stop the service
echo "⏹️ Stopping service..."
sudo systemctl stop yvanietec

# Navigate to project directory
cd /var/www/yvanietec

# Activate virtual environment
source venv/bin/activate

# Pull latest changes (if using git)
# git pull origin main

# Install/update dependencies
echo "📚 Updating dependencies..."
pip install -r requirements.txt

# Run migrations
echo "🔄 Running migrations..."
python manage.py migrate --settings=project.settings_production

# Collect static files
echo "📦 Collecting static files..."
python manage.py collectstatic --settings=project.settings_production --noinput

# Set proper permissions
echo "🔒 Setting permissions..."
sudo chown -R www-data:www-data /var/www/yvanietec
sudo chmod -R 755 /var/www/yvanietec

# Start the service
echo "▶️ Starting service..."
sudo systemctl start yvanietec

# Check service status
echo "📊 Checking service status..."
sudo systemctl status yvanietec

echo "✅ Update completed successfully!"
