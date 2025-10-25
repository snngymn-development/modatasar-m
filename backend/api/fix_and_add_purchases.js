const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Fixing and adding purchase data...')

  try {
    // Clean everything
    await prisma.purchaseItem.deleteMany()
    await prisma.purchase.deleteMany()
    await prisma.supplier.deleteMany()

    // Create suppliers first
    const suppliers = await prisma.supplier.createMany({
      data: [
        { id: 'supplier-1', name: 'Test Supplier 1', email: 'supplier1@test.com', phone: '555-0001' },
        { id: 'supplier-2', name: 'Test Supplier 2', email: 'supplier2@test.com', phone: '555-0002' },
        { id: 'supplier-3', name: 'Test Supplier 3', email: 'supplier3@test.com', phone: '555-0003' }
      ]
    })

    console.log(`✅ Created suppliers`)

    // Create purchases
    const purchases = await Promise.all([
      prisma.purchase.create({
        data: {
          id: 'purchase-1',
          supplierId: 'supplier-1',
          type: 'STOCK',
          status: 'ORDERED',
          paymentStatus: 'UNPAID',
          date: new Date('2025-10-20'),
          note: 'Kumaş alımı',
          subTotal: 100000,
          vatTot: 18000,
          total: 118000,
          paid: 0
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
          note: 'Elektrik faturası',
          subTotal: 200000,
          vatTot: 36000,
          total: 236000,
          paid: 236000
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
          note: 'Dikiş makinesi yedek parçaları',
          subTotal: 300000,
          vatTot: 54000,
          total: 354000,
          paid: 177000
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
          note: 'Taslak sipariş - iplikler',
          subTotal: 80000,
          vatTot: 14400,
          total: 94400,
          paid: 0
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
          note: 'Su faturası',
          subTotal: 120000,
          vatTot: 21600,
          total: 141600,
          paid: 141600
        }
      })
    ])

    console.log(`✅ Created ${purchases.length} purchases`)
    console.log('🎉 Purchase data added successfully!')
    
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
