# Deneme1 Desktop App (Tauri)

Desktop uygulaması, Web build'ini sarmalayarak Windows için native uygulama sağlar.

## Gereksinimler

- Rust (https://rustup.rs/)
- Node.js & pnpm
- Visual Studio Build Tools (Windows)

## Geliştirme

```bash
# Geliştirme modunda çalıştır
pnpm dev

# Build (production)
pnpm build
```

## Özellikler

- ✅ Web build entegrasyonu
- ✅ Native window yönetimi
- ✅ System tray (gelecek)
- ✅ Auto-updater (gelecek)
- ✅ Keyboard shortcuts (gelecek)

## Mimari

Desktop uygulama, Web build'ini (`frontend/web/dist`) kullanarak çalışır.
Tauri, Rust backend + Web frontend hibrit yaklaşımı kullanır.

