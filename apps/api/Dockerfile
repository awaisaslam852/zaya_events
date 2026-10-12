FROM node:20-bookworm-slim AS build
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate
WORKDIR /repo
COPY pnpm-workspace.yaml package.json tsconfig.base.json ./
COPY apps/api ./apps/api
RUN pnpm install --filter @zaya/api --frozen-lockfile=false || pnpm install --filter @zaya/api
WORKDIR /repo/apps/api
RUN pnpm exec prisma generate
RUN pnpm exec tsc -p tsconfig.json

FROM node:20-bookworm-slim AS runner
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate
ENV NODE_ENV=production
WORKDIR /repo
COPY pnpm-workspace.yaml package.json ./
COPY apps/api/package.json apps/api/package.json
COPY --from=build /repo/node_modules /repo/node_modules
COPY --from=build /repo/apps/api/node_modules /repo/apps/api/node_modules
COPY --from=build /repo/apps/api/dist apps/api/dist
COPY --from=build /repo/apps/api/prisma apps/api/prisma
WORKDIR /repo/apps/api
RUN mkdir -p uploads
EXPOSE 4000
CMD ["sh", "-c", "pnpm exec prisma migrate deploy && node dist/index.js"]
