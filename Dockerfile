# Use a slim, secure base image
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy package.json first to leverage Docker caching
COPY package.json ./

# Install dependencies securely
RUN npm install --production

# Copy the rest of the application code
COPY server.js ./

# SECURITY FEATURE: Do not run the container as root
USER node

# Expose the application port
EXPOSE 3000

# Start the application
CMD [ "node", "server.js" ]
