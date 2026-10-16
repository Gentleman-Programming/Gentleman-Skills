---
name: docker
description: >
  Docker and Docker Compose patterns for development and production.
  Trigger: When writing Dockerfiles, when using Docker Compose, when containerizing apps, when debugging containers.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when:
- Writing or optimizing Dockerfiles
- Setting up Docker Compose for local development
- Multi-stage builds for production images
- Debugging container issues
- Configuring health checks, volumes, or networking

## Critical Patterns

- **Multi-stage builds are required for production**: compile in a builder stage,
  ship only the binary in a minimal runtime stage (single-stage images hit 800MB+).
- **Order layers by change frequency**: system deps first, then package manifests
  and install, then source code — so dependency layers stay cached.
- **Install dependencies before copying source**: copy manifests, install, then
  copy the code; copying everything first rebuilds deps on every code change.
- **Pin image versions**: never use the `latest` tag in production
  (e.g., `node:22-alpine`, not `node:latest`).
- **Run as a non-root user**: create a dedicated user/group and set `USER` in the
  final stage.
- **The Docker socket is root-equivalent**: `/var/run/docker.sock` lets anyone
  talking to it start containers and control the daemon host. Don't mount it
  into containers that don't need it, and remember that adding a user to the
  `docker` group is effectively granting root on that host.
- **No secrets in the image**: pass credentials at runtime (`-e` or Docker
  secrets), never bake them into `ENV`.
- **Health checks gate dependencies**: define a healthcheck on dependent services
  and wire them with `depends_on: condition: service_healthy`.

## Dockerfile Best Practices

### Multi-Stage Build (REQUIRED for production)

```dockerfile
# GOOD: Multi-stage build
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server

FROM alpine:3.20
RUN apk --no-cache add ca-certificates
COPY --from=builder /server /server
EXPOSE 8080
CMD ["/server"]
```

```dockerfile
# BAD: Single stage, large image
FROM golang:1.24
WORKDIR /app
COPY . .
RUN go build -o server ./cmd/server
CMD ["./server"]
# Result: 800MB+ image with build tools
```

### Layer Optimization

```dockerfile
# GOOD: Layers ordered by change frequency
FROM node:22-alpine
WORKDIR /app

# 1. System deps (rarely changes)
RUN apk add --no-cache tini

# 2. Package manifest (changes on dep update)
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

# 3. Source code (changes often)
COPY . .

ENTRYPOINT ["tini", "--"]
CMD ["pnpm", "start"]
```

### Security: Non-Root User

```dockerfile
# GOOD: Run as non-root
FROM node:22-alpine
RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY --chown=appuser:appgroup . .
USER appuser
CMD ["node", "server.js"]
```

## Docker Compose

### Dev Environment

```yaml
services:
  app:
    build:
      context: .
      target: builder
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://postgres:secret@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: secret
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

## Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

## Debugging Containers

```bash
docker exec -it <container> sh
docker logs -f <container>
docker inspect <container>
docker stats <container>
docker cp <container>:/app/logs ./logs
```

## Anti-Patterns

### Don't: Use `latest` tag in production
```dockerfile
# BAD
FROM node:latest
# GOOD
FROM node:22-alpine
```

### Don't: Copy everything then install
```dockerfile
# BAD: Rebuilds deps on every code change
COPY . .
RUN npm install
# GOOD: Install deps first (cached layer)
COPY package*.json ./
RUN npm ci
COPY . .
```

### Don't: Store secrets in image
```dockerfile
# BAD
ENV API_KEY=sk-1234567890
# GOOD: Pass at runtime with -e or Docker secrets
```

## Code Examples

### Example 1: Production Multi-Stage Dockerfile

```dockerfile
# Builder stage: compile a static binary.
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server

# Runtime stage: minimal image, non-root user.
FROM alpine:3.20
RUN apk --no-cache add ca-certificates \
  && addgroup -g 1001 appgroup \
  && adduser -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY --from=builder /server /server
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
CMD ["/server"]
```

### Example 2: Docker Compose Dev Environment

```yaml
services:
  app:
    build:
      context: .
      target: builder
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://postgres:secret@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: secret
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

## References

- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Hadolint](https://github.com/hadolint/hadolint)
- [Dive](https://github.com/wagoodman/dive) — image layer explorer
