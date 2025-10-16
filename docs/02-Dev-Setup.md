# Development Setup

## Ortam DeÄŸiÅŸkenleri
- .env (root): ortak deÄŸiÅŸkenler
- backend/api/.env: API (DB_URL, JWT_SECRET, ...)
- frontend/web/.env: FRONTEND_API_URL vb.

## Komutlar (Ã¶zet)
- backend: pnpm start:dev, pnpm test, pnpm build, pnpm prisma:migrate:dev
- frontend/web: npm run dev, npm run build
- frontend/mobile: flutter run -d windows, flutter build web

## Kod Kalitesi
- TypeScript strict, ESLint + Prettier
- Flutter: flutter analyze, flutter test
