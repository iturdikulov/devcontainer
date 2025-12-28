FROM base AS node_builder

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

FROM debian:trixie-slim

# Setup a non-root user
RUN groupadd --system --gid 999 nonroot \
 && useradd --system --gid 999 --uid 999 --create-home nonroot

# Copy node & modules
COPY --from=base /usr/local/bin/node /usr/local/bin/
COPY --from=base /usr/local/include/node /usr/local/include/node
COPY --from=base /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node_builder --chown=nonroot:nonroot /app /app

# Use the non-root user to run our application
USER nonroot

# Use `/app` as the working directory
WORKDIR /app
