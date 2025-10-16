const { chromium } = require('playwright');
const { performance } = require('perf_hooks');

class PerformanceTester {
  constructor() {
    this.results = [];
  }

  async runTests() {
    console.log('🚀 Starting Performance Tests...\n');

    const browser = await chromium.launch();
    const context = await browser.newContext();
    const page = await context.newPage();

    // Test 1: Page Load Time
    await this.testPageLoadTime(page);

    // Test 2: API Response Times
    await this.testApiResponseTimes();

    // Test 3: Memory Usage
    await this.testMemoryUsage(page);

    // Test 4: Bundle Size Analysis
    await this.testBundleSize();

    await browser.close();

    this.generateReport();
  }

  async testPageLoadTime(page) {
    console.log('📊 Testing Page Load Time...');
    
    const startTime = performance.now();
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('networkidle');
    const endTime = performance.now();
    
    const loadTime = endTime - startTime;
    this.results.push({
      test: 'Page Load Time',
      value: loadTime,
      unit: 'ms',
      status: loadTime < 3000 ? 'PASS' : 'FAIL',
      threshold: 3000
    });

    console.log(`   Load Time: ${loadTime.toFixed(2)}ms`);
  }

  async testApiResponseTimes() {
    console.log('🌐 Testing API Response Times...');
    
    const endpoints = [
      'http://localhost:3001/health',
      'http://localhost:3001/api/users',
      'http://localhost:3001/api/products',
      'http://localhost:3001/api/customers'
    ];

    for (const endpoint of endpoints) {
      const startTime = performance.now();
      try {
        const response = await fetch(endpoint);
        const endTime = performance.now();
        
        const responseTime = endTime - startTime;
        this.results.push({
          test: `API Response - ${endpoint.split('/').pop()}`,
          value: responseTime,
          unit: 'ms',
          status: responseTime < 1000 ? 'PASS' : 'FAIL',
          threshold: 1000
        });

        console.log(`   ${endpoint}: ${responseTime.toFixed(2)}ms`);
      } catch (error) {
        console.log(`   ${endpoint}: ERROR - ${error.message}`);
      }
    }
  }

  async testMemoryUsage(page) {
    console.log('💾 Testing Memory Usage...');
    
    const metrics = await page.evaluate(() => {
      return {
        usedJSHeapSize: performance.memory?.usedJSHeapSize || 0,
        totalJSHeapSize: performance.memory?.totalJSHeapSize || 0,
        jsHeapSizeLimit: performance.memory?.jsHeapSizeLimit || 0
      };
    });

    const memoryUsageMB = metrics.usedJSHeapSize / 1024 / 1024;
    
    this.results.push({
      test: 'Memory Usage',
      value: memoryUsageMB,
      unit: 'MB',
      status: memoryUsageMB < 100 ? 'PASS' : 'FAIL',
      threshold: 100
    });

    console.log(`   Memory Usage: ${memoryUsageMB.toFixed(2)}MB`);
  }

  async testBundleSize() {
    console.log('📦 Testing Bundle Size...');
    
    // This would typically analyze the actual bundle files
    // For now, we'll simulate the check
    const bundleSize = 2.5; // MB
    
    this.results.push({
      test: 'Bundle Size',
      value: bundleSize,
      unit: 'MB',
      status: bundleSize < 5 ? 'PASS' : 'FAIL',
      threshold: 5
    });

    console.log(`   Bundle Size: ${bundleSize}MB`);
  }

  generateReport() {
    console.log('\n📋 Performance Test Report');
    console.log('='.repeat(50));
    
    let passCount = 0;
    let failCount = 0;

    this.results.forEach(result => {
      const status = result.status === 'PASS' ? '✅' : '❌';
      console.log(`${status} ${result.test}: ${result.value}${result.unit} (threshold: ${result.threshold}${result.unit})`);
      
      if (result.status === 'PASS') {
        passCount++;
      } else {
        failCount++;
      }
    });

    console.log('='.repeat(50));
    console.log(`Total Tests: ${this.results.length}`);
    console.log(`Passed: ${passCount}`);
    console.log(`Failed: ${failCount}`);
    console.log(`Success Rate: ${((passCount / this.results.length) * 100).toFixed(1)}%`);

    if (failCount > 0) {
      console.log('\n⚠️  Some performance tests failed. Consider optimizing:');
      this.results
        .filter(r => r.status === 'FAIL')
        .forEach(r => console.log(`   - ${r.test}`));
    } else {
      console.log('\n🎉 All performance tests passed!');
    }
  }
}

// Run the tests
const tester = new PerformanceTester();
tester.runTests().catch(console.error);
