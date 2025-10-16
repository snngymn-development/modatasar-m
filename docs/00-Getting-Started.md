# Getting Started (Tek GiriÅŸ NoktasÄ±)

## 1) Gerekenler
- Node.js 20+, pnpm 9+
- Flutter 3.22+ (web build iÃ§in)
- Docker 24+, Docker Compose
- PostgreSQL 15+ (lokal ya da Docker)
- GitHub hesabÄ± ve repo eriÅŸimi

## 2) HÄ±zlÄ± BaÅŸlangÄ±Ã§
`ash
# env
cp .env.example .env
cp backend/api/.env.example backend/api/.env
cp frontend/web/.env.example frontend/web/.env

# veritabanÄ± (lokal docker)
docker compose -f ops/docker/docker-compose.minimal.yml up -d postgres

# backend
cd backend/api
pnpm i
pnpm prisma:generate && pnpm prisma:migrate:dev
pnpm start:dev

# frontend (web)
cd ../../frontend/web
npm i
npm run dev

# frontend (mobile)
cd ../mobile
flutter pub get
flutter run -d windows
`

## 3) Branch AkÄ±ÅŸÄ±

feature/* â†’ Pull Request â†’ staging

staging â†’ QA/Preview â†’ prod'a merge â†’ canlÄ± deploy (otomatik)

Detay: bkz. docs/04-CICD.md

## 4) HÄ±zlÄ± Test

- Backend API: http://localhost:3001
- React Web: http://localhost:5173
- Flutter Windows: Native uygulama

## 5) Sorun Giderme

- Port Ã§akÄ±ÅŸmasÄ±: 
etstat -ano | findstr :3000
- Flutter pubspec.yaml: cd frontend/mobile dizininde Ã§alÄ±ÅŸtÄ±r
- Prisma hatasÄ±: .env dosyasÄ±nÄ± kontrol et

## 6) Sonraki AdÄ±mlar

1. [Proje YapÄ±sÄ±](01-Project-Structure.md)
2. [GeliÅŸtirme Kurulumu](02-Dev-Setup.md)
3. [Mimari](03-Architecture.md)
4. [CI/CD](04-CICD.md)
5. [Kurallar](05-Conventions.md)
