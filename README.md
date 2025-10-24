# Yvanietec - Company Website

A modern, responsive company website built with Django featuring a cyberpunk-inspired design.

---

## 🚀 **Want to Deploy? Start Here!**

### For Windows Users (Recommended):
👉 **[GET_STARTED.md](GET_STARTED.md)** - Complete deployment guide in 30 minutes

### Quick Reference:
👉 **[SIMPLE_GUIDE.md](SIMPLE_GUIDE.md)** - One-page deployment guide

### All Documentation:
📚 **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** - Complete documentation index

---

## Features

- 🎨 Modern cyberpunk UI design
- 📱 Fully responsive layout
- ⚡ Fast loading with optimized static files
- 🔒 Production-ready security settings
- 🚀 Easy deployment scripts
- 📊 Admin panel for content management

## Technology Stack

- **Backend**: Django 5.2
- **Frontend**: HTML5, CSS3, JavaScript
- **Server**: Gunicorn + Nginx
- **Database**: PostgreSQL (production) / SQLite (development)
- **Static Files**: WhiteNoise

## Quick Start (Development)

1. **Clone the repository:**
```bash
git clone <your-repo-url>
cd yvanietec/project
```

2. **Set up virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Run migrations:**
```bash
python manage.py migrate
```

5. **Create superuser:**
```bash
python manage.py createsuperuser
```

6. **Run development server:**
```bash
python manage.py runserver
```

7. **Visit the website:**
   - Main site: http://localhost:8000
   - Admin panel: http://localhost:8000/admin

## 🚀 Production Deployment

We've created comprehensive deployment guides for hosting on DigitalOcean with your GoDaddy domain!

### 📚 Deployment Documentation

| Guide | Description | When to Use |
|-------|-------------|-------------|
| **[README_HOSTING.md](README_HOSTING.md)** | 🎯 **START HERE** - Overview & guide selector | First time deploying |
| **[QUICKSTART.md](QUICKSTART.md)** | ⚡ Fast 15-minute deployment | Quick deployment |
| **[PRE_DEPLOYMENT_CHECKLIST.md](PRE_DEPLOYMENT_CHECKLIST.md)** | ✅ Make sure you're ready | Before deploying |
| **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** | 📖 Complete step-by-step guide | Detailed walkthrough |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | 🏗️ System architecture & how it works | Understanding the system |

### ⚡ Quick Deploy (3 Steps)

#### 1. Setup (Local Computer - 5 min)
```bash
chmod +x setup.sh
./setup.sh
```
*This configures all deployment files for you!*

#### 2. Configure DNS (GoDaddy - 5 min)
- Log into GoDaddy → Your Domain → DNS
- Add A record: `@` → Your Droplet IP
- Add A record: `www` → Your Droplet IP

#### 3. Deploy (Server - 15 min)
```bash
# SSH to your server
ssh root@YOUR_DROPLET_IP

# Clone and deploy
mkdir -p /var/www && cd /var/www
git clone https://github.com/yvanietec/yvanietec.git yvanietec
cd yvanietec/project
chmod +x deploy.sh
./deploy.sh

# Install SSL
apt install certbot python3-certbot-nginx -y
certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

**Done! Visit `https://yourdomain.com`** 🎉

### 📖 Need Help?

- **New to deployment?** → Start with [PRE_DEPLOYMENT_CHECKLIST.md](PRE_DEPLOYMENT_CHECKLIST.md)
- **Want it fast?** → Follow [QUICKSTART.md](QUICKSTART.md)
- **Want details?** → Read [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Want to understand?** → See [ARCHITECTURE.md](ARCHITECTURE.md)

## Project Structure

```
yvanietec/
├── project/                 # Django project root
│   ├── project/            # Django settings
│   │   ├── settings.py     # Development settings
│   │   └── settings_production.py  # Production settings
│   ├── website/            # Main app
│   ├── templates/          # HTML templates
│   ├── static/             # Static files (CSS, JS, images)
│   ├── media/              # User uploaded files
│   ├── requirements.txt    # Python dependencies
│   ├── deploy.sh           # Deployment script
│   ├── update.sh           # Update script
│   ├── nginx.conf          # Nginx configuration
│   ├── gunicorn.conf.py    # Gunicorn configuration
│   └── yvanietec.service   # Systemd service file
└── README.md               # This file
```

## Configuration

### Environment Variables

Create a `.env` file in the project directory:

```env
SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=your-domain.com,www.your-domain.com
DATABASE_URL=postgresql://username:password@localhost:5432/dbname
```

### Generate Secret Key

```bash
python generate_secret_key.py
```

## Maintenance

### Updating the Website

```bash
cd /var/www/yvanietec
./update.sh
```

### Backup Database

```bash
python manage.py dumpdata > backup_$(date +%Y%m%d_%H%M%S).json
```

### View Logs

```bash
# Django logs
sudo journalctl -u yvanietec -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

## Security Features

- ✅ HTTPS ready (SSL configuration included)
- ✅ Security headers configured
- ✅ CSRF protection enabled
- ✅ XSS protection
- ✅ Content Security Policy
- ✅ Secure cookie settings
- ✅ Firewall configuration

## Support

For deployment issues, check:
1. Service status: `sudo systemctl status yvanietec nginx`
2. Logs: `sudo journalctl -u yvanietec -f`
3. File permissions
4. DNS configuration

## License

This project is proprietary software for Yvanietec company.
