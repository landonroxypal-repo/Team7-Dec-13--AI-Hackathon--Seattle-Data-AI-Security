#!/bin/bash

# LearnMap.ai AWS EC2 Setup Script
# Run: chmod +x setup-aws.sh && ./setup-aws.sh

echo "🚀 Starting LearnMap.ai AWS deployment..."

# Update system
echo "📦 Installing dependencies..."
sudo apt update
sudo apt install -y nodejs npm git curl

# Clone repo
echo "📥 Cloning repository..."
cd ~
git clone https://github.com/YOUR-USERNAME/Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security.git
cd Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security/Team\ 7

# Install app dependencies
echo "🔧 Installing npm packages..."
npm install
cd backend && npm install && cd ..

# Build frontend
echo "🏗️  Building frontend..."
npm run build

# Install PM2 globally
echo "📌 Installing PM2 process manager..."
sudo npm install -g pm2

# Create frontend server script
echo "⚙️  Creating frontend server..."
cat > /tmp/server.js << 'EOF'
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 5173;
const DIST_DIR = '/home/ubuntu/Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security/Team 7/dist';

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
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpeg'
      };
      res.writeHead(200, { 'Content-Type': types[ext] || 'text/plain' });
      res.end(data);
    }
  });
});

server.listen(PORT, 'localhost', () => {
  console.log(`✅ Frontend server running at http://localhost:${PORT}/`);
});
EOF

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Update the API key in ~/Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security/Team\ 7/backend/.env"
echo "2. Run: pm2 start 'node server.js' --cwd ~/Team7-Dec-13--AI-Hackathon--Seattle-Data-AI-Security/Team\ 7/backend --name backend"
echo "3. Run: pm2 start 'node /tmp/server.js' --name frontend"
echo "4. Run: pm2 startup && pm2 save"
echo "5. Visit: http://YOUR-INSTANCE-IP:5173"
echo ""
echo "To check status: pm2 status"
echo "To view logs: pm2 logs"
