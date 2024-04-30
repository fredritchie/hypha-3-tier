#!/bin/bash
set -ex

sudo echo "\$nrconf{restart} = 'a'" >> /etc/needrestart/needrestart.conf
# Update package lists
sudo apt-get update

# Install Node.js and npm
sudo apt-get install -y nodejs 
sudo apt-get install -y npm

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo apt-get install -y nginx

# Install Express.js dependencies
cd /var/www/html
npm install express aws-sdk

# Configure Nginx as a reverse proxy for your Node.js app
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Restart Nginx to apply the changes
sudo systemctl restart nginx

# Create the Express.js app file
sudo tee /var/www/html/app.js > /dev/null <<EOF
const express = require('express');
const app = express();
const AWS = require('aws-sdk');
const fs = require('fs');

AWS.config.region = 'ap-south-1';
const lambda = new AWS.Lambda({ region: 'ap-south-1' });

app.use(express.json());

app.post('/submit', (req, res) => {
  const firstName = req.body.firstName;
  const lastName = req.body.lastName;

  const payload = {
    firstName,
    lastName
  };

  console.log("Payload:", payload);

  const params = {
    FunctionName: 'form',
    InvocationType: 'RequestResponse',
    Payload: JSON.stringify(payload)
  };

  lambda.invoke(params, (err, data) => {
    if (err) {
      console.log(err);
      res.status(500).send({ message: 'Error invoking Lambda function' });
    } else {
      console.log(data);
      res.send({ message: 'Lambda function invoked successfully' });
    }
  });
});

app.listen(3000, () => {
  console.log('Server listening on port 3000');
});

app.get('/', (req, res) => {
  const indexHtml = `
  <!DOCTYPE html>
  <html>
  <head>
    <title>Lambda Form</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f2f2f2;
      }
      .container {
        max-width: 600px;
        margin: 50px auto;
        padding: 20px;
        background-color: #fff;
        border-radius: 8px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
      }
      h1 {
        color: #333;
      }
      form {
        margin-top: 20px;
      }
      label {
        display: block;
        margin-bottom: 5px;
        color: #666;
      }
      input[type="text"] {
        width: 100%;
        padding: 10px;
        margin-bottom: 10px;
        border: 1px solid #ccc;
        border-radius: 4px;
        box-sizing: border-box;
      }
      button {
        padding: 10px 20px;
        background-color: #4CAF50;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
      }
      button:hover {
        background-color: #45a049;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>Welcome to Hypha DevOps Cohorts</h1>
      <h2>Enter your name here</h2>
      <form id="userForm">
        <label for="firstName">First Name:</label>
        <input type="text" id="firstName" name="firstName">
        <label for="lastName">Last Name:</label>
        <input type="text" id="lastName" name="lastName">
        <button type="button" onclick="submitForm()">Submit</button>
      </form>
    </div>
    <div id="message" style="text-align: center; color: green; font-weight: bold;"></div> <!-- Updated line -->
    <script>
      function submitForm() {
        const formData = new FormData(document.getElementById('userForm'));
        fetch('/submit', {
          method: 'POST',
          body: JSON.stringify(Object.fromEntries(formData)),
          headers: { 'Content-Type': 'application/json' }
        })
        .then(response => response.json())
        .then(data => {
          console.log(data);
          // Clear form fields
          document.getElementById('userForm').reset();
          // Display success message
          document.getElementById('message').innerHTML = 'Form submitted successfully!';
        })
        .catch(error => console.error(error));
      }
    </script>
  </body>
  </html>
  `;
  res.send(indexHtml);
}); 
EOF

npm install express
npm install aws-sdk 
# Run the Express.js app using PM2
pm2 start /var/www/html/app.js

# Save PM2 process list to automatically start at boot
pm2 save

# Display server status
sudo systemctl status nginx
pm2 status
