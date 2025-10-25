const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Starting simple purchase test...')

  // Clean existing data
  await prisma.purchaseItem.deleteMany()
  await prisma.purchase.deleteMany()
  await prisma.product.deleteMany()
  await prisma.supplier.deleteMany()

  console.log('🗑️  Cleaned existing data')

  // Create basic suppliers
  const suppliers = await Promise.all([
    prisma.supplier.create({
      data: {
        id: 'supplier-1',
        name: 'Test Supplier 1',
        email: 'supplier1@test.com',
        phone: '555-0001'
      }
    }),
    prisma.supplier.create({
      data: {
        id: 'supplier-2', 
        name: 'Test Supplier 2',
        email: 'supplier2@test.com',
        phone: '555-0002'
      }
    })
  ])

  console.log(`✅ Created ${suppliers.length} suppliers`)

  // Create basic products
  const products = await Promise.all([
    prisma.product.create({
      data: {
        id: 'prod-1',
        name: 'Test Product 1',
        price: 10000, // 100 TL
        stock: 50
      }
    }),
    prisma.product.create({
      data: {
        id: 'prod-2',
        name: 'Test Product 2', 
        price: 20000, // 200 TL
        stock: 30
      }
    })
  ])

  console.log(`✅ Created ${products.length} products`)

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
        dueDate: new Date('2025-11-20'),
        note: 'Test purchase 1',
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
        note: 'Test purchase 2',
        subTotal: 200000, // 2,000 TL
        vatTot: 36000,    // 360 TL
        total: 236000,    // 2,360 TL
        paid: 236000,
        items: {
          create: [
            {
              productId: 'prod-2',
              quantity: 10,
              qtyOrdered: 10,
              qtyReceived: 10,
              unitPrice: 20000,
              totalPrice: 200000
            }
          ]
        }
      }
    })
  ])

  console.log(`✅ Created ${purchases.length} purchases`)
  console.log('🎉 Simple purchase test completed!')
}

main()
  .catch((e) => {
    console.error('❌ Error:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
