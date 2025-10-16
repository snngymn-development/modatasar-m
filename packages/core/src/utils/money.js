export const fmtTRY = (n) => new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(n);
export const calcBalance = (price, collected) => Math.max(Number(price || 0) - Number(collected || 0), 0);
