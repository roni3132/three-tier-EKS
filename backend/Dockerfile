
FROM node:22.14.0-slim
# Set working directory
WORKDIR /app
# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production
# Copy the rest of the application files
COPY . .
# Start the application
CMD ["node", "index.js"]