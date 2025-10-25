import { Injectable, Logger } from '@nestjs/common'
import { promises as fs } from 'fs'
import * as path from 'path'
import * as puppeteer from 'puppeteer'

export interface PDFOptions {
  format?: 'A4' | 'A3' | 'Letter'
  margin?: {
    top?: string
    right?: string
    bottom?: string
    left?: string
  }
  headerTemplate?: string
  footerTemplate?: string
  displayHeaderFooter?: boolean
}

@Injectable()
export class PDFService {
  private readonly logger = new Logger(PDFService.name)
  private browser: any

  async onModuleInit() {
    // Initialize browser instance
    this.browser = await puppeteer.launch({
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--no-first-run',
        '--no-zygote',
        '--single-process',
        '--disable-gpu'
      ]
    })
    this.logger.log('Puppeteer browser initialized')
  }

  async onModuleDestroy() {
    if (this.browser) {
      await this.browser.close()
      this.logger.log('Puppeteer browser closed')
    }
  }

  /**
   * Generate PDF from HTML content
   */
  async generatePDF(
    htmlContent: string,
    outputPath: string,
    options: PDFOptions = {}
  ): Promise<string> {
    try {
      // Create page
      const page = await this.browser.newPage()

      // Set default options
      const defaultOptions: PDFOptions = {
        format: 'A4',
        margin: {
          top: '1cm',
          right: '1cm',
          bottom: '1cm',
          left: '1cm'
        },
        displayHeaderFooter: false,
        ...options
      }

      // Set content
      await page.setContent(htmlContent, { waitUntil: 'networkidle0' })

      // Wait a bit for any async content to load
      await page.waitForTimeout(1000)

      // Ensure output directory exists
      const outputDir = path.dirname(outputPath)
      await fs.mkdir(outputDir, { recursive: true })

      // Generate PDF
      await page.pdf({
        path: outputPath,
        format: defaultOptions.format,
        margin: defaultOptions.margin,
        headerTemplate: defaultOptions.headerTemplate,
        footerTemplate: defaultOptions.footerTemplate,
        displayHeaderFooter: defaultOptions.displayHeaderFooter,
        printBackground: true
      })

      await page.close()

      this.logger.log(`PDF generated successfully: ${outputPath}`)
      return outputPath

    } catch (error) {
      const err = error as Error
      this.logger.error(`Failed to generate PDF: ${err.message}`, err.stack)
      throw new Error(`PDF generation failed: ${err.message}`)
    }
  }

  /**
   * Generate PDF from HTML content and return buffer
   */
  async generatePDFBuffer(
    htmlContent: string,
    options: PDFOptions = {}
  ): Promise<Buffer> {
    try {
      const page = await this.browser.newPage()

      // Set default options
      const defaultOptions: PDFOptions = {
        format: 'A4',
        margin: {
          top: '1cm',
          right: '1cm',
          bottom: '1cm',
          left: '1cm'
        },
        displayHeaderFooter: false,
        ...options
      }

      // Set content
      await page.setContent(htmlContent, { waitUntil: 'networkidle0' })

      // Wait a bit for any async content to load
      await page.waitForTimeout(1000)

      // Generate PDF buffer
      const pdfBuffer = await page.pdf({
        format: defaultOptions.format,
        margin: defaultOptions.margin,
        headerTemplate: defaultOptions.headerTemplate,
        footerTemplate: defaultOptions.footerTemplate,
        displayHeaderFooter: defaultOptions.displayHeaderFooter,
        printBackground: true
      })

      await page.close()

      this.logger.log('PDF buffer generated successfully')
      return Buffer.from(pdfBuffer)

    } catch (error) {
      const err = error as Error
      this.logger.error(`Failed to generate PDF buffer: ${err.message}`, err.stack)
      throw new Error(`PDF generation failed: ${err.message}`)
    }
  }

  /**
   * Generate contract-specific PDF with header/footer
   */
  async generateContractPDF(
    htmlContent: string,
    contractNumber: string,
    outputPath?: string
  ): Promise<string | Buffer> {
    const options: PDFOptions = {
      format: 'A4',
      margin: {
        top: '2cm',
        right: '2cm',
        bottom: '2cm',
        left: '2cm'
      },
      displayHeaderFooter: true,
      headerTemplate: `
        <div style="font-size: 10px; text-align: center; width: 100%; margin: 0 1cm;">
          <span>Sözleşme No: ${contractNumber}</span>
        </div>
      `,
      footerTemplate: `
        <div style="font-size: 8px; text-align: center; width: 100%; margin: 0 1cm;">
          <span>Sayfa <span class="pageNumber"></span> / <span class="totalPages"></span></span>
        </div>
      `
    }

    if (outputPath) {
      return this.generatePDF(htmlContent, outputPath, options)
    } else {
      return this.generatePDFBuffer(htmlContent, options)
    }
  }

  /**
   * Clean up old PDF files (utility method)
   */
  async cleanupOldPDFs(directory: string, maxAgeHours: number = 24): Promise<void> {
    try {
      const files = await fs.readdir(directory)
      const now = Date.now()
      const maxAge = maxAgeHours * 60 * 60 * 1000 // Convert to milliseconds

      for (const file of files) {
        if (file.endsWith('.pdf')) {
          const filePath = path.join(directory, file)
          const stats = await fs.stat(filePath)

          if (now - stats.mtime.getTime() > maxAge) {
            await fs.unlink(filePath)
            this.logger.log(`Cleaned up old PDF: ${filePath}`)
          }
        }
      }
    } catch (error) {
      const err = error as Error
      this.logger.error(`Failed to cleanup old PDFs: ${err.message}`, err.stack)
    }
  }

  /**
   * Check if PDF exists
   */
  async pdfExists(filePath: string): Promise<boolean> {
    try {
      await fs.access(filePath)
      return true
    } catch {
      return false
    }
  }

  /**
   * Get PDF file size
   */
  async getPDFFileSize(filePath: string): Promise<number> {
    try {
      const stats = await fs.stat(filePath)
      return stats.size
    } catch {
      return 0
    }
  }
}
