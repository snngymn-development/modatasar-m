const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Adding minimal purchase data...')

  try {
    // Clean existing purchases
    await prisma.purchaseItem.deleteMany()
    await prisma.purchase.deleteMany()

    // Create ONE simple purchase
    const purchase = await prisma.purchase.create({
      data: {
        id: 'purchase-test-1',
        supplierId: 'supplier-1',
        type: 'STOCK',
        status: 'ORDERED',
        paymentStatus: 'UNPAID',
        date: new Date('2025-10-20'),
        note: 'Test Purchase',
        subTotal: 100000,
        vatTot: 18000,
        total: 118000,
        paid: 0
      }
    })

    console.log(`✅ Created purchase: ${purchase.id}`)
    console.log('🎉 Minimal purchase data added successfully!')
    
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
