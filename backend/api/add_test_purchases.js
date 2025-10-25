const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Adding test purchase data...')

  try {
    // Check if suppliers exist
    const suppliers = await prisma.supplier.findMany()
    console.log(`Found ${suppliers.length} suppliers`)

    if (suppliers.length === 0) {
      console.log('Creating basic suppliers...')
      await prisma.supplier.createMany({
        data: [
          { id: 'supplier-1', name: 'Test Supplier 1', email: 'supplier1@test.com', phone: '555-0001' },
          { id: 'supplier-2', name: 'Test Supplier 2', email: 'supplier2@test.com', phone: '555-0002' },
          { id: 'supplier-3', name: 'Test Supplier 3', email: 'supplier3@test.com', phone: '555-0003' }
        ]
      })
    }

    // Check if products exist
    const products = await prisma.product.findMany()
    console.log(`Found ${products.length} products`)

    if (products.length === 0) {
      console.log('Creating basic products...')
      await prisma.product.createMany({
        data: [
          { id: 'prod-1', name: 'Test Product 1', category: 'Kumaş' },
          { id: 'prod-2', name: 'Test Product 2', category: 'Aksesuar' },
          { id: 'prod-3', name: 'Test Product 3', category: 'Makine' },
          { id: 'prod-4', name: 'Test Product 4', category: 'İplik' },
          { id: 'prod-5', name: 'Test Product 5', category: 'Hizmet' }
        ]
      })
    }

    // Clean existing purchases
    await prisma.purchaseItem.deleteMany()
    await prisma.purchase.deleteMany()

    // Create test purchases
    const purchases = await Promise.all([
      prisma.purchase.create({
        data: {
          id: 'purchase-1',
          supplierId: 'supplier-1',
          type: 'STOCK',
          status: 'ORDERED',
          paymentStatus: 'UNPAID',
          date: new Date('2025-10-20'),
          dueDate: new Date('2025-11-20'),
          note: 'Kumaş alımı - Test',
          subTotal: 100000, // 1,000 TL
          vatTot: 18000,    // 180 TL
          total: 118000,    // 1,180 TL
          paid: 0,
          items: {
            create: [
              {
                productId: 'prod-1',
                quantity: 10,
                qtyOrdered: 10,
                unitPrice: 10000,
                totalPrice: 100000
              }
            ]
          }
        }
      }),
      prisma.purchase.create({
        data: {
          id: 'purchase-2',
          supplierId: 'supplier-2',
          type: 'EXPENSE',
          status: 'RECEIVED',
          paymentStatus: 'PAID',
          date: new Date('2025-10-18'),
          dueDate: new Date('2025-10-25'),
          note: 'Elektrik faturası - Test',
          subTotal: 200000, // 2,000 TL
          vatTot: 36000,    // 360 TL
          total: 236000,    // 2,360 TL
          paid: 236000,
          items: {
            create: [
              {
                productId: 'prod-2',
                quantity: 1,
                qtyOrdered: 1,
                qtyReceived: 1,
                unitPrice: 200000,
                totalPrice: 200000
              }
            ]
          }
        }
      }),
      prisma.purchase.create({
        data: {
          id: 'purchase-3',
          supplierId: 'supplier-3',
          type: 'INVENTORY',
          status: 'PARTIAL_RECEIVED',
          paymentStatus: 'PARTIAL',
          date: new Date('2025-10-15'),
          dueDate: new Date('2025-11-15'),
          note: 'Dikiş makinesi yedek parçaları - Test',
          subTotal: 300000, // 3,000 TL
          vatTot: 54000,    // 540 TL
          total: 354000,    // 3,540 TL
          paid: 177000,     // 1,770 TL (yarısı ödenmiş)
          items: {
            create: [
              {
                productId: 'prod-3',
                quantity: 5,
                qtyOrdered: 5,
                qtyReceived: 3,
                unitPrice: 60000,
                totalPrice: 300000
              }
            ]
          }
        }
      }),
      prisma.purchase.create({
        data: {
          id: 'purchase-4',
          supplierId: 'supplier-1',
          type: 'STOCK',
          status: 'DRAFT',
          paymentStatus: 'UNPAID',
          date: new Date('2025-10-22'),
          note: 'Taslak sipariş - iplikler - Test',
          subTotal: 80000,  // 800 TL
          vatTot: 14400,    // 144 TL
          total: 94400,     // 944 TL
          paid: 0,
          items: {
            create: [
              {
                productId: 'prod-4',
                quantity: 20,
                qtyOrdered: 20,
                unitPrice: 4000,
                totalPrice: 80000
              }
            ]
          }
        }
      }),
      prisma.purchase.create({
        data: {
          id: 'purchase-5',
          supplierId: 'supplier-2',
          type: 'EXPENSE',
          status: 'CLOSED',
          paymentStatus: 'PAID',
          date: new Date('2025-10-10'),
          dueDate: new Date('2025-10-20'),
          note: 'Su faturası - Test',
          subTotal: 120000, // 1,200 TL
          vatTot: 21600,    // 216 TL
          total: 141600,    // 1,416 TL
          paid: 141600,
          items: {
            create: [
              {
                productId: 'prod-5',
                quantity: 1,
                qtyOrdered: 1,
                qtyReceived: 1,
                unitPrice: 120000,
                totalPrice: 120000
              }
            ]
          }
        }
      })
    ])

    console.log(`✅ Created ${purchases.length} test purchases`)
    console.log('🎉 Test purchase data added successfully!')
    
  } catch (error) {
    console.error('❌ Error adding test data:', error)
  }
}

main()
  .catch((e) => {
    console.error('❌ Error:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
