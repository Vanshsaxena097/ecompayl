FROM node:18.8-alpine AS base

ENV PAYLOAD_SECRET=your123
ENV DATABASE_URI=mongodb+srv://vanshsaxena2024:Vanshsaxena@cluster0.rxdajgm.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0

FROM base AS builder

WORKDIR /home/node/app
COPY package*.json ./

COPY . .
RUN yarn install
RUN yarn build

# Ensure TypeScript is installed
RUN yarn add typescript @types/node --dev

# Transpile the payload config file
RUN npx tsc src/payload/payload.config.ts --outDir dist/payload --esModuleInterop --module commonjs

FROM base AS runtime

ENV NODE_ENV=production
ENV PAYLOAD_CONFIG_PATH=dist/payload/payload.config.js

WORKDIR /home/node/app
COPY package*.json  ./
COPY yarn.lock ./

RUN yarn install --production
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/build ./build

EXPOSE 3000

CMD ["node", "dist/server.js"]