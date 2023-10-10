FROM node:16-alpine AS builder

RUN mkdir -p /nuxt-app
WORKDIR /nuxt-app
COPY . .

RUN npm ci && npm cache clean --force
RUN npm run build


FROM keymetrics/pm2:16-alpine

RUN mkdir -p /nuxt-app/.output

WORKDIR /nuxt-app/.output

COPY --from=builder /nuxt-app/.output .
COPY ./ecosystem.config.js /nuxt-app

WORKDIR /nuxt-app

ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

EXPOSE 3000 

ENTRYPOINT ["pm2-runtime", "start", "/nuxt-app/ecosystem.config.js"]

# Build Image
# docker build -t nuxt-app .
# Run Image
# docker run -d -p 3000:3000 nuxt-app