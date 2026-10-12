FROM node:20-bookworm-slim AS build
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml* ./
COPY apps/vendor-web/package.json apps/vendor-web/package.json
RUN pnpm install --filter @zaya/vendor-web --prod=false
COPY apps/vendor-web apps/vendor-web
ARG VITE_API_URL=http://localhost:4000
ENV VITE_API_URL=$VITE_API_URL
WORKDIR /app/apps/vendor-web
RUN pnpm build

FROM nginx:1.27-alpine
COPY apps/vendor-web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/apps/vendor-web/dist /usr/share/nginx/html
EXPOSE 80
