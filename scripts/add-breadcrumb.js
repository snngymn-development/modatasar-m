const fs = require('fs');
const path = require('path');

const PAGES_TO_UPDATE = [
  'frontend/web/src/pages/InventoryPage.tsx',
  'frontend/web/src/pages/InventoryStockPage.tsx',
  'frontend/web/src/pages/SchedulePage.tsx',
  'frontend/web/src/pages/PurchasesPage.tsx',
  'frontend/web/src/pages/PurchasingPage.tsx',
  'frontend/web/src/pages/PartyPage.tsx',
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
  'frontend/web/src/pages/employees/EmployeesPage.tsx',
  'frontend/web/src/pages/employees/PayrollManagementPage.tsx',
  'frontend/web/src/pages/employees/TimeEntryApprovalPage.tsx',
];

function addBreadcrumbToFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Skip if already has Breadcrumb
    if (content.includes('Breadcrumb')) {
      console.log(`⏭️  ${path.basename(filePath)} - Already has Breadcrumb`);
      return;
    }

    // Add import
    if (!content.includes('import { Breadcrumb }')) {
      const importMatch = content.match(/^(import .*\n)+/m);
      if (importMatch) {
        const lastImportIndex = importMatch[0].lastIndexOf('\n');
        content = content.slice(0, importMatch.index + lastImportIndex + 1) +
          "import { Breadcrumb } from '../components/navigation/Breadcrumb'\n" +
          content.slice(importMatch.index + lastImportIndex + 1);
      }
    }

    // Add <Breadcrumb /> after return
    const returnMatch = content.match(/return \(\s*\n\s*<(div|>)/);
    if (returnMatch) {
      const insertPosition = returnMatch.index + returnMatch[0].length;
      content = content.slice(0, insertPosition) +
        '\n      <Breadcrumb />' +
        content.slice(insertPosition);
    }

    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✅ ${path.basename(filePath)} - Breadcrumb added`);
  } catch (error) {
    console.error(`❌ ${path.basename(filePath)} - Error:`, error.message);
  }
}

console.log('🚀 Adding Breadcrumb to all pages...\n');
PAGES_TO_UPDATE.forEach(addBreadcrumbToFile);
console.log('\n✨ Done!');

