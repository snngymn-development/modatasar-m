import fs from 'fs/promises'
import path from 'path'
import glob from 'glob'

type Platform = 'web' | 'mobile' | 'desktop' | 'ios' | 'android'
type Feature = 'nav' | 'breadcrumb' | 'auth' | 'i18n' | 'emptyState' | 'realtime' | 'quickAdd' | 'responsive' | 'pwa' | 'offline'

type PageAudit = {
  page: string
  platform: Platform
  hasNavLink: boolean
  hasBreadcrumb: boolean
  hasAuth: boolean
  hasI18n: boolean
  hasEmptyState: boolean
  hasRealtime: boolean
  hasQuickAdd: boolean
  hasResponsiveHints: boolean
  hasPWA: boolean
  hasOffline: boolean
  filePath: string
  exists: boolean
}

type PlatformStatus = {
  platform: Platform
  totalPages: number
  implementedPages: number
  missingPages: string[]
  features: Record<Feature, number>
}

// Web sayfaları (mevcut)
const WEB_PAGES = [
  'dashboard', 'partners', 'partners/customers', 'parties', 'rent-sale',
  'inventory', 'inventory-stock', 'schedule', 'ai', 'ai/assist', 'ai/chat',
  'finance', 'purchasing', 'hr', 'more', 'more/state', 'settings',
  'params', 'reports', 'whatsapp', 'executive'
]

// Backend modülleri (mevcut)
const BACKEND_MODULES = [
  'customers', 'suppliers', 'products', 'orders', 'rentals', 'purchases',
  'calendar', 'inventory', 'stocks', 'finance', 'employees', 'transactions',
  'agenda-events', 'time-entries', 'allowances', 'payroll', 'dashboard'
]

async function readFile(file: string): Promise<string> {
  try {
    return await fs.readFile(file, 'utf8')
  } catch {
    return ''
  }
}

async function auditWebPages(): Promise<PageAudit[]> {
  const results: PageAudit[] = []
  
  for (const page of WEB_PAGES) {
    const filePath = `frontend/web/src/pages/${page.split('/').map(p => p.charAt(0).toUpperCase() + p.slice(1)).join('')}Page.tsx`
    const content = await readFile(filePath)
    
    results.push({
      page,
      platform: 'web',
      hasNavLink: /ROUTES\.|href.*${page}/.test(content),
      hasBreadcrumb: /Breadcrumb|breadcrumb/.test(content),
      hasAuth: /useAuth|ProtectedRoute|requireAuth/.test(content),
      hasI18n: /TEXT\[|useI18n|i18n\./.test(content),
      hasEmptyState: /EmptyState|NoData|empty:/.test(content),
      hasRealtime: /useSSE|EventSource|WebSocket|socket\.|io\(/.test(content),
      hasQuickAdd: /CommandPalette|QuickAdd|cmd-k|⌘K|Ctrl\+K/.test(content),
      hasResponsiveHints: /(?:sm:|md:|lg:|xl:|2xl:)/.test(content),
      hasPWA: /manifest\.json|service.*worker|PWA/.test(content),
      hasOffline: /offline|queue|sync/.test(content),
      filePath,
      exists: content.length > 0
    })
  }
  
  return results
}

async function auditMobilePages(): Promise<PageAudit[]> {
  const results: PageAudit[] = []
  
  for (const page of WEB_PAGES) {
    const screenName = page.split('/').map(p => p.charAt(0).toUpperCase() + p.slice(1)).join('') + 'Screen'
    const filePath = `frontend/mobile/src/screens/${screenName}.tsx`
    const content = await readFile(filePath)
    
    results.push({
      page,
      platform: 'mobile',
      hasNavLink: /navigation|navigate/.test(content),
      hasBreadcrumb: /Breadcrumb|breadcrumb/.test(content),
      hasAuth: /useAuth|ProtectedRoute/.test(content),
      hasI18n: /TEXT\[|useI18n/.test(content),
      hasEmptyState: /EmptyState|NoData/.test(content),
      hasRealtime: /useSSE|EventSource|WebSocket/.test(content),
      hasQuickAdd: /CommandPalette|QuickAdd/.test(content),
      hasResponsiveHints: false, // Mobile doesn't need responsive hints
      hasPWA: false, // Mobile is native
      hasOffline: /offline|queue|sync/.test(content),
      filePath,
      exists: content.length > 0
    })
  }
  
  return results
}

async function auditDesktopPages(): Promise<PageAudit[]> {
  const results: PageAudit[] = []
  
  for (const page of WEB_PAGES) {
    const filePath = `frontend/desktop/src/pages/${page.split('/').map(p => p.charAt(0).toUpperCase() + p.slice(1)).join('')}Page.tsx`
    const content = await readFile(filePath)
    
    results.push({
      page,
      platform: 'desktop',
      hasNavLink: /ROUTES\.|href/.test(content),
      hasBreadcrumb: /Breadcrumb|breadcrumb/.test(content),
      hasAuth: /useAuth|ProtectedRoute/.test(content),
      hasI18n: /TEXT\[|useI18n/.test(content),
      hasEmptyState: /EmptyState|NoData/.test(content),
      hasRealtime: /useSSE|EventSource|WebSocket/.test(content),
      hasQuickAdd: /CommandPalette|QuickAdd/.test(content),
      hasResponsiveHints: false, // Desktop doesn't need responsive
      hasPWA: false, // Desktop is native
      hasOffline: /offline|queue|sync/.test(content),
      filePath,
      exists: content.length > 0
    })
  }
  
  return results
}

async function auditBackendModules(): Promise<PageAudit[]> {
  const results: PageAudit[] = []
  
  for (const module of BACKEND_MODULES) {
    const controllerPath = `backend/api/src/modules/${module}/${module}.controller.ts`
    const servicePath = `backend/api/src/modules/${module}/${module}.service.ts`
    const modulePath = `backend/api/src/modules/${module}/${module}.module.ts`
    
    const controllerContent = await readFile(controllerPath)
    const serviceContent = await readFile(servicePath)
    const moduleContent = await readFile(modulePath)
    
    const hasController = controllerContent.length > 0
    const hasService = serviceContent.length > 0
    const hasModule = moduleContent.length > 0
    
    results.push({
      page: module,
      platform: 'web', // Backend serves all platforms
      hasNavLink: false, // Not applicable
      hasBreadcrumb: false, // Not applicable
      hasAuth: /@UseGuards|AuthGuard|JwtAuthGuard/.test(controllerContent),
      hasI18n: false, // Backend doesn't use i18n
      hasEmptyState: false, // Not applicable
      hasRealtime: /@WebSocketGateway|@SubscribeMessage|EventEmitter|SSE/.test(controllerContent + serviceContent),
      hasQuickAdd: false, // Not applicable
      hasResponsiveHints: false, // Not applicable
      hasPWA: false, // Not applicable
      hasOffline: false, // Not applicable
      filePath: controllerPath,
      exists: hasController && hasService && hasModule
    })
  }
  
  return results
}

function calculatePlatformStatus(audits: PageAudit[]): PlatformStatus[] {
  const platforms: Platform[] = ['web', 'mobile', 'desktop', 'ios', 'android']
  const statuses: PlatformStatus[] = []
  
  for (const platform of platforms) {
    const platformAudits = audits.filter(a => a.platform === platform)
    const implementedPages = platformAudits.filter(a => a.exists)
    const missingPages = platformAudits.filter(a => !a.exists).map(a => a.page)
    
    const features: Record<Feature, number> = {
      nav: implementedPages.filter(a => a.hasNavLink).length,
      breadcrumb: implementedPages.filter(a => a.hasBreadcrumb).length,
      auth: implementedPages.filter(a => a.hasAuth).length,
      i18n: implementedPages.filter(a => a.hasI18n).length,
      emptyState: implementedPages.filter(a => a.hasEmptyState).length,
      realtime: implementedPages.filter(a => a.hasRealtime).length,
      quickAdd: implementedPages.filter(a => a.hasQuickAdd).length,
      responsive: implementedPages.filter(a => a.hasResponsiveHints).length,
      pwa: implementedPages.filter(a => a.hasPWA).length,
      offline: implementedPages.filter(a => a.hasOffline).length
    }
    
    statuses.push({
      platform,
      totalPages: WEB_PAGES.length,
      implementedPages: implementedPages.length,
      missingPages,
      features
    })
  }
  
  return statuses
}

function generateMarkdownReport(audits: PageAudit[], statuses: PlatformStatus[]): string {
  let report = '# 🎯 PLATFORM EŞİTLİK DENETİM RAPORU\n\n'
  
  // Genel Özet Tablosu
  report += '## 📊 GENEL ÖZET\n\n'
  report += '| Platform | Sayfa Sayısı | Eksik Sayfa | Nav | Breadcrumb | Auth | i18n | Empty | Realtime | QuickAdd | Responsive | PWA | Offline |\n'
  report += '|----------|-------------|-------------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|\n'
  
  for (const status of statuses) {
    const missingCount = status.missingPages.length
    const navPct = Math.round((status.features.nav / status.implementedPages) * 100) || 0
    const breadcrumbPct = Math.round((status.features.breadcrumb / status.implementedPages) * 100) || 0
    const authPct = Math.round((status.features.auth / status.implementedPages) * 100) || 0
    const i18nPct = Math.round((status.features.i18n / status.implementedPages) * 100) || 0
    const emptyPct = Math.round((status.features.emptyState / status.implementedPages) * 100) || 0
    const realtimePct = Math.round((status.features.realtime / status.implementedPages) * 100) || 0
    const quickAddPct = Math.round((status.features.quickAdd / status.implementedPages) * 100) || 0
    const responsivePct = Math.round((status.features.responsive / status.implementedPages) * 100) || 0
    const pwaPct = Math.round((status.features.pwa / status.implementedPages) * 100) || 0
    const offlinePct = Math.round((status.features.offline / status.implementedPages) * 100) || 0
    
    report += `| ${status.platform.toUpperCase()} | ${status.implementedPages}/${status.totalPages} | ${missingCount} | ${navPct}% | ${breadcrumbPct}% | ${authPct}% | ${i18nPct}% | ${emptyPct}% | ${realtimePct}% | ${quickAddPct}% | ${responsivePct}% | ${pwaPct}% | ${offlinePct}% |\n`
  }
  
  // Platform Detayları
  report += '\n## 🔍 PLATFORM DETAYLARI\n\n'
  
  for (const status of statuses) {
    report += `### ${status.platform.toUpperCase()} PLATFORM\n\n`
    
    if (status.missingPages.length > 0) {
      report += `**❌ Eksik Sayfalar (${status.missingPages.length}):**\n`
      for (const page of status.missingPages) {
        report += `- ${page}\n`
      }
      report += '\n'
    }
    
    report += `**📈 Özellik Durumu:**\n`
    report += `- Navigation: ${status.features.nav}/${status.implementedPages} (${Math.round((status.features.nav / status.implementedPages) * 100) || 0}%)\n`
    report += `- Breadcrumb: ${status.features.breadcrumb}/${status.implementedPages} (${Math.round((status.features.breadcrumb / status.implementedPages) * 100) || 0}%)\n`
    report += `- Auth: ${status.features.auth}/${status.implementedPages} (${Math.round((status.features.auth / status.implementedPages) * 100) || 0}%)\n`
    report += `- i18n: ${status.features.i18n}/${status.implementedPages} (${Math.round((status.features.i18n / status.implementedPages) * 100) || 0}%)\n`
    report += `- Empty State: ${status.features.emptyState}/${status.implementedPages} (${Math.round((status.features.emptyState / status.implementedPages) * 100) || 0}%)\n`
    report += `- Real-time: ${status.features.realtime}/${status.implementedPages} (${Math.round((status.features.realtime / status.implementedPages) * 100) || 0}%)\n`
    report += `- Quick Add: ${status.features.quickAdd}/${status.implementedPages} (${Math.round((status.features.quickAdd / status.implementedPages) * 100) || 0}%)\n`
    report += `- Responsive: ${status.features.responsive}/${status.implementedPages} (${Math.round((status.features.responsive / status.implementedPages) * 100) || 0}%)\n`
    report += `- PWA: ${status.features.pwa}/${status.implementedPages} (${Math.round((status.features.pwa / status.implementedPages) * 100) || 0}%)\n`
    report += `- Offline: ${status.features.offline}/${status.implementedPages} (${Math.round((status.features.offline / status.implementedPages) * 100) || 0}%)\n\n`
  }
  
  return report
}

function generateSprintRoadmap(statuses: PlatformStatus[]): string {
  let roadmap = '# 🚀 SPRINT BAZLI YOL HARİTASI\n\n'
  
  // Sprint 1: Kritik Altyapı
  roadmap += '## 🏗️ SPRINT 1: KRİTİK ALTYAPI (2-3 hafta)\n\n'
  roadmap += '**Hedef:** Tüm platformlarda temel sayfa yapısı ve navigasyon\n\n'
  roadmap += '### Web Platform ✅ (Mevcut)\n'
  roadmap += '- [x] 22 sayfa mevcut\n'
  roadmap += '- [x] Navigation sistemi\n'
  roadmap += '- [x] Auth sistemi\n\n'
  
  roadmap += '### Mobile Platform (React Native/Expo)\n'
  roadmap += '- [ ] Expo projesi kurulumu\n'
  roadmap += '- [ ] Navigation stack (React Navigation)\n'
  roadmap += '- [ ] 22 sayfa screen oluşturma\n'
  roadmap += '- [ ] Auth context entegrasyonu\n'
  roadmap += '- [ ] API entegrasyonu\n\n'
  
  roadmap += '### Desktop Platform (Tauri)\n'
  roadmap += '- [ ] Tauri projesi kurulumu\n'
  roadmap += '- [ ] Web build entegrasyonu\n'
  roadmap += '- [ ] Native menü sistemi\n'
  roadmap += '- [ ] Window yönetimi\n\n'
  
  // Sprint 2: Özellik Eşitliği
  roadmap += '## ⚡ SPRINT 2: ÖZELLİK EŞİTLİĞİ (3-4 hafta)\n\n'
  roadmap += '**Hedef:** Tüm platformlarda aynı özellik seti\n\n'
  roadmap += '### Ortak Özellikler\n'
  roadmap += '- [ ] Breadcrumb sistemi (tüm platformlar)\n'
  roadmap += '- [ ] i18n entegrasyonu (tüm platformlar)\n'
  roadmap += '- [ ] Empty state bileşenleri\n'
  roadmap += '- [ ] Error handling\n'
  roadmap += '- [ ] Loading states\n\n'
  
  roadmap += '### Real-time Özellikler\n'
  roadmap += '- [ ] WebSocket gateway (Backend)\n'
  roadmap += '- [ ] SSE fallback\n'
  roadmap += '- [ ] useEvents hook (Web)\n'
  roadmap += '- [ ] useEvents hook (Mobile)\n'
  roadmap += '- [ ] Real-time sync (Desktop)\n\n'
  
  // Sprint 3: Gelişmiş Özellikler
  roadmap += '## 🎨 SPRINT 3: GELİŞMİŞ ÖZELLİKLER (2-3 hafta)\n\n'
  roadmap += '**Hedef:** Platform-specific optimizasyonlar\n\n'
  roadmap += '### Mobile Specific\n'
  roadmap += '- [ ] Push notifications\n'
  roadmap += '- [ ] Offline queue\n'
  roadmap += '- [ ] Camera integration\n'
  roadmap += '- [ ] Biometric auth\n\n'
  
  roadmap += '### Desktop Specific\n'
  roadmap += '- [ ] System tray\n'
  roadmap += '- [ ] Auto-updater\n'
  roadmap += '- [ ] Keyboard shortcuts\n'
  roadmap += '- [ ] File system access\n\n'
  
  roadmap += '### Web Specific\n'
  roadmap += '- [ ] PWA manifest\n'
  roadmap += '- [ ] Service worker\n'
  roadmap += '- [ ] Offline caching\n'
  roadmap += '- [ ] Install prompt\n\n'
  
  // Sprint 4: Optimizasyon
  roadmap += '## 🚀 SPRINT 4: OPTİMİZASYON (2 hafta)\n\n'
  roadmap += '**Hedef:** Performance ve kullanıcı deneyimi\n\n'
  roadmap += '- [ ] Performance monitoring\n'
  roadmap += '- [ ] Error tracking\n'
  roadmap += '- [ ] Analytics\n'
  roadmap += '- [ ] A/B testing\n'
  roadmap += '- [ ] E2E testler\n'
  roadmap += '- [ ] Load testing\n\n'
  
  return roadmap
}

async function main() {
  console.log('🔍 Platform eşitlik denetimi başlatılıyor...\n')
  
  // Tüm platformları denetle
  const webAudits = await auditWebPages()
  const mobileAudits = await auditMobilePages()
  const desktopAudits = await auditDesktopPages()
  const backendAudits = await auditBackendModules()
  
  const allAudits = [...webAudits, ...mobileAudits, ...desktopAudits, ...backendAudits]
  const statuses = calculatePlatformStatus(allAudits)
  
  // Raporları oluştur
  const markdownReport = generateMarkdownReport(allAudits, statuses)
  const sprintRoadmap = generateSprintRoadmap(statuses)
  
  // Dosyalara yaz
  await fs.mkdir('docs/audit', { recursive: true })
  await fs.writeFile('docs/audit/platform-audit-report.md', markdownReport)
  await fs.writeFile('docs/audit/sprint-roadmap.md', sprintRoadmap)
  
  // Konsola özet yazdır
  console.log('📊 PLATFORM DURUMU ÖZETİ:')
  console.log('========================')
  for (const status of statuses) {
    const percentage = Math.round((status.implementedPages / status.totalPages) * 100)
    console.log(`${status.platform.toUpperCase()}: ${status.implementedPages}/${status.totalPages} (${percentage}%)`)
  }
  
  console.log('\n📁 Raporlar oluşturuldu:')
  console.log('- docs/audit/platform-audit-report.md')
  console.log('- docs/audit/sprint-roadmap.md')
}

main().catch(e => {
  console.error('❌ Hata:', e)
  process.exit(1)
})
