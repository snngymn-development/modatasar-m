/**
 * Format amount in cents to Turkish Lira
 * @param cents - Amount in cents (e.g., 10000 = ₺100)
 * @returns Formatted string (e.g., "₺100")
 */
export const fmtTRY = (cents: number) =>
  new Intl.NumberFormat('tr-TR', { style:'currency', currency:'TRY', maximumFractionDigits:0 }).format(cents / 100)

/**
 * Calculate remaining balance
 * @param totalCents - Total price in cents
 * @param collectedCents - Amount collected in cents
 * @returns Balance in cents
 */
export const calcBalance = (totalCents: number, collectedCents: number) =>
  Math.max(Number(totalCents||0) - Number(collectedCents||0), 0)

