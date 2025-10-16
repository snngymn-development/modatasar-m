# CI/CD

## Branch Modeli
- staging: QA/preview ortamÄ± (otomatik deploy)
- prod: canlÄ± ortam (otomatik deploy)
- feature/*: geliÅŸtirme (PR â†’ staging)

## Pipeline AÅŸamalarÄ±
1. Lint/Test
2. Build
3. Docker Image Push (server)
4. Deploy (staging/prod)
