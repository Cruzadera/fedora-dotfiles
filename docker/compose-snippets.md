# Docker Compose snippets

## Common app stack

```yaml
services:
  app:
    image: your-image:latest
    ports:
      - "8080:8080"
    environment:
      - TZ=Europe/Madrid
```

## Useful commands

```bash
docker compose up -d
docker compose logs -f
docker compose down
```

