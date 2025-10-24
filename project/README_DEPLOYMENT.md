# Yvanietec Website Deployment Guide

This guide will help you deploy your Django website to a DigitalOcean droplet with your GoDaddy domain.

## Prerequisites

- DigitalOcean droplet (Ubuntu 22.04 recommended)
- GoDaddy domain name
- SSH access to your droplet
- Basic knowledge of Linux commands

## Step 1: Prepare Your Domain

1. **Point your domain to DigitalOcean:**
   - Log into your GoDaddy account
   - Go to your domain's DNS settings
   - Add an A record pointing to your DigitalOcean droplet's IP address
   - Example: `@` → `your-droplet-ip`
   - Example: `www` → `your-droplet-ip`

2. **Wait for DNS propagation (can take up to 48 hours)**

## Step 2: Connect to Your Droplet

```bash
ssh root@your-droplet-ip
```

## Step 3: Upload Your Code

### Option A: Using Git (Recommended)
```bash
# On your droplet
cd /var/www
git clone https://github.com/yourusername/yvanietec.git
cd yvanietec
```

### Option B: Using SCP
```bash
# From your local machine
scp -r yvanietec/project/* root@your-droplet-ip:/var/www/yvanietec/
```

## Step 4: Run the Deployment Script

```bash
cd /var/www/yvanietec
chmod +x deploy.sh
./deploy.sh
```

The script will:
- Update system packages
- Install required software (Python, Nginx, PostgreSQL)
- Set up virtual environment
- Install Python dependencies
- Configure database
- Set up Nginx
- Configure systemd service
- Set up firewall

## Step 5: Configure Environment Variables

Edit the `.env` file with your actual values:

```bash
nano .env
```

Replace the placeholder values:
- `SECRET_KEY`: Generate a new Django secret key
- `ALLOWED_HOSTS`: Your domain name and server IP
- `DATABASE_URL`: Your PostgreSQL connection string

## Step 6: Update Nginx Configuration

Edit the Nginx configuration to use your domain:

```bash
sudo nano /etc/nginx/sites-available/yvanietec
```

Replace `your-domain.com` with your actual domain name.

## Step 7: Test and Restart Services

```bash
# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check Django service status
sudo systemctl status yvanietec

# View logs if needed
sudo journalctl -u yvanietec -f
```

## Step 8: SSL Certificate (Optional but Recommended)

Install Certbot for free SSL certificates:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

After SSL setup, uncomment the HTTPS sections in `nginx.conf`.

## Step 9: Final Configuration

1. **Create a superuser:**
```bash
cd /var/www/yvanietec
source venv/bin/activate
python manage.py createsuperuser --settings=project.settings_production
```

2. **Test your website:**
   - Visit `http://your-domain.com`
   - Check admin panel at `http://your-domain.com/admin`

## Maintenance

### Updating Your Website

Use the update script:
```bash
cd /var/www/yvanietec
chmod +x update.sh
./update.sh
```

### Useful Commands

```bash
# Check service status
sudo systemctl status yvanietec

# View logs
sudo journalctl -u yvanietec -f

# Restart service
sudo systemctl restart yvanietec

# Check Nginx status
sudo systemctl status nginx

# View Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### Backup Database

```bash
cd /var/www/yvanietec
source venv/bin/activate
python manage.py dumpdata --settings=project.settings_production > backup_$(date +%Y%m%d_%H%M%S).json
```

## Troubleshooting

### Common Issues

1. **Website not loading:**
   - Check if services are running: `sudo systemctl status yvanietec nginx`
   - Check firewall: `sudo ufw status`
   - Check logs: `sudo journalctl -u yvanietec -f`

2. **Static files not loading:**
   - Run: `python manage.py collectstatic --settings=project.settings_production`
   - Check Nginx configuration
   - Check file permissions

3. **Database connection issues:**
   - Check PostgreSQL status: `sudo systemctl status postgresql`
   - Verify database credentials in `.env`
   - Check database exists: `sudo -u postgres psql -l`

### Security Checklist

- [ ] Changed default Django secret key
- [ ] Set DEBUG=False in production
- [ ] Configured ALLOWED_HOSTS
- [ ] Set up SSL certificate
- [ ] Configured firewall
- [ ] Set proper file permissions
- [ ] Regular security updates

## Support

If you encounter issues:
1. Check the logs: `sudo journalctl -u yvanietec -f`
2. Verify all services are running
3. Check file permissions
4. Ensure DNS is properly configured

Your website should now be live at `http://your-domain.com`!
