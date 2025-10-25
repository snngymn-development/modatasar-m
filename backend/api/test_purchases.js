const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()

async function testPurchases() {
  try {
    console.log('Testing purchases query...')
    
    const purchases = await prisma.purchase.findMany()
    
    console.log('Found purchases:', purchases.length)
    console.log('First purchase:', JSON.stringify(purchases[0], null, 2))
    
  } catch (error) {
    console.error('Error:', error)
  } finally {
    await prisma.$disconnect()
  }
}

testPurchases()
