
# Stage 1: Dependencies
# This stage installs all the npm dependencies
FROM node:22 AS deps
WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci 
# npm ci is a clean install with no duplicates # install only the dependencies

# Stage 2: Builder
# This stage builds the Next.js application

FROM node:22 AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Stage 3: Base
# This stage sets up the base for the final image

FROM node:22 AS base
WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules

COPY --from=builder /app/package.json ./package.json

COPY --from=builder /app/public ./public

COPY --from=builder /app/.next ./.next

EXPOSE 3000

FROM base as production
CMD ["npm", "run", "start"]

FROM base as development
CMD ["npm", "run", "dev"]
