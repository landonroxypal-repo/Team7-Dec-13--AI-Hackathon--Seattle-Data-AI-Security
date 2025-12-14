# Deploy LearnMap.ai to AWS EC2

## Quick Setup (5-10 minutes)

### Step 1: Launch EC2 Instance
```bash
# In AWS Console:
1. Go to EC2 → Launch Instance
2. Select: Ubuntu 22.04 LTS (free tier)
3. Instance Type: t2.small (or t2.micro)
4. Security Group: Allow ports 80, 443, 5000, 5173
5. Launch and save your key pair (.pem file)
```

### Step 2: Connect & Deploy
```bash
# On your local machine:
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR-INSTANCE-IP

# On the EC2 instance, run:
curl -O https://raw.githubusercontent.com/YOUR-REPO/Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security/main/Team\ 7/setup-aws.sh
chmod +x setup-aws.sh
./setup-aws.sh
```

### Step 3: Set API Key
```bash
cd ~/learnmap-ai/backend
nano .env
# Update GOOGLE_API_KEY with your key, save (Ctrl+O, Enter, Ctrl+X)
```

### Step 4: Start Services
```bash
pm2 start "node server.js" --cwd ~/learnmap-ai/backend --name backend
pm2 start "node /tmp/server.js" --name frontend
pm2 startup
pm2 save
```

### Step 5: Access Your App
- Get your instance's public IP from AWS Console
- Visit: `http://YOUR-INSTANCE-IP:5173`

---

## Setup Script (setup-aws.sh)
```bash
#!/bin/bash

# Update system
sudo apt update
sudo apt install -y nodejs npm git curl

# Clone repo
cd ~
git clone https://github.com/YOUR-REPO/Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security.git
cd Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security/Team\ 7

# Install dependencies
npm install
cd backend && npm install && cd ..

# Build frontend
npm run build

# Install PM2 globally
sudo npm install -g pm2

# Create frontend server script
cat > /tmp/server.js << 'EOF'
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 5173;
const DIST_DIR = process.env.HOME + '/learnmap-ai/dist';

const server = http.createServer((req, res) => {
  let filePath = path.join(DIST_DIR, req.url === '/' ? 'index.html' : req.url);
  
  fs.readFile(filePath, (err, data) => {
    if (err) {
      fs.readFile(path.join(DIST_DIR, 'index.html'), (err2, data2) => {
        if (err2) {
          res.writeHead(404);
          res.end('Not found');
        } else {
          res.writeHead(200, { 'Content-Type': 'text/html' });
          res.end(data2);
        }
      });
    } else {
      const ext = path.extname(filePath);
      const types = {
        '.html': 'text/html',
        '.js': 'application/javascript',
        '.css': 'text/css',
        '.json': 'application/json'
      };
      res.writeHead(200, { 'Content-Type': types[ext] || 'text/plain' });
      res.end(data);
    }
  });
});

server.listen(PORT, 'localhost', () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});
EOF

echo "✅ Setup complete! Now run the Step 3-4 commands above."
```

---

## Production Setup with Domain

### Add Elastic IP (Static IP)
```bash
# In AWS Console:
1. EC2 → Elastic IPs → Allocate
2. Associate with your instance
```

### Get SSL Certificate (Free)
```bash
# In AWS Console:
1. Certificate Manager → Request Certificate
2. Use your domain
3. Validate via DNS
```

### Add Load Balancer (Optional but Recommended)
```bash
# In AWS Console:
1. EC2 → Load Balancers → Create ALB
2. Target Group → Instance on port 5173
3. Attach SSL certificate
4. Update Route 53 to point to ALB
```

---

## Cost Estimate
- **t2.micro**: Free tier (if eligible)
- **t2.small**: ~$15/month
- **Domain (Route 53)**: $12/year
- **Data transfer**: ~$0.12/GB

**Total**: $15-20/month

---

## Troubleshooting

### Port Already in Use
```bash
lsof -i :5173
kill -9 <PID>
```

### Check Logs
```bash
pm2 logs backend
pm2 logs frontend
```

### Restart Services
```bash
pm2 restart all
pm2 status
```

---

## Next Steps for Judges

1. Share your instance's public IP
2. They visit: `http://YOUR-IP:5173`
3. Demo the full app:
   - Select topic → Take quiz
   - View results → See roadmap
   - Download PDF
4. Explain the tech stack and architecture

**Your app is now live on AWS! 🚀**
