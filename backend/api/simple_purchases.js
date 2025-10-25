const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Adding simple purchase data...')

  try {
    // Clean existing purchases
    await prisma.purchaseItem.deleteMany()
    await prisma.purchase.deleteMany()

    // Create test purchases WITHOUT productId
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
          subTotal: 100000,
          vatTot: 18000,
          total: 118000,
          paid: 0,
          items: {
            create: [
              {
                description: 'Test Product 1',
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
          subTotal: 200000,
          vatTot: 36000,
          total: 236000,
          paid: 236000,
          items: {
            create: [
              {
                description: 'Test Product 2',
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
          subTotal: 300000,
          vatTot: 54000,
          total: 354000,
          paid: 177000,
          items: {
            create: [
              {
                description: 'Test Product 3',
                quantity: 5,
                qtyOrdered: 5,
                qtyReceived: 3,
                unitPrice: 60000,
                totalPrice: 300000
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
