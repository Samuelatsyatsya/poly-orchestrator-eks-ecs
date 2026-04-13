# Use a lightweight Node.js base image.
FROM node:20-alpine

# Set the working directory inside the container.
WORKDIR /app

# Copy dependency manifest.
COPY package.json ./

# Install production dependencies only.
RUN npm install --omit=dev

# Copy application source.
COPY server.js ./

# Expose the application port.
EXPOSE 3000

# Start the application.
CMD ["npm", "start"]
