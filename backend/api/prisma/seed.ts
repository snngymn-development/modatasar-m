
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Starting database seeding...')

  // Clean existing data (in correct order to avoid foreign key constraints)
  await prisma.customerConsent.deleteMany()
  await prisma.contract.deleteMany()
  await prisma.contractTemplate.deleteMany()

  // Finance
  await prisma.posting.deleteMany()
  await prisma.transaction.deleteMany()
  await prisma.account.deleteMany()

  // Agenda / Calendar
  await prisma.agendaEvent.deleteMany()
  await prisma.calendarEvent.deleteMany()

  // Rentals & Orders
  await prisma.rental.deleteMany()
  await prisma.orderStatus.deleteMany()
  await prisma.orderFitting.deleteMany()
  await prisma.orderDiscount.deleteMany()
  await prisma.orderCharge.deleteMany()
  await prisma.orderDetail.deleteMany()
  await prisma.order.deleteMany()

  // Purchases & Stock
  await prisma.goodsReceiptLine.deleteMany()
  await prisma.goodsReceipt.deleteMany()
  await prisma.purchaseItem.deleteMany()
  await prisma.purchaseDiscount.deleteMany()
  await prisma.purchaseCharge.deleteMany()
  await prisma.purchase.deleteMany()

  await prisma.stockMovement.deleteMany()
  await prisma.stockCard.deleteMany()

  // Products / People / Orgs
  await prisma.product.deleteMany()
  await prisma.customer.deleteMany()
  await prisma.supplier.deleteMany()

  // HR (ileride kullanırsan)
  await prisma.payrollItem.deleteMany()
  await prisma.payrollRun.deleteMany()
  await prisma.sgkRecord.deleteMany()
  await prisma.allowance.deleteMany()
  await prisma.timeEntry.deleteMany()
  await prisma.employee.deleteMany()

  console.log('🗑️  Cleaned existing data')

  // ============================================
  // 0. CREATE FINANCE ACCOUNTS (if SEED_FINANCE=true)
  // ============================================
  if (process.env.SEED_FINANCE === 'true') {
    console.log('💰 Creating finance accounts...')
    
    // Create parent accounts
    const parentAccounts = await Promise.all([
      prisma.account.create({
        data: {
          id: 'acc-cash',
          type: 'CASH',
          name: 'Kasa',
          currency: 'TRY',
          isActive: true,
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-bank',
          type: 'BANK',
          name: 'Banka',
          currency: 'TRY',
          isActive: true,
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-pos',
          type: 'POS',
          name: 'POS',
          currency: 'TRY',
          isActive: true,
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-credit-card',
          type: 'CREDIT_CARD',
          name: 'Kredi Kartı',
          currency: 'TRY',
          isActive: true,
        },
      }),
    ])

    // Create child accounts for banks
    const bankChildren = await Promise.all([
      prisma.account.create({
        data: {
          id: 'acc-bank-garanti',
          type: 'BANK',
          name: 'Garanti',
          currency: 'TRY',
          isActive: true,
          parentId: 'acc-bank',
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-bank-isbank',
          type: 'BANK',
          name: 'İşbankası',
          currency: 'TRY',
          isActive: true,
          parentId: 'acc-bank',
        },
      }),
    ])

    // Create child accounts for credit cards
    const creditCardChildren = await Promise.all([
      prisma.account.create({
        data: {
          id: 'acc-cc-garanti',
          type: 'CREDIT_CARD',
          name: 'Garanti Kredi Kartı',
          currency: 'TRY',
          isActive: true,
          parentId: 'acc-credit-card',
          creditLimit: 5000000, // 50,000 TL limit
          usedAmount: 1200000,  // 12,000 TL used
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-cc-isbank',
          type: 'CREDIT_CARD',
          name: 'İşbankası Kredi Kartı',
          currency: 'TRY',
          isActive: true,
          parentId: 'acc-credit-card',
          creditLimit: 3000000, // 30,000 TL limit
          usedAmount: 800000,   // 8,000 TL used
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-cc-yapikredi',
          type: 'CREDIT_CARD',
          name: 'Yapıkredi Kredi Kartı',
          currency: 'TRY',
          isActive: true,
          parentId: 'acc-credit-card',
          creditLimit: 4000000, // 40,000 TL limit
          usedAmount: 1500000,  // 15,000 TL used
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-cc-akbank',
          type: 'CREDIT_CARD',
          name: 'Akbank Kredi Kartı',
          currency: 'TRY',
          isActive: true,
          parentId: 'acc-credit-card',
          creditLimit: 2500000, // 25,000 TL limit
          usedAmount: 500000,   // 5,000 TL used
        },
      }),
    ])

    console.log(`✅ Created ${parentAccounts.length} parent accounts and ${bankChildren.length + creditCardChildren.length} child accounts`)

    // Create demo transactions if SEED_FINANCE_DEMO=true
    if (process.env.SEED_FINANCE_DEMO === 'true') {
      console.log('💰 Creating demo finance transactions...')
      
      // First create customers and suppliers (if they don't exist)
      const customer1 = await prisma.customer.upsert({
        where: { id: 'cust-F1' },
        update: {},
        create: {
          id: 'cust-F1',
          name: 'Ayşe Yılmaz',
          phone: '0532 123 45 67',
          email: 'ayse@example.com'
        }
      })

      const supplier1 = await prisma.supplier.upsert({
        where: { id: 'supp-F1' },
        update: {},
        create: {
          id: 'supp-F1',
          name: 'Tekstil AŞ',
          phone: '0212 123 45 67',
          email: 'info@tekstil.com'
        }
      })
      
      // Demo Transaction 1: Tahsilat (Müşteriden Kasa)
      const transaction1 = await prisma.transaction.create({
        data: {
          id: 'txn-1',
          kind: 'RECEIVABLE',
          amount: 50000, // 500 TL
          currency: 'TRY',
          rateToTRY: 1.0,
          note: 'Müşteri ödemesi',
          customerId: 'cust-F1',
          createdBy: 'system',
          postings: {
            create: [
              {
                accountId: 'acc-cash', // Kasa (nakit giriş)
                dc: 'DEBIT',
                amount: 50000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
              {
                accountId: 'acc-bank-garanti', // Müşteri alacağı kapatma (banka)
                dc: 'CREDIT',
                amount: 50000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
            ],
          },
        },
      })

      // Demo Transaction 2: Ödeme (Banka → Tedarikçi)
      const transaction2 = await prisma.transaction.create({
        data: {
          id: 'txn-2',
          kind: 'PAYABLE',
          amount: 25000, // 250 TL
          currency: 'TRY',
          rateToTRY: 1.0,
          note: 'Tedarikçi ödemesi',
          supplierId: 'supp-F1',
          createdBy: 'system',
          postings: {
            create: [
              {
                accountId: 'acc-bank-garanti', // Tedarikçi borcu kapatma (banka çıkışı)
                dc: 'DEBIT',
                amount: 25000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
              {
                accountId: 'acc-bank-garanti', // Banka hesabı
                dc: 'CREDIT',
                amount: 25000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
            ],
          },
        },
      })

      // Demo Transaction 3: Virman (Banka → Kasa)
      const transaction3 = await prisma.transaction.create({
        data: {
          id: 'txn-3',
          kind: 'INTERNAL_TRANSFER',
          amount: 10000, // 100 TL
          currency: 'TRY',
          rateToTRY: 1.0,
          note: 'Günlük nakit çekme',
          createdBy: 'system',
          postings: {
            create: [
              {
                accountId: 'acc-cash', // Kasa (nakit giriş)
                dc: 'DEBIT',
                amount: 10000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
              {
                accountId: 'acc-bank-garanti', // Banka (nakit çıkış)
                dc: 'CREDIT',
                amount: 10000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
            ],
          },
        },
      })

      console.log('✅ Created 3 demo finance transactions')
    }
  }

  // ============================================
  // 1. CREATE CUSTOMERS (15)
  // ============================================
  const customers = await Promise.all([
    prisma.customer.create({
      data: {
        id: 'cust-1',
        name: 'Ayşe Yılmaz',
        phone: '+90 555 123 4567',
        email: 'ayse.yilmaz@example.com',
        city: 'İstanbul',
        isProtocol: true,
        stars: 3,
        priority: 'HIGH',
        tags: 'VIP,Abiye',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-10T10:00:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-2',
        name: 'Mehmet Demir',
        phone: '+90 555 234 5678',
        email: 'mehmet.demir@example.com',
        city: 'Ankara',
        isProtocol: false,
        stars: 2,
        priority: 'NORMAL',
        tags: 'Düğün',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-12T14:30:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-3',
        name: 'Fatma Kaya',
        phone: '+90 555 345 6789',
        email: 'fatma.kaya@example.com',
        city: 'İzmir',
        isProtocol: false,
        stars: 1,
        priority: 'LOW',
        tags: 'Günlük',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-08T09:15:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-4',
        name: 'Ali Çelik',
        phone: '+90 555 456 7890',
        city: 'Bursa',
        isProtocol: true,
        stars: 3,
        priority: 'HIGH',
        tags: 'VIP,İş',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-11T16:45:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-5',
        name: 'Zeynep Arslan',
        phone: '+90 555 567 8901',
        email: 'zeynep.arslan@example.com',
        city: 'İstanbul',
        isProtocol: false,
        stars: 2,
        priority: 'NORMAL',
        tags: 'Özel Gün',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-09T11:20:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-6',
        name: 'Ahmet Özkan',
        phone: '+90 555 678 9012',
        email: 'ahmet.ozkan@example.com',
        city: 'Antalya',
        isProtocol: false,
        stars: 1,
        priority: 'LOW',
        tags: 'Tatil',
        status: 'PASSIVE',
        lastActivityAt: new Date('2024-12-15T08:30:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-7',
        name: 'Elif Şahin',
        phone: '+90 555 789 0123',
        email: 'elif.sahin@example.com',
        city: 'İstanbul',
        isProtocol: true,
        stars: 3,
        priority: 'HIGH',
        tags: 'VIP,Abiye,Düğün',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-13T13:10:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-8',
        name: 'Mustafa Kılıç',
        phone: '+90 555 890 1234',
        city: 'Ankara',
        isProtocol: false,
        stars: 2,
        priority: 'NORMAL',
        tags: 'İş',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-07T15:25:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-9',
        name: 'Selin Yıldız',
        phone: '+90 555 901 2345',
        email: 'selin.yildiz@example.com',
        city: 'İzmir',
        isProtocol: false,
        stars: 1,
        priority: 'LOW',
        tags: 'Günlük',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-06T12:40:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-10',
        name: 'Burak Aydın',
        phone: '+90 555 012 3456',
        email: 'burak.aydin@example.com',
        city: 'Bursa',
        isProtocol: true,
        stars: 3,
        priority: 'HIGH',
        tags: 'VIP,İş,Özel Gün',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-12T17:55:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-11',
        name: 'Gamze Çelik',
        phone: '+90 555 123 4567',
        email: 'gamze.celik@example.com',
        city: 'İstanbul',
        isProtocol: false,
        stars: 2,
        priority: 'NORMAL',
        tags: 'Düğün',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-05T10:15:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-12',
        name: 'Emre Koç',
        phone: '+90 555 234 5678',
        city: 'Ankara',
        isProtocol: false,
        stars: 1,
        priority: 'LOW',
        tags: 'Günlük',
        status: 'PASSIVE',
        lastActivityAt: new Date('2024-11-20T14:20:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-13',
        name: 'Deniz Öztürk',
        phone: '+90 555 345 6789',
        email: 'deniz.ozturk@example.com',
        city: 'İzmir',
        isProtocol: true,
        stars: 3,
        priority: 'HIGH',
        tags: 'VIP,Abiye',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-14T09:30:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-14',
        name: 'Cemre Aktaş',
        phone: '+90 555 456 7890',
        email: 'cemre.aktas@example.com',
        city: 'Bursa',
        isProtocol: false,
        stars: 2,
        priority: 'NORMAL',
        tags: 'Özel Gün',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-04T16:10:00Z'),
      },
    }),
    prisma.customer.create({
      data: {
        id: 'cust-15',
        name: 'Kaan Yılmaz',
        phone: '+90 555 567 8901',
        city: 'İstanbul',
        isProtocol: false,
        stars: 1,
        priority: 'LOW',
        tags: 'İş',
        status: 'ACTIVE',
        lastActivityAt: new Date('2025-01-03T11:45:00Z'),
      },
    }),
  ])

  console.log(`✅ Created ${customers.length} customers`)

  // ============================================
  // 2. CREATE PRODUCTS (10)
  // ============================================
  const products = await Promise.all([
    // Takım Elbiseler (5)
    prisma.product.create({
      data: {
        id: 'prod-1',
        name: 'Smokin Takım Elbise',
        model: 'Classic',
        color: 'Siyah',
        size: 'L',
        category: 'Takım Elbise',
        tags: 'Düğün,Gala,Smokin',
        status: 'AVAILABLE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-2',
        name: 'Slim Fit Takım',
        model: 'Modern',
        color: 'Lacivert',
        size: 'M',
        category: 'Takım Elbise',
        tags: 'İş,Düğün,Modern',
        status: 'AVAILABLE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-3',
        name: 'Damat Takımı',
        model: 'Premium',
        color: 'Gri',
        size: 'XL',
        category: 'Takım Elbise',
        tags: 'Düğün,Damat,Premium',
        status: 'IN_USE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-4',
        name: 'Casual Takım',
        model: 'Slim',
        color: 'Kahverengi',
        size: 'M',
        category: 'Takım Elbise',
        tags: 'Casual,Günlük',
        status: 'AVAILABLE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-5',
        name: 'Saten Yelek Takım',
        model: 'Classic',
        color: 'Bordo',
        size: 'L',
        category: 'Takım Elbise',
        tags: 'Düğün,Yelek,Özel',
        status: 'MAINTENANCE',
      },
    }),

    // Aksesuarlar (5)
    prisma.product.create({
      data: {
        id: 'prod-6',
        name: 'Papyon',
        model: 'Standart',
        color: 'Siyah',
        category: 'Aksesuar',
        tags: 'Papyon,Düğün',
        status: 'AVAILABLE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-7',
        name: 'Kravat',
        model: 'İpek',
        color: 'Bordo',
        category: 'Aksesuar',
        tags: 'Kravat,İş',
        status: 'AVAILABLE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-8',
        name: 'Kol Düğmesi',
        model: 'Altın',
        color: 'Gold',
        category: 'Aksesuar',
        tags: 'Kol Düğmesi,Premium',
        status: 'AVAILABLE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-9',
        name: 'Kemer',
        model: 'Deri',
        color: 'Siyah',
        category: 'Aksesuar',
        tags: 'Kemer,Deri',
        status: 'AVAILABLE',
      },
    }),
    prisma.product.create({
      data: {
        id: 'prod-10',
        name: 'Mendil',
        model: 'İpek',
        color: 'Beyaz',
        category: 'Aksesuar',
        tags: 'Mendil,Düğün',
        status: 'AVAILABLE',
      },
    }),
  ])

  console.log(`✅ Created ${products.length} products`)

  // ============================================
  // 2.5. CREATE SUPPLIERS (8)
  // ============================================
  const suppliers = await Promise.all([
    prisma.supplier.upsert({
      where: { id: 'supp-1' },
      update: {
        name: 'Tekstil AŞ',
        phone: '+90 212 555 0101',
        email: 'info@tekstilas.com',
        city: 'İstanbul',
        category: 'FABRIC',
        status: 'ACTIVE',
      },
      create: {
        id: 'supp-1',
        name: 'Tekstil AŞ',
        phone: '+90 212 555 0101',
        email: 'info@tekstilas.com',
        city: 'İstanbul',
        category: 'FABRIC',
        status: 'ACTIVE',
      },
    }),
    prisma.supplier.create({
      data: {
        id: 'supp-2',
        name: 'Aksesuar Dünyası',
        phone: '+90 216 555 0202',
        email: 'siparis@aksesuar.com',
        city: 'Bursa',
        category: 'ACCESSORY',
        status: 'ACTIVE',
      },
    }),
    prisma.supplier.create({
      data: {
        id: 'supp-3',
        name: 'Temizlik Merkezi',
        phone: '+90 232 555 0303',
        email: 'hizmet@temizlik.com',
        city: 'İzmir',
        category: 'CLEANING',
        status: 'ACTIVE',
      },
    }),
    prisma.supplier.create({
      data: {
        id: 'supp-4',
        name: 'Tadilat Atölyesi',
        phone: '+90 312 555 0404',
        email: 'tadilat@atolye.com',
        city: 'Ankara',
        category: 'ALTERATION',
        status: 'ACTIVE',
      },
    }),
    prisma.supplier.create({
      data: {
        id: 'supp-5',
        name: 'Kumaş Toptan',
        phone: '+90 224 555 0505',
        email: 'toptan@kumas.com',
        city: 'Bursa',
        category: 'FABRIC',
        status: 'ACTIVE',
      },
    }),
    prisma.supplier.create({
      data: {
        id: 'supp-6',
        name: 'Düğme & Fermuar',
        phone: '+90 212 555 0606',
        city: 'İstanbul',
        category: 'ACCESSORY',
        status: 'PASSIVE',
      },
    }),
    prisma.supplier.create({
      data: {
        id: 'supp-7',
        name: 'Özel Temizlik',
        phone: '+90 216 555 0707',
        email: 'ozel@temizlik.com',
        city: 'Bursa',
        category: 'CLEANING',
        status: 'ACTIVE',
      },
    }),
    prisma.supplier.create({
      data: {
        id: 'supp-8',
        name: 'Hızlı Tadilat',
        phone: '+90 232 555 0808',
        city: 'İzmir',
        category: 'ALTERATION',
        status: 'ACTIVE',
      },
    }),
  ])

  console.log(`✅ Created ${suppliers.length} suppliers`)

  // ============================================
  // 3. CREATE ORDERS (15: 10 TAILORING, 5 RENTAL)
  // ============================================

  // TAILORING ORDERS (10)
  const tailoringOrders = await Promise.all([
    prisma.order.create({
      data: {
        id: 'order-1',
        type: 'TAILORING',
        customerId: 'cust-1',
        organization: 'Yılmaz Ailesi',
        deliveryDate: new Date('2025-11-15'),
        total: 50000, // 500 TL in cents
        collected: 20000, // 200 TL
        status: 'half_ready',
        stage: 'half_ready',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-2',
        type: 'TAILORING',
        customerId: 'cust-2',
        deliveryDate: new Date('2025-11-20'),
        total: 75000, // 750 TL
        collected: 75000, // Paid in full
        status: 'delivered',
        stage: 'delivered',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-3',
        type: 'TAILORING',
        customerId: 'cust-3',
        organization: 'Kaya Holding',
        deliveryDate: new Date('2025-12-01'),
        total: 100000, // 1000 TL
        collected: 30000, // 300 TL
        status: 'pending_approval',
        stage: 'pending_approval',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-4',
        type: 'TAILORING',
        customerId: 'cust-4',
        deliveryDate: new Date('2025-11-25'),
        total: 45000, // 450 TL
        collected: 45000,
        status: 'fully_ready',
        stage: 'fully_ready',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-5',
        type: 'TAILORING',
        customerId: 'cust-5',
        organization: 'Arslan Tekstil',
        deliveryDate: new Date('2025-12-10'),
        total: 85000, // 850 TL
        collected: 0,
        status: 'almost_ready',
        stage: 'almost_ready',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-6',
        type: 'TAILORING',
        customerId: 'cust-1',
        deliveryDate: new Date('2025-10-20'),
        total: 30000,
        collected: 30000,
        status: 'cancelled',
        stage: 'cancelled',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-7',
        type: 'TAILORING',
        customerId: 'cust-2',
        deliveryDate: new Date('2025-11-30'),
        total: 60000,
        collected: 15000,
        status: 'half_ready',
        stage: 'half_ready',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-8',
        type: 'TAILORING',
        customerId: 'cust-3',
        deliveryDate: new Date('2025-12-05'),
        total: 95000,
        collected: 50000,
        status: 'almost_ready',
        stage: 'almost_ready',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-9',
        type: 'TAILORING',
        customerId: 'cust-4',
        deliveryDate: new Date('2025-11-18'),
        total: 40000,
        collected: 40000,
        status: 'delivered',
        stage: 'delivered',
      },
    }),
    prisma.order.create({
      data: {
        id: 'order-10',
        type: 'TAILORING',
        customerId: 'cust-5',
        deliveryDate: new Date('2025-12-15'),
        total: 70000,
        collected: 20000,
        status: 'pending_approval',
        stage: 'pending_approval',
      },
    }),
  ])

  console.log(`✅ Created ${tailoringOrders.length} TAILORING orders`)

  // RENTAL ORDERS (5) + RENTALS
  const rentalOrder1 = await prisma.order.create({
    data: {
      id: 'order-11',
      type: 'RENTAL',
      customerId: 'cust-1',
      organization: 'Düğün Organizasyonu',
      total: 20000, // 200 TL
      collected: 20000,
      status: 'delivered',
      stage: 'delivered',
      rental: {
        create: {
          id: 'rental-1',
          productId: 'prod-1',
// Smokin
          start: new Date('2025-10-20'),
          end: new Date('2025-10-22'),
          organization: 'Düğün Organizasyonu',
        },
      },
    },
  })

  const rentalOrder2 = await prisma.order.create({
    data: {
      id: 'order-12',
      type: 'RENTAL',
      customerId: 'cust-2',
      total: 15000, // 150 TL
      collected: 15000,
      status: 'completed',
      stage: 'completed',
      rental: {
        create: {
          id: 'rental-2',
          productId: 'prod-2',
// Slim Fit
          start: new Date('2025-10-10'),
          end: new Date('2025-10-12'),
        },
      },
    },
  })

  const rentalOrder3 = await prisma.order.create({
    data: {
      id: 'order-13',
      type: 'RENTAL',
      customerId: 'cust-3',
      organization: 'Kaya Holding Etkinliği',
      total: 25000, // 250 TL
      collected: 12500,
      status: 'approved',
      stage: 'approved',
      rental: {
        create: {
          id: 'rental-3',
          productId: 'prod-3',
// Damat Takımı
          start: new Date('2025-11-05'),
          end: new Date('2025-11-07'),
          organization: 'Kaya Holding Etkinliği',
        },
      },
    },
  })

  const       rentalOrder4 = await prisma.order.create({
    data: {
      id: 'order-14',
      type: 'RENTAL',
      customerId: 'cust-4',
      total: 18000, // 180 TL
      collected: 18000,
      status: 'delivered',
      stage: 'delivered',
      rental: {
        create: {
          id: 'rental-4',
          productId: 'prod-4', // Casual Takım
          start: new Date('2025-10-25'),
          end: new Date('2025-10-27'),
        },
      },
    },
  })

  const rentalOrder5 = await prisma.order.create({
    data: {
      id: 'order-15',
      type: 'RENTAL',
      customerId: 'cust-5',
      organization: 'Arslan Tekstil Gala',
      total: 30000, // 300 TL
      collected: 0,
      status: 'approved',
      stage: 'approved',
      rental: {
        create: {
          id: 'rental-5',
          productId: 'prod-1', // Smokin (yeniden)
          start: new Date('2025-11-10'),
          end: new Date('2025-11-12'),
        },
      },
    },
  })

  console.log('✅ Created 5 RENTAL orders with rentals')

  // ============================================
  // 4. CREATE STOCK CARDS (5)
  // ============================================
  console.log('📦 Creating stock cards...')
  
  const stockCards = await Promise.all([
    prisma.stockCard.upsert({
      where: { id: 'stock-1' },
      update: {
        code: 'STK-001',
        name: 'Kumaş - Lacivert',
        description: 'Lacivert renkli pamuk kumaş',
        category: 'Kumaş',
        type: 'Pamuk',
        kind: 'Düz',
        group: 'Günlük',
        unit: 'metre',
        criticalQty: 50,
        location: 'MAIN',
        supplierId: 'supp-1',
        tags: 'lacivert,kumaş,pamuk',
        status: 'ACTIVE',
      },
      create: {
        id: 'stock-1',
        code: 'STK-001',
        name: 'Kumaş - Lacivert',
        description: 'Lacivert renkli pamuk kumaş',
        category: 'Kumaş',
        type: 'Pamuk',
        kind: 'Düz',
        group: 'Günlük',
        unit: 'metre',
        criticalQty: 50,
        location: 'MAIN',
        supplierId: 'supp-1',
        tags: 'lacivert,kumaş,pamuk',
        status: 'ACTIVE',
      },
    }),
    prisma.stockCard.create({
      data: {
        id: 'stock-2',
        code: 'STK-002',
        name: 'Kumaş - Siyah',
        description: 'Siyah renkli pamuk kumaş',
        category: 'Kumaş',
        type: 'Pamuk',
        kind: 'Düz',
        group: 'Günlük',
        unit: 'metre',
        criticalQty: 30,
        location: 'MAIN',
        supplierId: 'supp-1',
        tags: 'siyah,kumaş,pamuk',
        status: 'ACTIVE',
      },
    }),
    prisma.stockCard.create({
      data: {
        id: 'stock-3',
        code: 'STK-003',
        name: 'Düğme - Beyaz',
        description: 'Beyaz plastik düğmeler',
        category: 'Aksesuar',
        type: 'Plastik',
        kind: 'Düğme',
        group: 'Günlük',
        unit: 'adet',
        criticalQty: 100,
        location: 'MAIN',
        supplierId: 'supp-2',
        tags: 'düğme,beyaz,plastik',
        status: 'ACTIVE',
      },
    }),
    prisma.stockCard.create({
      data: {
        id: 'stock-4',
        code: 'STK-004-NEW',
        name: 'İplik - Beyaz',
        description: 'Beyaz polyester iplik',
        category: 'Aksesuar',
        type: 'Polyester',
        kind: 'İplik',
        group: 'Günlük',
        unit: 'makara',
        criticalQty: 20,
        location: 'MAIN',
        supplierId: 'supp-2',
        tags: 'iplik,beyaz,polyester',
        status: 'ACTIVE',
      },
    }),
    prisma.stockCard.create({
      data: {
        id: 'stock-5',
        code: 'STK-005',
        name: 'Astarlık - Beyaz',
        description: 'Beyaz astarlık kumaş',
        category: 'Kumaş',
        type: 'Pamuk',
        kind: 'Astarlık',
        group: 'Günlük',
        unit: 'metre',
        criticalQty: 25,
        location: 'MAIN',
        supplierId: 'supp-1',
        tags: 'astarlık,beyaz,pamuk',
        status: 'ACTIVE',
      },
    }),
  ])

  console.log(`✅ Created ${stockCards.length} stock cards`)

  // ============================================
  // 5. CREATE STOCK MOVEMENTS (10)
  // ============================================
  console.log('📦 Creating stock movements...')
  
  const stockMovements = await Promise.all([
    // Initial stock entries
    prisma.stockMovement.create({
      data: {
        id: 'mov-1',
        type: 'IN',
        stockCardId: 'stock-1',
        qty: 100,
        unit: 'metre',
        warehouse: 'MAIN',
        date: new Date('2024-01-01'),
        note: 'İlk stok girişi',
        referenceType: 'OTHER',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-2',
        type: 'IN',
        stockCardId: 'stock-2',
        qty: 80,
        unit: 'metre',
        warehouse: 'MAIN',
        date: new Date('2024-01-01'),
        note: 'İlk stok girişi',
        referenceType: 'OTHER',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-3',
        type: 'IN',
        stockCardId: 'stock-3',
        qty: 500,
        unit: 'adet',
        warehouse: 'MAIN',
        date: new Date('2024-01-01'),
        note: 'İlk stok girişi',
        referenceType: 'OTHER',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-4',
        type: 'IN',
        stockCardId: 'stock-4',
        qty: 50,
        unit: 'makara',
        warehouse: 'MAIN',
        date: new Date('2024-01-01'),
        note: 'İlk stok girişi',
        referenceType: 'OTHER',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-5',
        type: 'IN',
        stockCardId: 'stock-5',
        qty: 60,
        unit: 'metre',
        warehouse: 'MAIN',
        date: new Date('2024-01-01'),
        note: 'İlk stok girişi',
        referenceType: 'OTHER',
        createdBy: 'system',
      },
    }),
    // Consumption movements
    prisma.stockMovement.create({
      data: {
        id: 'mov-6',
        type: 'OUT',
        stockCardId: 'stock-1',
        qty: 5,
        unit: 'metre',
        warehouse: 'MAIN',
        date: new Date('2024-02-15'),
        note: 'Smokin üretimi için kullanım',
        referenceType: 'TAILORING',
        referenceId: 'order-1',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-7',
        type: 'OUT',
        stockCardId: 'stock-2',
        qty: 3,
        unit: 'metre',
        warehouse: 'MAIN',
        date: new Date('2024-02-20'),
        note: 'Takım elbise üretimi için kullanım',
        referenceType: 'TAILORING',
        referenceId: 'order-2',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-8',
        type: 'OUT',
        stockCardId: 'stock-3',
        qty: 8,
        unit: 'adet',
        warehouse: 'MAIN',
        date: new Date('2024-02-15'),
        note: 'Smokin üretimi için kullanım',
        referenceType: 'TAILORING',
        referenceId: 'order-1',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-9',
        type: 'OUT',
        stockCardId: 'stock-4',
        qty: 2,
        unit: 'makara',
        warehouse: 'MAIN',
        date: new Date('2024-02-15'),
        note: 'Smokin üretimi için kullanım',
        referenceType: 'TAILORING',
        referenceId: 'order-1',
        createdBy: 'system',
      },
    }),
    prisma.stockMovement.create({
      data: {
        id: 'mov-10',
        type: 'OUT',
        stockCardId: 'stock-5',
        qty: 1,
        unit: 'metre',
        warehouse: 'MAIN',
        date: new Date('2024-02-15'),
        note: 'Smokin üretimi için kullanım',
        referenceType: 'TAILORING',
        referenceId: 'order-1',
        createdBy: 'system',
      },
    }),
  ])

  console.log(`✅ Created ${stockMovements.length} stock movements`)

  // ============================================
  // 6. CREATE AGENDA EVENTS (8)
  // ============================================
  const agendaEvents = await Promise.all([
    // ALTERATION (3)
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-1',
        productId: 'prod-1',
        type: 'ALTERATION',
        start: new Date('2025-10-23'),
        end: new Date('2025-10-24'),
        note: 'Kol boyu tadilat',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-2',
        productId: 'prod-2',
        type: 'ALTERATION',
        start: new Date('2025-10-28'),
        end: new Date('2025-10-29'),
        note: 'Bel tadilat',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-3',
        productId: 'prod-3',
        type: 'ALTERATION',
        start: new Date('2025-11-01'),
        end: new Date('2025-11-02'),
        note: 'Pantolon paça',
      },
    }),

    // DRY_CLEANING (3)
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-4',
        productId: 'prod-1',
        type: 'DRY_CLEANING',
        start: new Date('2025-10-30'),
        end: new Date('2025-10-31'),
        note: 'Düğünden sonra temizlik',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-5',
        productId: 'prod-2',
        type: 'DRY_CLEANING',
        start: new Date('2025-11-08'),
        end: new Date('2025-11-09'),
        note: 'Periyodik temizlik',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-6',
        productId: 'prod-3',
        type: 'DRY_CLEANING',
        start: new Date('2025-10-26'),
        end: new Date('2025-10-27'),
        note: 'Saten kumaş özel temizlik',
      },
    }),

    // OUT_OF_SERVICE (2)
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-7',
        productId: 'prod-4',
        type: 'OUT_OF_SERVICE',
        start: new Date('2025-10-18'),
        end: new Date('2025-10-25'),
        note: 'Yıpranma nedeniyle bakım',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-8',
        productId: 'prod-5',
        type: 'OUT_OF_SERVICE',
        start: new Date('2025-11-13'),
        end: new Date('2025-11-15'),
        note: 'Düğme değişimi',
      },
    }),
  ])

  console.log(`✅ Created ${agendaEvents.length} agenda events`)

  // ============================================
  // 7. CREATE PURCHASES (12)
  // ============================================
  const purchases = await Promise.all([
    // Basit test verileri - Schema'ya uygun
    prisma.purchase.create({
      data: {
        id: 'purchase-1',
        supplierId: 'supp-1',
        type: 'STOCK',
        status: 'ORDERED',
        paymentStatus: 'UNPAID',
        date: new Date('2025-10-20'),
        dueDate: new Date('2025-11-20'),
        note: 'Kumaş alımı - Smokin takımlar için',
        subTotal: 500000, // 5,000 TL
        vatTot: 90000,    // 900 TL
        total: 590000,    // 5,900 TL
        paid: 0,
        items: {
          create: [
            {
              productType: 'PRODUCT',
              qtyOrdered: 10,
              qtyReceived: 0,
              unitPrice: 50000, // 500 TL per unit
              lineSubTotal: 500000,
              lineVat: 90000,
              lineTotal: 590000
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-2',
        supplierId: 'supp-2',
        type: 'EXPENSE',
        status: 'RECEIVED',
        paymentStatus: 'PAID',
        date: new Date('2025-10-18'),
        dueDate: new Date('2025-10-25'),
        note: 'Elektrik faturası - Ekim ayı',
        subTotal: 150000, // 1,500 TL
        vatTot: 27000,    // 270 TL
        total: 177000,    // 1,770 TL
        paid: 177000,
        items: {
          create: [
            {
              productType: 'SERVICE',
              qtyOrdered: 1,
              qtyReceived: 1,
              unitPrice: 150000,
              lineSubTotal: 150000,
              lineVat: 27000,
              lineTotal: 177000
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-3',
        supplierId: 'supp-3',
        type: 'INVENTORY',
        status: 'PARTIAL_RECEIVED',
        paymentStatus: 'PARTIAL',
        date: new Date('2025-10-15'),
        dueDate: new Date('2025-11-15'),
        note: 'Dikiş makinesi yedek parçaları',
        subTotal: 300000, // 3,000 TL
        vatTot: 54000,    // 540 TL
        total: 354000,    // 3,540 TL
        paid: 177000,     // 1,770 TL (yarısı ödenmiş)
        items: {
          create: [
            {
              productType: 'PRODUCT',
              qtyOrdered: 5,
              qtyReceived: 2,
              unitPrice: 60000,
              lineSubTotal: 300000,
              lineVat: 54000,
              lineTotal: 354000
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-4',
        supplierId: 'supp-1',
        type: 'STOCK',
        status: 'DRAFT',
        paymentStatus: 'UNPAID',
        date: new Date('2025-10-22'),
        note: 'Taslak sipariş - iplikler',
        subTotal: 80000,  // 800 TL
        vatTot: 14400,    // 144 TL
        total: 94400,     // 944 TL
        paid: 0,
        items: {
          create: [
            {
              productType: 'PRODUCT',
              qtyOrdered: 20,
              qtyReceived: 0,
              unitPrice: 4000,
              lineSubTotal: 80000,
              lineVat: 14400,
              lineTotal: 94400
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-5',
        supplierId: 'supp-2',
        type: 'EXPENSE',
        status: 'CLOSED',
        paymentStatus: 'PAID',
        date: new Date('2025-10-10'),
        dueDate: new Date('2025-10-20'),
        note: 'Su faturası',
        subTotal: 120000, // 1,200 TL
        vatTot: 21600,    // 216 TL
        total: 141600,    // 1,416 TL
        paid: 141600,
        items: {
          create: [
            {
              productType: 'SERVICE',
              qtyOrdered: 1,
              qtyReceived: 1,
              unitPrice: 120000,
              lineSubTotal: 120000,
              lineVat: 21600,
              lineTotal: 141600
            }
          ]
        }
      }
    }),
    // Basit ek test verileri
    prisma.purchase.create({
      data: {
        id: 'purchase-6',
        supplierId: 'supp-1',
        type: 'STOCK',
        status: 'RECEIVED',
        paymentStatus: 'UNPAID',
        date: new Date('2025-10-25'),
        dueDate: new Date('2025-11-25'),
        note: 'Yeni sezon kumaşları - Pamuklu',
        subTotal: 750000, // 7,500 TL
        vatTot: 135000,   // 1,350 TL
        chargeTot: 25000, // 250 TL
        discountTot: 50000, // 500 TL
        total: 860000,    // 8,600 TL (subTotal + vatTot + chargeTot - discountTot)
        paid: 0,
        items: {
          create: [
            {
              qtyOrdered: 15,
              qtyReceived: 15,
              unitPrice: 50000, // 500 TL per unit
              lineSubTotal: 750000,
              lineVat: 135000,
              lineTotal: 835000 // 750000 + 135000 - 50000 (discount)
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-7',
        supplierId: 'supp-3',
        type: 'EXPENSE',
        status: 'PENDING',
        paymentStatus: 'UNPAID',
        date: new Date('2025-10-28'),
        dueDate: new Date('2025-11-15'),
        note: 'İnternet ve telefon faturası',
        subTotal: 45000,  // 450 TL
        vatTot: 8100,     // 81 TL
        total: 53100,     // 531 TL
        paid: 0,
        items: {
          create: [
            {
              qtyOrdered: 1,
              qtyReceived: 0,
              unitPrice: 45000,
              lineSubTotal: 45000,
              lineVat: 8100,
              lineTotal: 53100
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-8',
        supplierId: 'supp-2',
        type: 'INVENTORY',
        status: 'ORDERED',
        paymentStatus: 'UNPAID',
        date: new Date('2025-10-30'),
        dueDate: new Date('2025-12-15'),
        note: 'Yeni dikiş makineleri - Brother serisi',
        subTotal: 1200000, // 12,000 TL
        vatTot: 216000,    // 2,160 TL
        chargeTot: 50000,  // 500 TL
        discountTot: 100000, // 1,000 TL
        total: 1366000,    // 13,660 TL (subTotal + vatTot + chargeTot - discountTot)
        paid: 0,
        items: {
          create: [
            {
              qtyOrdered: 2,
              qtyReceived: 0,
              unitPrice: 600000, // 6,000 TL per unit
              lineSubTotal: 1200000,
              lineVat: 216000,
              lineTotal: 1380000 // 1200000 + 216000 - 100000 (discount)
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-9',
        supplierId: 'supp-1',
        type: 'STOCK',
        status: 'CANCELLED',
        paymentStatus: 'UNPAID',
        date: new Date('2025-10-05'),
        note: 'İptal edilen sipariş - Kalite sorunu',
        subTotal: 200000, // 2,000 TL
        vatTot: 36000,    // 360 TL
        total: 236000,    // 2,360 TL
        paid: 0,
        items: {
          create: [
            {
              qtyOrdered: 50,
              qtyReceived: 0,
              unitPrice: 4000,
              lineSubTotal: 200000,
              lineVat: 36000,
              lineTotal: 236000
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-10',
        supplierId: 'supp-3',
        type: 'EXPENSE',
        status: 'RECEIVED',
        paymentStatus: 'PARTIAL',
        date: new Date('2025-10-12'),
        dueDate: new Date('2025-11-12'),
        note: 'Kira ödemesi - Ekim ayı',
        subTotal: 300000, // 3,000 TL
        vatTot: 0,        // Kira için KDV yok
        total: 300000,    // 3,000 TL
        paid: 150000,     // 1,500 TL (yarısı ödenmiş)
        items: {
          create: [
            {
              qtyOrdered: 1,
              qtyReceived: 1,
              unitPrice: 300000,
              lineSubTotal: 300000,
              lineVat: 0,
              lineTotal: 300000
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-11',
        supplierId: 'supp-2',
        type: 'STOCK',
        status: 'DRAFT',
        paymentStatus: 'UNPAID',
        date: new Date('2025-11-01'),
        note: 'Taslak - Yılbaşı dekorasyon malzemeleri',
        subTotal: 35000,  // 350 TL
        vatTot: 6300,     // 63 TL
        total: 41300,     // 413 TL
        paid: 0,
        items: {
          create: [
            {
              qtyOrdered: 7,
              qtyReceived: 0,
              unitPrice: 5000, // 50 TL per unit
              lineSubTotal: 35000,
              lineVat: 6300,
              lineTotal: 41300
            }
          ]
        }
      }
    }),
    prisma.purchase.create({
      data: {
        id: 'purchase-12',
        supplierId: 'supp-1',
        type: 'INVENTORY',
        status: 'RECEIVED',
        paymentStatus: 'PAID',
        date: new Date('2025-09-15'),
        dueDate: new Date('2025-10-15'),
        note: 'Eylül ayı temizlik malzemeleri',
        subTotal: 85000,  // 850 TL
        vatTot: 15300,    // 153 TL
        chargeTot: 5000,  // 50 TL
        total: 105300,    // 1,053 TL (subTotal + vatTot + chargeTot)
        paid: 105300,
        items: {
          create: [
            {
              productType: 'SERVICE',
              qtyOrdered: 1,
              qtyReceived: 1,
              unitPrice: 85000,
              lineSubTotal: 85000,
              lineVat: 15300,
              lineTotal: 105300 // 85000 + 15300 + 5000 (charge)
            }
          ]
        }
      }
    })
  ])

  console.log(`✅ Created ${purchases.length} purchases`)

  // ============================================
  // CONTRACT TEMPLATES
  // ============================================
  console.log('📄 Creating contract templates...')
  
  const contractTemplates = await Promise.all([
    prisma.contractTemplate.create({
      data: {
        name: 'Dikim Sözleşmesi',
        type: 'DİKİM',
        version: '1.0',
        content: `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dikim Sözleşmesi</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .contract-info { margin-bottom: 20px; }
        .terms { margin: 20px 0; }
        .signature { margin-top: 50px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>DİKİM SÖZLEŞMESİ</h1>
        <p>Sözleşme No: {{contractNumber}}</p>
    </div>
    
    <div class="contract-info">
        <p><strong>Müşteri:</strong> {{customerName}}</p>
        <p><strong>Telefon:</strong> {{customerPhone}}</p>
        <p><strong>Sipariş Tarihi:</strong> {{orderDate}}</p>
        <p><strong>Teslim Tarihi:</strong> {{deliveryDate}}</p>
        <p><strong>Toplam Tutar:</strong> {{totalAmount}} TL</p>
    </div>
    
    <div class="terms">
        <h3>Sözleşme Şartları:</h3>
        <ol>
            <li>Dikim işlemi {{deliveryDate}} tarihine kadar tamamlanacaktır.</li>
            <li>Müşteri ölçüleri doğru verilmiştir ve sorumluluk müşteriye aittir.</li>
            <li>Değişiklik talepleri teslim tarihinden 3 gün öncesine kadar kabul edilir.</li>
            <li>Ödeme {{totalAmount}} TL tutarında teslim sırasında yapılacaktır.</li>
            <li>İptal durumunda %50 ücret kesintisi uygulanır.</li>
        </ol>
    </div>
    
    <div class="signature">
        <p>Müşteri Adı Soyadı: _________________</p>
        <p>İmza: _________________</p>
        <p>Tarih: _________________</p>
    </div>
</body>
</html>`
      }
    }),
    prisma.contractTemplate.create({
      data: {
        name: 'Kiralama Sözleşmesi',
        type: 'KİRALAMA',
        version: '1.0',
        content: `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Kiralama Sözleşmesi</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .contract-info { margin-bottom: 20px; }
        .terms { margin: 20px 0; }
        .signature { margin-top: 50px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>KİRALAMA SÖZLEŞMESİ</h1>
        <p>Sözleşme No: {{contractNumber}}</p>
    </div>
    
    <div class="contract-info">
        <p><strong>Müşteri:</strong> {{customerName}}</p>
        <p><strong>Telefon:</strong> {{customerPhone}}</p>
        <p><strong>Kiralama Tarihi:</strong> {{orderDate}}</p>
        <p><strong>İade Tarihi:</strong> {{deliveryDate}}</p>
        <p><strong>Günlük Ücret:</strong> {{dailyRate}} TL</p>
        <p><strong>Toplam Tutar:</strong> {{totalAmount}} TL</p>
    </div>
    
    <div class="terms">
        <h3>Sözleşme Şartları:</h3>
        <ol>
            <li>Kiralama süresi {{rentalDays}} gündür.</li>
            <li>Ürün hasarında tamir bedeli müşteriye aittir.</li>
            <li>Gecikme durumunda günlük {{dailyRate}} TL ek ücret alınır.</li>
            <li>Ödeme kiralama başlangıcında yapılacaktır.</li>
            <li>İptal durumunda %25 ücret kesintisi uygulanır.</li>
        </ol>
    </div>
    
    <div class="signature">
        <p>Müşteri Adı Soyadı: _________________</p>
        <p>İmza: _________________</p>
        <p>Tarih: _________________</p>
    </div>
</body>
</html>`
      }
    })
  ])

  console.log(`✅ Created ${contractTemplates.length} contract templates`)

  // ============================================
  // SUMMARY
  // ============================================
  console.log('\n🎉 Database seeding completed successfully!')
  console.log('📊 Summary:')
  console.log(`   - ${customers.length} Customers`)
  console.log(`   - ${suppliers.length} Suppliers`)
  console.log(`   - ${products.length} Products`)
  console.log(`   - 10 TAILORING Orders`)
  console.log(`   - 5 RENTAL Orders (with rentals)`)
  console.log(`   - ${contractTemplates.length} Contract Templates`)
  console.log(`   - ${stockCards.length} Stock Cards (5 different items)`)
  console.log(`   - ${stockMovements.length} Stock Movements (5 IN, 5 OUT)`)
  console.log(`   - ${agendaEvents.length} Agenda Events (3 Alteration, 3 Dry Cleaning, 2 Out of Service)`)
  console.log(`   - ${purchases.length} Purchases (5 Stock, 4 Expense, 3 Inventory)`)
  if (process.env.SEED_FINANCE === 'true') {
    console.log(`   - 5 Finance Accounts (Kasa, Banka, POS, Tedarikçi POS, Kredi Kartı)`)
    if (process.env.SEED_FINANCE_DEMO === 'true') {
      console.log(`   - 3 Demo Finance Transactions (Tahsilat, Ödeme, Virman)`)
    }
  }
}

main()
  .catch((e) => {
    console.error('❌ Error during seeding:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })