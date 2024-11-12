FROM node:20-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
COPY pnpm-workspace.yaml ./
COPY packages/stack-sc/package.json ./packages/stack-sc/
COPY packages/stack-ui/package.json ./packages/stack-ui/
COPY packages/stack-emails/package.json ./packages/stack-emails/
COPY packages/stack/package.json ./packages/stack/
COPY packages/init-stack/package.json ./packages/init-stack/
COPY packages/stack-shared/package.json ./packages/stack-shared/
COPY apps/backend/package.json ./apps/backend/
COPY apps/dashboard/package.json ./apps/dashboard/
RUN pnpm install --frozen-lockfile

FROM base AS dep
RUN npm install -g pnpm
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/packages/stack-sc/node_modules ./packages/stack-sc/node_modules
COPY --from=deps /app/packages/stack-ui/node_modules ./packages/stack-ui/node_modules
COPY --from=deps /app/packages/stack-emails/node_modules ./packages/stack-emails/node_modules
COPY --from=deps /app/packages/stack/node_modules ./packages/stack/node_modules
COPY --from=deps /app/packages/init-stack/node_modules ./packages/init-stack/node_modules
COPY --from=deps /app/packages/stack-shared/node_modules ./packages/stack-shared/node_modules
COPY --from=deps /app/apps/backend/node_modules ./apps/backend/node_modules
COPY --from=deps /app/apps/dashboard/node_modules ./apps/dashboard/node_modules

COPY timestamp.txt ./timestamp.txt

COPY package.json pnpm-lock.yaml* ./
COPY pnpm-workspace.yaml ./
COPY turbo.json ./
COPY LICENSE ./

COPY packages ./packages
COPY apps ./apps
COPY docs ./docs
COPY eslint-configs ./eslint-configs

RUN pnpm install --frozen-lockfile

ARG NEXT_PUBLIC_SENTRY_DSN
ARG NEXT_PUBLIC_SENTRY_ORG
ARG NEXT_PUBLIC_SENTRY_PROJECT
ARG SENTRY_AUTH_TOKEN

ENV NEXT_PUBLIC_SENTRY_DSN=${NEXT_PUBLIC_SENTRY_DSN}
ENV NEXT_PUBLIC_SENTRY_ORG=${NEXT_PUBLIC_SENTRY_ORG}
ENV NEXT_PUBLIC_SENTRY_PROJECT=${NEXT_PUBLIC_SENTRY_PROJECT}
ENV SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN}

FROM dep AS builder-backend

ARG STACK_SERVER_SECRET

ENV STACK_SERVER_SECRET=${STACK_SERVER_SECRET}

RUN pnpm run build:backend

FROM dep AS builder-dashboard

ARG NEXT_PUBLIC_STACK_URL
ARG NEXT_PUBLIC_STACK_PROJECT_ID
ARG NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY
ARG STACK_SECRET_SERVER_KEY
ARG NEXT_PUBLIC_STACK_SVIX_SERVER_URL
ARG NEXT_PUBLIC_STACK_HEAD_TAGS

ENV NEXT_PUBLIC_STACK_URL=${NEXT_PUBLIC_STACK_URL}
ENV NEXT_PUBLIC_STACK_PROJECT_ID=${NEXT_PUBLIC_STACK_PROJECT_ID}
ENV NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=${NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY}
ENV STACK_SECRET_SERVER_KEY=${STACK_SECRET_SERVER_KEY}
ENV NEXT_PUBLIC_STACK_SVIX_SERVER_URL=${NEXT_PUBLIC_STACK_SVIX_SERVER_URL}
ENV NEXT_PUBLIC_STACK_HEAD_TAGS=${NEXT_PUBLIC_STACK_HEAD_TAGS}

RUN pnpm run build:dashboard

FROM base AS backend

WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

USER nextjs

COPY --from=builder-backend /app/apps/backend/.next/standalone ./
COPY --from=builder-backend /app/apps/backend/.next/static ./apps/backend/.next/static
COPY apps/backend/LICENSE ./

CMD PORT=8102 node ./apps/backend/server.js

FROM base AS dashboard

WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

USER nextjs

COPY --from=builder-dashboard /app/apps/dashboard/.next/standalone ./
COPY --from=builder-dashboard /app/apps/dashboard/.next/static ./apps/dashboard/.next/static
COPY --from=builder-dashboard /app/apps/dashboard/public ./apps/dashboard/public
COPY apps/dashboard/LICENSE ./apps/

CMD PORT=8101 node ./apps/dashboard/server.js