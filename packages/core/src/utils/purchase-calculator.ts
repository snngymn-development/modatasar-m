/**
 * Purchase Calculation System
 * Handles complex financial calculations for purchase orders
 */

export interface PurchaseItem {
  id: string
  qtyOrdered: number
  qtyReceived: number
  unitPrice: number // cents
  lineDiscountTot: number // cents
  lineChargeTot: number // cents
  lineSubTotal: number // cents
  lineVat: number // cents
  lineTotal: number // cents
}

export interface HeaderCharge {
  id: string
  title: string
  amount: number // cents
  allocate: 'PROPORTIONAL' | 'BY_QTY' | 'BY_VALUE' | 'NONE'
}

export interface HeaderDiscount {
  id: string
  title: string
  amount: number // cents
  kind: 'ABS' | 'PCT'
}

export interface PurchaseCalculationInput {
  items: PurchaseItem[]
  headerCharges: HeaderCharge[]
  headerDiscounts: HeaderDiscount[]
  vatRate: number // 0.20 = 20%
}

export interface PurchaseCalculationResult {
  // Line calculations
  lineCalculations: Array<{
    itemId: string
    lineBase: number
    lineAfterDiscounts: number
    lineAfterCharges: number
    lineVat: number
    lineTotal: number
    allocatedHeaderCharges: number
    allocatedHeaderDiscounts: number
  }>
  
  // Header totals
  subTotal: number
  discountTot: number
  chargeTot: number
  vatTot: number
  roundingAdj: number
  total: number
}

/**
 * Calculate purchase totals with complex business rules
 */
export function calculatePurchaseTotals(input: PurchaseCalculationInput): PurchaseCalculationResult {
  const { items, headerCharges, headerDiscounts, vatRate } = input
  
  // 1. Calculate line-level totals
  const lineCalculations = items.map(item => {
    // Line base calculation
    const lineBase = item.qtyOrdered * item.unitPrice
    
    // Apply line discounts
    const lineAfterDiscounts = Math.max(0, lineBase - item.lineDiscountTot)
    
    // Apply line charges
    const lineAfterCharges = lineAfterDiscounts + item.lineChargeTot
    
    return {
      itemId: item.id,
      lineBase,
      lineAfterDiscounts,
      lineAfterCharges,
      lineVat: 0, // Will be calculated after header allocation
      lineTotal: 0, // Will be calculated after header allocation
      allocatedHeaderCharges: 0, // Will be calculated
      allocatedHeaderDiscounts: 0 // Will be calculated
    }
  })
  
  // 2. Calculate subtotal (sum of line totals)
  const subTotal = lineCalculations.reduce((sum, line) => sum + line.lineAfterCharges, 0)
  
  // 3. Allocate header charges and discounts
  const totalHeaderCharges = headerCharges.reduce((sum, charge) => sum + charge.amount, 0)
  const totalHeaderDiscounts = headerDiscounts.reduce((sum, discount) => sum + discount.amount, 0)
  
  // Allocate header charges
  lineCalculations.forEach((line, index) => {
    const item = items[index]
    const chargeAllocation = allocateHeaderAmount(
      totalHeaderCharges,
      headerCharges,
      line.lineAfterCharges,
      subTotal,
      item.qtyOrdered,
      items.reduce((sum, item) => sum + item.qtyOrdered, 0)
    )
    line.allocatedHeaderCharges = chargeAllocation
  })
  
  // Allocate header discounts
  lineCalculations.forEach((line, index) => {
    const item = items[index]
    const discountAllocation = allocateHeaderAmount(
      totalHeaderDiscounts,
      headerDiscounts,
      line.lineAfterCharges,
      subTotal,
      item.qtyOrdered,
      items.reduce((sum, item) => sum + item.qtyOrdered, 0)
    )
    line.allocatedHeaderDiscounts = discountAllocation
  })
  
  // 4. Calculate final line totals
  lineCalculations.forEach(line => {
    const lineSubTotal = line.lineAfterCharges + line.allocatedHeaderCharges - line.allocatedHeaderDiscounts
    line.lineVat = Math.round(lineSubTotal * vatRate)
    line.lineTotal = lineSubTotal + line.lineVat
  })
  
  // 5. Calculate header totals
  const finalSubTotal = lineCalculations.reduce((sum, line) => sum + (line.lineAfterCharges + line.allocatedHeaderCharges - line.allocatedHeaderDiscounts), 0)
  const vatTot = lineCalculations.reduce((sum, line) => sum + line.lineVat, 0)
  const total = finalSubTotal + vatTot
  
  // 6. Calculate rounding adjustment (±1 cent)
  const roundingAdj = Math.round(total) - total
  
  return {
    lineCalculations,
    subTotal: Math.round(finalSubTotal),
    discountTot: totalHeaderDiscounts,
    chargeTot: totalHeaderCharges,
    vatTot: Math.round(vatTot),
    roundingAdj,
    total: Math.round(total)
  }
}

/**
 * Allocate header charges/discounts to lines based on allocation method
 */
function allocateHeaderAmount(
  totalAmount: number,
  items: (HeaderCharge | HeaderDiscount)[],
  lineValue: number,
  totalValue: number,
  lineQty: number,
  totalQty: number
): number {
  if (totalAmount === 0) return 0
  
  // Use the first item's allocation method (assuming all items use same method)
  const allocationMethod = (items[0] as HeaderCharge)?.allocate || 'PROPORTIONAL'
  
  switch (allocationMethod) {
    case 'PROPORTIONAL':
      return Math.round((lineValue / totalValue) * totalAmount)
    
    case 'BY_QTY':
      return Math.round((lineQty / totalQty) * totalAmount)
    
    case 'BY_VALUE':
      return Math.round((lineValue / totalValue) * totalAmount)
    
    case 'NONE':
    default:
      return 0
  }
}

/**
 * Validate purchase calculation input
 */
export function validatePurchaseInput(input: PurchaseCalculationInput): string[] {
  const errors: string[] = []
  
  if (!input.items || input.items.length === 0) {
    errors.push('At least one item is required')
  }
  
  input.items.forEach((item, index) => {
    if (item.qtyOrdered <= 0) {
      errors.push(`Item ${index + 1}: Quantity must be positive`)
    }
    if (item.unitPrice < 0) {
      errors.push(`Item ${index + 1}: Unit price cannot be negative`)
    }
    if (item.lineDiscountTot < 0) {
      errors.push(`Item ${index + 1}: Line discount cannot be negative`)
    }
    if (item.lineChargeTot < 0) {
      errors.push(`Item ${index + 1}: Line charge cannot be negative`)
    }
  })
  
  if (input.vatRate < 0 || input.vatRate > 1) {
    errors.push('VAT rate must be between 0 and 1')
  }
  
  input.headerCharges.forEach((charge, index) => {
    if (charge.amount < 0) {
      errors.push(`Header charge ${index + 1}: Amount cannot be negative`)
    }
  })
  
  input.headerDiscounts.forEach((discount, index) => {
    if (discount.amount < 0) {
      errors.push(`Header discount ${index + 1}: Amount cannot be negative`)
    }
  })
  
  return errors
}

/**
 * Format currency for display
 */
export function formatCurrency(cents: number, currency: string = 'TRY'): string {
  return new Intl.NumberFormat('tr-TR', {
    style: 'currency',
    currency,
    maximumFractionDigits: 0
  }).format(cents / 100)
}

/**
 * Calculate percentage discount amount
 */
export function calculatePercentageDiscount(baseAmount: number, percentage: number): number {
  return Math.round(baseAmount * (percentage / 100))
}
