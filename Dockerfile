# Build Stage
FROM node:18-alpine AS base
#RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR /app
COPY package*.json pnpm-lock.yaml ./
RUN npm install -g pnpm
RUN pnpm install

# builder
FROM base as builder
WORKDIR /app
COPY . .
RUN pnpm run build

# production
FROM base as production

WORKDIR /app
ENV NODE_ENV=production

RUN addgroup -g 1001 -S pretrip
RUN adduser -S pretrip -u 1001
USER pretrip

COPY --from=builder --chown=pretrip:pretrip /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

CMD ["pnpm", "run", "start"]

# development
FROM base as development
WORKDIR /app
ENV NODE_ENV=development
RUN pnpm install 
COPY . .
CMD ["pnpm", "run", "dev"]
