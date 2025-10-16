const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class SecurityAuditor {
  constructor() {
    this.results = {
      vulnerabilities: [],
      warnings: [],
      recommendations: []
    };
  }

  async runAudit() {
    console.log('🔒 Starting Security Audit...\n');

    await this.auditNpmPackages();
    await this.auditDockerImages();
    await this.auditCodeSecurity();
    await this.auditSecrets();
    await this.auditDependencies();

    this.generateReport();
  }

  async auditNpmPackages() {
    console.log('📦 Auditing NPM packages...');
    
    try {
      const output = execSync('npm audit --json', { encoding: 'utf8' });
      const audit = JSON.parse(output);
      
      if (audit.vulnerabilities) {
        Object.entries(audit.vulnerabilities).forEach(([name, vuln]) => {
          this.results.vulnerabilities.push({
            type: 'npm',
            package: name,
            severity: vuln.severity,
            title: vuln.title,
            description: vuln.description,
            recommendation: vuln.recommendation
          });
        });
      }
      
      console.log(`   Found ${Object.keys(audit.vulnerabilities || {}).length} vulnerabilities`);
    } catch (error) {
      console.log('   Error running npm audit:', error.message);
    }
  }

  async auditDockerImages() {
    console.log('🐳 Auditing Docker images...');
    
    try {
      // Check for outdated base images
      const dockerfile = fs.readFileSync('Dockerfile', 'utf8');
      const lines = dockerfile.split('\n');
      
      lines.forEach((line, index) => {
        if (line.startsWith('FROM')) {
          const image = line.split(' ')[1];
          if (image.includes('latest') || image.includes('alpine')) {
            this.results.warnings.push({
              type: 'docker',
              file: 'Dockerfile',
              line: index + 1,
              issue: 'Using latest or alpine tag',
              recommendation: 'Use specific version tags for better security'
            });
          }
        }
      });
      
      console.log('   Dockerfile analysis completed');
    } catch (error) {
      console.log('   Error analyzing Dockerfile:', error.message);
    }
  }

  async auditCodeSecurity() {
    console.log('🔍 Auditing code security...');
    
    const securityPatterns = [
      {
        pattern: /password\s*=\s*['"][^'"]+['"]/gi,
        message: 'Hardcoded password detected',
        severity: 'high'
      },
      {
        pattern: /api[_-]?key\s*=\s*['"][^'"]+['"]/gi,
        message: 'Hardcoded API key detected',
        severity: 'high'
      },
      {
        pattern: /secret\s*=\s*['"][^'"]+['"]/gi,
        message: 'Hardcoded secret detected',
        severity: 'high'
      },
      {
        pattern: /eval\s*\(/gi,
        message: 'Use of eval() function detected',
        severity: 'medium'
      },
      {
        pattern: /innerHTML\s*=/gi,
        message: 'Direct innerHTML assignment detected',
        severity: 'medium'
      },
      {
        pattern: /console\.log/gi,
        message: 'Console.log statements in production code',
        severity: 'low'
      }
    ];

    const files = this.getSourceFiles();
    
    files.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf8');
        
        securityPatterns.forEach(pattern => {
          const matches = content.match(pattern.pattern);
          if (matches) {
            matches.forEach(match => {
              this.results.vulnerabilities.push({
                type: 'code',
                file: file,
                pattern: pattern.message,
                severity: pattern.severity,
                match: match,
                recommendation: this.getSecurityRecommendation(pattern.message)
              });
            });
          }
        });
      } catch (error) {
        // Skip files that can't be read
      }
    });
    
    console.log(`   Analyzed ${files.length} source files`);
  }

  async auditSecrets() {
    console.log('🔐 Auditing secrets and credentials...');
    
    const secretPatterns = [
      {
        pattern: /[A-Za-z0-9+/]{40,}={0,2}/g,
        message: 'Potential base64 encoded secret'
      },
      {
        pattern: /[A-Fa-f0-9]{32,}/g,
        message: 'Potential MD5/SHA hash'
      },
      {
        pattern: /sk-[A-Za-z0-9]{48}/g,
        message: 'Potential OpenAI API key'
      },
      {
        pattern: /[A-Za-z0-9]{20,}/g,
        message: 'Potential long random string'
      }
    ];

    const files = this.getSourceFiles();
    
    files.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf8');
        
        secretPatterns.forEach(pattern => {
          const matches = content.match(pattern.pattern);
          if (matches) {
            matches.forEach(match => {
              if (match.length > 20) { // Only flag long strings
                this.results.warnings.push({
                  type: 'secret',
                  file: file,
                  pattern: pattern.message,
                  match: match.substring(0, 20) + '...',
                  recommendation: 'Verify this is not a hardcoded secret'
                });
              }
            });
          }
        });
      } catch (error) {
        // Skip files that can't be read
      }
    });
    
    console.log('   Secret scanning completed');
  }

  async auditDependencies() {
    console.log('📋 Auditing dependency security...');
    
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    const dependencies = { ...packageJson.dependencies, ...packageJson.devDependencies };
    
    // Check for known vulnerable packages
    const vulnerablePackages = [
      'lodash', 'moment', 'jquery', 'express', 'mongoose'
    ];
    
    vulnerablePackages.forEach(pkg => {
      if (dependencies[pkg]) {
        this.results.recommendations.push({
          type: 'dependency',
          package: pkg,
          version: dependencies[pkg],
          recommendation: 'Check for security updates and consider alternatives'
        });
      }
    });
    
    console.log('   Dependency analysis completed');
  }

  getSourceFiles() {
    const extensions = ['.js', '.ts', '.tsx', '.jsx', '.json'];
    const files = [];
    
    const scanDir = (dir) => {
      try {
        const items = fs.readdirSync(dir);
        items.forEach(item => {
          const fullPath = path.join(dir, item);
          const stat = fs.statSync(fullPath);
          
          if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
            scanDir(fullPath);
          } else if (stat.isFile() && extensions.some(ext => item.endsWith(ext))) {
            files.push(fullPath);
          }
        });
      } catch (error) {
        // Skip directories that can't be read
      }
    };
    
    scanDir('.');
    return files;
  }

  getSecurityRecommendation(issue) {
    const recommendations = {
      'Hardcoded password detected': 'Use environment variables or secure key management',
      'Hardcoded API key detected': 'Use environment variables or secure key management',
      'Hardcoded secret detected': 'Use environment variables or secure key management',
      'Use of eval() function detected': 'Avoid eval() and use safer alternatives',
      'Direct innerHTML assignment detected': 'Use textContent or proper sanitization',
      'Console.log statements in production code': 'Remove or use proper logging'
    };
    
    return recommendations[issue] || 'Review and fix security issue';
  }

  generateReport() {
    console.log('\n📋 Security Audit Report');
    console.log('='.repeat(50));
    
    // Vulnerabilities
    if (this.results.vulnerabilities.length > 0) {
      console.log('\n🚨 VULNERABILITIES FOUND:');
      this.results.vulnerabilities.forEach((vuln, index) => {
        console.log(`${index + 1}. [${vuln.severity.toUpperCase()}] ${vuln.pattern || vuln.title}`);
        console.log(`   File: ${vuln.file || vuln.package}`);
        console.log(`   Recommendation: ${vuln.recommendation}`);
        console.log('');
      });
    }
    
    // Warnings
    if (this.results.warnings.length > 0) {
      console.log('\n⚠️  WARNINGS:');
      this.results.warnings.forEach((warning, index) => {
        console.log(`${index + 1}. ${warning.pattern}`);
        console.log(`   File: ${warning.file}`);
        console.log(`   Recommendation: ${warning.recommendation}`);
        console.log('');
      });
    }
    
    // Recommendations
    if (this.results.recommendations.length > 0) {
      console.log('\n💡 RECOMMENDATIONS:');
      this.results.recommendations.forEach((rec, index) => {
        console.log(`${index + 1}. ${rec.package}: ${rec.recommendation}`);
      });
    }
    
    // Summary
    console.log('\n📊 SUMMARY:');
    console.log(`Vulnerabilities: ${this.results.vulnerabilities.length}`);
    console.log(`Warnings: ${this.results.warnings.length}`);
    console.log(`Recommendations: ${this.results.recommendations.length}`);
    
    const totalIssues = this.results.vulnerabilities.length + this.results.warnings.length;
    if (totalIssues === 0) {
      console.log('\n🎉 No security issues found!');
    } else {
      console.log(`\n⚠️  Total issues found: ${totalIssues}`);
      console.log('Please review and fix the issues above.');
    }
  }
}

// Run the security audit
const auditor = new SecurityAuditor();
auditor.runAudit().catch(console.error);
