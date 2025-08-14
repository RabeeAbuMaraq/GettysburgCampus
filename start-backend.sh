#!/bin/bash

# Gettysburg Campus Backend Startup Script
echo "🚀 Starting Gettysburg Campus Backend Server..."

# Navigate to the backend directory
cd "/Volumes/A009/GettysburgCampus/GettysburgCampus-Backend"

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start the development server
echo "🔥 Starting server on http://10.0.0.204:3000"
echo "📧 SMTP: Brevo (smtp-relay.brevo.com)"
echo "🔐 JWT: Configured"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

npm run dev 