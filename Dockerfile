# Base image
FROM node:18.8-alpine AS base

# Builder stage
FROM base AS builder

WORKDIR /home/node/app

# Copy package.json and yarn.lock separately to leverage Docker cache
COPY package*.json ./
COPY yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application files
COPY . .

# Build the application
RUN yarn build

# Runtime stage
FROM base AS runtime

ENV NODE_ENV=production
ENV PAYLOAD_CONFIG_PATH=dist/payload.config.js

WORKDIR /home/node/app

# Copy only the necessary files for production
COPY package*.json ./
COPY yarn.lock ./

# Install only production dependencies
RUN yarn install --production --frozen-lockfile

# Copy build artifacts from builder stage
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/build ./build

EXPOSE 3000

CMD ["node", "dist/server.js"]
