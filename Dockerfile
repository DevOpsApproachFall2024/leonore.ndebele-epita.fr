FROM node:22 AS deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

FROM node:22 AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM node:22 AS base
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY --from=builder /app/.next ./.next

EXPOSE 3000

FROM base as production
