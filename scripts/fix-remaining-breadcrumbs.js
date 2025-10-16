const fs = require('fs');

const PAGES = [
  'frontend/web/src/pages/InventoryPage.tsx',
  'frontend/web/src/pages/InventoryStockPage.tsx',
  'frontend/web/src/pages/SchedulePage.tsx',
  'frontend/web/src/pages/PurchasesPage.tsx',
  'frontend/web/src/pages/PurchasingPage.tsx',
  'frontend/web/src/pages/WhatsAppPage.tsx',
  'frontend/web/src/pages/SettingsPage.tsx',
  'frontend/web/src/pages/ExecutivePage.tsx',
  'frontend/web/src/pages/ReportsPage.tsx',
  'frontend/web/src/pages/ParamsPage.tsx',
  'frontend/web/src/pages/MoreStatePage.tsx',
  'frontend/web/src/pages/MorePage.tsx',
  'frontend/web/src/pages/HRPage.tsx',
  'frontend/web/src/pages/AIChatPage.tsx',
  'frontend/web/src/pages/AIAssistPage.tsx',
  'frontend/web/src/pages/AIPage.tsx',
  'frontend/web/src/pages/PartnersPage.tsx',
  'frontend/web/src/pages/PartnersCustomersPage.tsx'
];

function fixBreadcrumb(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Zaten düzgünse skip
    if (content.includes("import { Breadcrumb }") && content.includes("<Breadcrumb")) {
      console.log(`✅ ${filePath.split('/').pop()} - Already fixed`);
      return;
    }

    // Import ekle
    if (!content.includes("import { Breadcrumb }")) {
      const lines = content.split('\n');
      let importInsertIndex = -1;
      
      // Son import'tan sonra ekle
      for (let i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('import ')) {
          importInsertIndex = i;
        }
      }
      
      if (importInsertIndex !== -1) {
        lines.splice(importInsertIndex + 1, 0, "import { Breadcrumb } from '../components/navigation/Breadcrumb'");
        content = lines.join('\n');
      }
    }

    // Usage ekle (eğer yoksa)
    if (!content.includes('<Breadcrumb')) {
      // return ( sonrasına ekle
      content = content.replace(/return\s*\(\s*\n\s*<([a-zA-Z]+)/, (match, tag) => {
        return `return (\n    <${tag}>\n      <Breadcrumb />`;
      });
    }

    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✅ ${filePath.split('/').pop()} - Fixed`);
  } catch (error) {
    console.error(`❌ ${filePath.split('/').pop()} - Error:`, error.message);
  }
}

console.log('🔧 Fixing remaining Breadcrumbs...\n');
PAGES.forEach(fixBreadcrumb);
console.log('\n✨ Done!');

