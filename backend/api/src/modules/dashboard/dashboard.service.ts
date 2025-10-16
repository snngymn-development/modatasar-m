import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getCards() {
    // Get counts from database
    const [
      pendingOrders,
      rentalReturns,
      totalCustomers,
      totalStaff
    ] = await Promise.all([
      this.prisma.order.count({ where: { status: 'ACTIVE' } }), // ✅ paymentStatus kaldırıldı
      this.prisma.rental.count(), // ✅ status kaldırıldı (Rental'da yok artık)
      this.prisma.customer.count(),
      Promise.resolve(11) // Mock staff count
    ])

    return {
      row1: [
        { emoji: '📦', title: 'Teslim Edilmeyen Sipariş', value: pendingOrders.toString(), color: 'bg-rose-100', href: '/orders/pending' },
        { emoji: '🔁', title: 'Kiradan Dönecek (3 Ay)', value: rentalReturns.toString(), color: 'bg-amber-200', href: '/rental/returns-3mo' },
        { emoji: '📅', title: 'Yaklaşan Randevu', value: '0', color: 'bg-blue-100', href: '/appointments/upcoming' },
        { emoji: '👗', title: 'Yaklaşan Prova', value: '0', color: 'bg-pink-200', href: '/fittings/upcoming' },
      ],
      row2: [
        { emoji: '💰', title: 'Bugünkü Satış • Kiralama', value: '–', color: 'bg-green-200', href: '/sales/today' },
        { emoji: '🗓️', title: 'Bugün Randevu', value: '0', color: 'bg-blue-100', href: '/appointments/today' },
        { emoji: '⚠️', title: 'Stok Uyarısı', value: '0', color: 'bg-rose-100', href: '/stock/alerts' },
        { emoji: '👥', title: 'Toplam Personel', value: totalStaff.toString(), color: 'bg-slate-200', href: '/hr/staff' },
      ],
      short: [
        { emoji: '🎉', title: 'Yaklaşan Özel Gün', value: '0', color: 'bg-fuchsia-100', href: '/calendar/special-days?when=upcoming' },
        { emoji: '🎈', title: 'Bugün Özel Gün', value: '0', color: 'bg-rose-100', href: '/calendar/special-days?when=today' },
        { emoji: '✅', title: 'ToDo', value: '0', color: 'bg-emerald-100', href: '/tasks/todo' },
        { emoji: '🚚', title: 'Tedarik (Geciken)', value: '0', color: 'bg-amber-100', href: '/procurement/delayed' },
      ],
    }
  }

  async getDashboard() {
    const [customers, orders, rentals] = await Promise.all([
      this.prisma.customer.count(),
      this.prisma.order.count(),
      this.prisma.rental.count(),
    ])

    // Calculate total revenue from orders
    const ordersData = await this.prisma.order.findMany({ select: { total: true, collected: true } })
    const totalRevenue = ordersData.reduce((sum, order) => sum + order.collected, 0)

    return {
      stats: {
        totalSales: totalRevenue,
        totalOrders: orders,
        totalCustomers: customers,
        totalProducts: 0, // TODO: Add products table
        revenue: totalRevenue,
        profit: Math.floor(totalRevenue * 0.3), // 30% profit margin estimate
        growthRate: 12.5
      },
      recentOrders: [],
      topProducts: [],
      salesChart: [],
      lastUpdated: new Date().toISOString()
    }
  }
}

