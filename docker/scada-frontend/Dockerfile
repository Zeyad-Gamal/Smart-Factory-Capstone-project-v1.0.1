# Build Stage
FROM node:22-alpine AS builder

WORKDIR /app
COPY Full-SCADA-system/ ./
RUN npm ci
RUN npm run build


# Runtime Stage
FROM nginx:alpine

COPY docker/scada-frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

COPY docker/scada-frontend/env.sh /docker-entrypoint.d/env.sh
RUN chmod +x /docker-entrypoint.d/env.sh

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]