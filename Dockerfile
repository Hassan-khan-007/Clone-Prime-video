# ==========================================
# Stage 1: Build the React Application
# ==========================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ==========================================
# Stage 2: Run the App using Node.js
# ==========================================
FROM node:20-alpine

WORKDIR /app

# Install 'serve' globally to serve the static build folder easily
RUN npm install -g serve

# Copy only the production build and package files from builder stage
COPY --from=builder /app/build ./build
COPY package.json package-lock.json ./

# Expose port 3000
EXPOSE 3000

# Start the application on port 3000
CMD ["npx", "serve", "-s", "build", "-l", "3000"]
