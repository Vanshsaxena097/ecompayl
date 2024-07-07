FROM node:18.8-alpine AS base

FROM base AS builder

WORKDIR /home/node/app
COPY package*.json ./

# Add this line to set the PAYLOAD_SECRET during build
ENV PAYLOAD_SECRET=your_secret_key_here

COPY . .
RUN yarn install
RUN yarn build

FROM base AS runtime

ENV NODE_ENV=production
ENV PAYLOAD_CONFIG_PATH=dist/payload.config.js
# Add this line to set the PAYLOAD_SECRET for runtime
ENV PAYLOAD_SECRET=your123
ENV DATABASE_URI=mongodb+srv://vanshsaxena2024:Vanshsaxena@cluster0.rxdajgm.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0

WORKDIR /home/node/app
COPY package*.json  ./
COPY yarn.lock ./

RUN yarn install --production
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/build ./build

EXPOSE 3000

CMD ["node", "dist/server.js"]