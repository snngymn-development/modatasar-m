# Deneme1 — Clean Core + DDD Monorepo

Bu proje Clean Core Architecture + DDD prensipleriyle monorepo yapısında inşa edilmiştir.

## Teknolojiler

- **Backend**: NestJS + Prisma + PostgreSQL
- **Frontend Web**: React + Vite + TypeScript
- **Frontend Mobile**: React Native (Expo)
- **Shared Core**: TypeScript types, entities, validation, i18n
- **API Documentation**: OpenAPI/Swagger + Codegen

## Kurulum

```bash
pnpm install
cp backend/api/.env.example backend/api/.env   # DATABASE_URL ve PORT düzenle
pnpm --filter @deneme1/api prisma:migrate
```

## Geliştirme

```bash
# Backend API (NestJS)
pnpm dev:api          # http://localhost:3000  (Swagger: /docs)

# Frontend Web (Vite)
pnpm dev:web

# Frontend Mobile (React Native)
pnpm dev:rn

# OpenAPI & Codegen
pnpm --filter @deneme1/api openapi:emit
pnpm --filter @deneme1/api codegen:all
```

## Yapı

```
deneme1/
├─ packages/core/       # Shared entities, types, validation, i18n
├─ packages/shared/     # Re-exports from core
├─ backend/api/         # NestJS REST API
└─ frontend/
   ├─ web/              # React web app
   └─ mobile/           # React Native mobile app
```

## Daha Fazla Bilgi

Detaylı dokümantasyon için `docs/` klasörüne bakın.
