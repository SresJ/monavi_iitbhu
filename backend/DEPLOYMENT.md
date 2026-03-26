# Deployment Guide: Clinical Dashboard API on DigitalOcean Ubuntu VM

## Prerequisites

- DigitalOcean account
- MongoDB Atlas account (or self-hosted MongoDB)
- Firebase project with service account
- OpenAI API key

---

## 1. Create DigitalOcean Droplet

1. Log in to DigitalOcean and click **Create > Droplets**
2. Choose configuration:
   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Minimum 4GB RAM / 2 vCPUs (ML models require memory)
   - **Region**: Choose closest to your users
   - **Authentication**: SSH keys (recommended)
3. Click **Create Droplet**
4. Note your droplet's **IPv4 address** (e.g., `143.198.xxx.xxx`)

---

## 2. Initial Server Setup

SSH into your droplet:

```bash
ssh root@YOUR_IPV4_ADDRESS
```

### Update system packages

```bash
apt update && apt upgrade -y
```

### Install required system packages

```bash
apt install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    git \
    nginx \
    build-essential \
    cmake \
    ffmpeg \
    tesseract-ocr \
    curl \
    wget
```

---

## 3. Clone and Setup Application

```bash
cd ~

# Clone your repository
git clone https://github.com/your-username/your-repo.git clinical_note_backend
cd ~/clinical_note_backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

---

## 4. Build Whisper.cpp

```bash
cd ~/clinical_note_backend/whisper/whisper.cpp

# Build whisper.cpp
mkdir -p build && cd build
cmake ..
make -j$(nproc)

# Download whisper model
cd ../models
./download-ggml-model.sh medium
```

---

## 5. Configure Environment Variables

```bash
cd ~/clinical_note_backend

# Create .env file
nano .env
```

Add the following content (replace `YOUR_IPV4_ADDRESS` with your actual IP):

```env
# MongoDB Configuration
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority
MONGODB_DB_NAME=clinical_dashboard

# Firebase Configuration
FIREBASE_SERVICE_ACCOUNT_PATH=/root/clinical_note_backend/firebase-service-account.json

# OpenAI Configuration
OPENAI_API_KEY=sk-your-openai-api-key

# Application Settings
APP_NAME=Clinical Dashboard API
APP_VERSION=1.0.0
DEBUG=False

# CORS Settings - Allow all origins
CORS_ORIGINS=["*"]

# File Upload Settings
UPLOAD_DIR=/root/clinical_note_backend/uploads
MAX_FILE_SIZE=10485760

# ML Pipeline Settings
DATA_DIR=/root/clinical_note_backend/data
WHISPER_MODEL_PATH=/root/clinical_note_backend/whisper/whisper.cpp/models/ggml-medium.bin
WHISPER_CLI_PATH=/root/clinical_note_backend/whisper/whisper.cpp/build/bin/whisper-cli
```

### Upload Firebase Service Account

From your local machine:

```bash
scp firebase-service-account.json root@YOUR_IPV4_ADDRESS:/root/clinical_note_backend/
```

### Create uploads directory

```bash
mkdir -p ~/clinical_note_backend/uploads
chmod 755 ~/clinical_note_backend/uploads
```

---

## 6. Create Systemd Service

```bash
sudo nano /etc/systemd/system/clinical-api.service
```

Add the following content:

```ini
[Unit]
Description=Clinical Dashboard FastAPI Application
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/root/clinical_note_backend
Environment="PATH=/root/clinical_note_backend/venv/bin"
EnvironmentFile=/root/clinical_note_backend/.env
ExecStart=/root/clinical_note_backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable clinical-api
sudo systemctl start clinical-api

# Check status
sudo systemctl status clinical-api

# View logs
sudo journalctl -u clinical-api -f
```

---

## 7. Configure Nginx Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/clinical-api
```

Add the following content (replace `YOUR_IPV4_ADDRESS` with your actual IP):

```nginx
server {
    listen 80;
    server_name YOUR_IPV4_ADDRESS;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        client_max_body_size 15M;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/clinical-api /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

---

## 8. Configure Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw enable
sudo ufw status
```

---

## 9. Verify Deployment

Test the API (replace `YOUR_IPV4_ADDRESS` with your actual IP):

```bash
# Health check
curl http://YOUR_IPV4_ADDRESS/health

# API docs - open in browser
http://YOUR_IPV4_ADDRESS/docs
```

---

## Maintenance Commands

### Restart the application

```bash
sudo systemctl restart clinical-api
```

### View logs

```bash
# Real-time logs
sudo journalctl -u clinical-api -f

# Last 100 lines
sudo journalctl -u clinical-api -n 100
```

### Update application

```bash
cd ~/clinical_note_backend
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart clinical-api
```

### Check service status

```bash
sudo systemctl status clinical-api
sudo systemctl status nginx
```

---

## Troubleshooting

### Application won't start

```bash
# Check logs
sudo journalctl -u clinical-api -n 50 --no-pager

# Test manually
cd ~/clinical_note_backend
source venv/bin/activate
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Port already in use

```bash
sudo lsof -i :8000
sudo kill -9 <PID>
```

### Permission denied errors

```bash
sudo chown -R root:root ~/clinical_note_backend
chmod -R 755 ~/clinical_note_backend
```

### Nginx 502 Bad Gateway

```bash
# Check if app is running
sudo systemctl status clinical-api

# Check nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Out of memory (ML models)

Add swap space:

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## Security Recommendations

1. **Keep system updated**: `sudo apt update && sudo apt upgrade -y`
2. **Use strong SSH keys** and disable password authentication
3. **Set up fail2ban**: `sudo apt install fail2ban`
4. **Regular backups** of `.env` and uploaded files
5. **Monitor logs** for suspicious activity
6. **Use environment variables** for all secrets (never commit to git)
7. **CORS_ORIGINS** is set to allow all origins (`["*"]`)

---

## Optional: Using Docker

Create a `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ffmpeg \
    tesseract-ocr \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN cd whisper/whisper.cpp && mkdir -p build && cd build && cmake .. && make -j$(nproc)

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Run with:

```bash
docker build -t clinical-api .
docker run -d -p 8000:8000 --env-file .env clinical-api
```
