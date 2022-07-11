# 🛠 Set up PNPM to be used from container
FROM node:16.15-bullseye as setup
USER root
RUN corepack enable && corepack prepare pnpm@7.5.0 --activate
USER node
RUN pnpm config set store-dir /home/node/.pnpm-store
WORKDIR /home/node/project

FROM setup as success
# ✅ `pnpm fetch` succeeds when package.json is present with lockfile
COPY pnpm-*.yaml package.json ./
RUN pnpm fetch
RUN pnpm install --offline --frozen-lockfile
COPY . .
RUN pnpm build
CMD [ "pnpm", "start" ]

FROM setup as error
# ❌ `pnpm fetch` fails without package.json when `@parcel/watcher install` is invoked (node-gyp issue?)
COPY pnpm-*.yaml ./
RUN pnpm fetch
RUN pnpm install --offline --frozen-lockfile
RUN pnpm build
CMD [ "pnpm", "start" ]
