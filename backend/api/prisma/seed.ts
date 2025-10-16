import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Starting database seeding...')

  // Clean existing data
  await prisma.posting.deleteMany()
  await prisma.transaction.deleteMany()
  await prisma.account.deleteMany()
  await prisma.agendaEvent.deleteMany()
  await prisma.rental.deleteMany()
  await prisma.order.deleteMany()
  await prisma.product.deleteMany()
  await prisma.customer.deleteMany()
  await prisma.supplier.deleteMany()

  console.log('🗑️  Cleaned existing data')

  // ============================================
  // 0. CREATE FINANCE ACCOUNTS (if SEED_FINANCE=true)
  // ============================================
  if (process.env.SEED_FINANCE === 'true') {
    console.log('💰 Creating finance accounts...')
    
    const accounts = await Promise.all([
      prisma.account.create({
        data: {
          id: 'acc-1',
          type: 'CASH',
          name: 'Kasa',
          currency: 'TRY',
          isActive: true,
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-2',
          type: 'BANK',
          name: 'Banka 1',
          currency: 'TRY',
          isActive: true,
        },
      }),
      prisma.account.create({
        data: {
          id: 'acc-3',
          type: 'POS',
          name: 'POS 1',
          currency: 'TRY',
          isActive: true,
        },
      }),
    ])

    console.log(`✅ Created ${accounts.length} finance accounts`)

    // Create demo transactions if SEED_FINANCE_DEMO=true
    if (process.env.SEED_FINANCE_DEMO === 'true') {
      console.log('💰 Creating demo finance transactions...')
      
      // Demo Transaction 1: Tahsilat (Müşteriden Kasa)
      const transaction1 = await prisma.transaction.create({
        data: {
          id: 'txn-1',
          kind: 'RECEIVABLE',
          amount: 50000, // 500 TL
          currency: 'TRY',
          rateToTRY: 1.0,
          note: 'Müşteri ödemesi',
          customerId: 'cust-1',
          createdBy: 'system',
          postings: {
            create: [
              {
                accountId: 'acc-1', // Kasa
                dc: 'DEBIT',
                amount: 50000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
              {
                accountId: 'acc-1', // Sanal müşteri alacağı (şimdilik aynı hesap)
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
          supplierId: 'supp-1',
          createdBy: 'system',
          postings: {
            create: [
              {
                accountId: 'acc-1', // Sanal tedarikçi borcu (şimdilik aynı hesap)
                dc: 'DEBIT',
                amount: 25000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
              {
                accountId: 'acc-2', // Banka
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
                accountId: 'acc-1', // Kasa
                dc: 'DEBIT',
                amount: 10000,
                currency: 'TRY',
                rateToTRY: 1.0,
              },
              {
                accountId: 'acc-2', // Banka
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
    prisma.supplier.create({
      data: {
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
        status: 'ACTIVE',
        stage: 'IN_PROGRESS_50',
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
        status: 'COMPLETED',
        stage: 'DELIVERED',
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
        status: 'ACTIVE',
        stage: 'CREATED',
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
        status: 'ACTIVE',
        stage: 'READY',
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
        status: 'ACTIVE',
        stage: 'IN_PROGRESS_80',
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
        status: 'CANCELLED',
        stage: 'CREATED',
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
        status: 'ACTIVE',
        stage: 'IN_PROGRESS_50',
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
        status: 'ACTIVE',
        stage: 'IN_PROGRESS_80',
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
        status: 'COMPLETED',
        stage: 'DELIVERED',
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
        status: 'ACTIVE',
        stage: 'CREATED',
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
      status: 'ACTIVE',
      stage: 'PICKED_UP',
      rental: {
        create: {
          id: 'rental-1',
          productId: 'prod-1', // Smokin
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
      status: 'COMPLETED',
      stage: 'RETURNED',
      rental: {
        create: {
          id: 'rental-2',
          productId: 'prod-2', // Slim Fit
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
      status: 'ACTIVE',
      stage: 'BOOKED',
      rental: {
        create: {
          id: 'rental-3',
          productId: 'prod-3', // Damat Takımı
          start: new Date('2025-11-05'),
          end: new Date('2025-11-07'),
          organization: 'Kaya Holding Etkinliği',
        },
      },
    },
  })

  const rentalOrder4 = await prisma.order.create({
    data: {
      id: 'order-14',
      type: 'RENTAL',
      customerId: 'cust-4',
      total: 18000, // 180 TL
      collected: 18000,
      status: 'ACTIVE',
      stage: 'PICKED_UP',
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
      status: 'ACTIVE',
      stage: 'BOOKED',
      rental: {
        create: {
          id: 'rental-5',
          productId: 'prod-1', // Smokin (yeniden)
          start: new Date('2025-11-10'),
          end: new Date('2025-11-12'),
          organization: 'Arslan Tekstil Gala',
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
    prisma.stockCard.create({
      data: {
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
        code: 'STK-004',
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
        productId: 'prod-4',
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
        productId: 'prod-2',
        type: 'DRY_CLEANING',
        start: new Date('2025-10-30'),
        end: new Date('2025-10-31'),
        note: 'Düğünden sonra temizlik',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-5',
        productId: 'prod-3',
        type: 'DRY_CLEANING',
        start: new Date('2025-11-08'),
        end: new Date('2025-11-09'),
        note: 'Periyodik temizlik',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-6',
        productId: 'prod-5',
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
        productId: 'prod-5',
        type: 'OUT_OF_SERVICE',
        start: new Date('2025-10-18'),
        end: new Date('2025-10-25'),
        note: 'Yıpranma nedeniyle bakım',
      },
    }),
    prisma.agendaEvent.create({
      data: {
        id: 'agenda-8',
        productId: 'prod-3',
        type: 'OUT_OF_SERVICE',
        start: new Date('2025-11-13'),
        end: new Date('2025-11-15'),
        note: 'Düğme değişimi',
      },
    }),
  ])

  console.log(`✅ Created ${agendaEvents.length} agenda events`)

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
  console.log(`   - ${stockCards.length} Stock Cards (5 different items)`)
  console.log(`   - ${stockMovements.length} Stock Movements (5 IN, 5 OUT)`)
  console.log(`   - ${agendaEvents.length} Agenda Events (3 Alteration, 3 Dry Cleaning, 2 Out of Service)`)
  if (process.env.SEED_FINANCE === 'true') {
    console.log(`   - 3 Finance Accounts (Kasa, Banka, POS)`)
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
