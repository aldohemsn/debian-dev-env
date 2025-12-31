# Debian Development Environment

This is a minimal Debian-based development environment, suitable for deployment on Railway or use as a local dev container.

## Usage

To build the image:

```bash
docker build -t debian-dev .
```

To run the container:

```bash
docker run -d --name my-dev-env debian-dev
```

## Content

- Base: `debian:stable-slim`
- Tools: curl, git, vim, wget, build-essential
