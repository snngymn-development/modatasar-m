import { z } from 'zod'

// Order Detail Schemas
export const OrderChargeSchema = z.object({
  id: z.string().optional(),
  orderDetailId: z.string().optional(),
  label: z.string().min(1, 'Masraf etiketi gerekli'),
  amount: z.number().int().min(0, 'Masraf tutarı pozitif olmalı'),
  description: z.string().optional(),
  createdAt: z.string().optional(),
})

export const OrderDiscountSchema = z.object({
  id: z.string().optional(),
  orderDetailId: z.string().optional(),
  label: z.string().min(1, 'İndirim etiketi gerekli'),
  amount: z.number().int().min(0, 'İndirim tutarı pozitif olmalı'),
  description: z.string().optional(),
  createdAt: z.string().optional(),
})

export const OrderDetailSchema = z.object({
  id: z.string().optional(),
  orderId: z.string().optional(),
  description: z.string().optional(),
  amount: z.number().int().min(0, 'Tutar pozitif olmalı'),
  charges: z.array(OrderChargeSchema).default([]),
  discounts: z.array(OrderDiscountSchema).default([]),
  importantNote: z.string().optional(),
  totalAmount: z.number().int().min(0).optional(),
  createdAt: z.string().optional(),
  updatedAt: z.string().optional(),
})

export const OrderFittingSchema = z.object({
  id: z.string().optional(),
  orderId: z.string().optional(),
  fittingNumber: z.number().int().min(1, 'Prova numarası 1\'den büyük olmalı'),
  fittingDate: z.string().min(1, 'Prova tarihi gerekli'),
  notes: z.string().optional(),
  status: z.enum(['SCHEDULED', 'COMPLETED', 'CANCELLED']).default('SCHEDULED'),
  createdAt: z.string().optional(),
})

export const OrderStatusSchema = z.object({
  id: z.string().optional(),
  orderId: z.string().optional(),
  status: z.enum(['STARTED', 'PROGRESS_50', 'PROGRESS_80', 'READY', 'DELIVERED']),
  percentage: z.number().int().min(0).max(100, 'Yüzde 0-100 arasında olmalı'),
  notes: z.string().optional(),
  createdAt: z.string().optional(),
  updatedAt: z.string().optional(),
})

// Customer Body Measurements Schema
export const CustomerBodyMeasurementsSchema = z.object({
  id: z.string().optional(),
  customerId: z.string().min(1, 'Müşteri ID gerekli'),
  chest: z.number().min(0, 'Göğüs ölçüsü pozitif olmalı'),
  waist: z.number().min(0, 'Bel ölçüsü pozitif olmalı'),
  hip: z.number().min(0, 'Kalça ölçüsü pozitif olmalı'),
  shoulder: z.number().min(0, 'Omuz ölçüsü pozitif olmalı'),
  armLength: z.number().min(0, 'Kol uzunluğu pozitif olmalı'),
  legLength: z.number().min(0, 'Bacak uzunluğu pozitif olmalı'),
  neck: z.number().min(0, 'Boyun ölçüsü pozitif olmalı'),
  notes: z.string().optional(),
  measuredAt: z.string().min(1, 'Ölçüm tarihi gerekli'),
  createdAt: z.string().optional(),
})

// Main Order Creation Schema
export const CreateOrderSchema = z.object({
  type: z.literal('TAILORING'), // Fixed to TAILORING for this module
  customerId: z.string().min(1, 'Müşteri seçimi gerekli'),
  organization: z.string().optional(),
  deliveryDate: z.string().min(1, 'Teslim tarihi gerekli'),
  description: z.string().optional(),
  amount: z.number().int().min(0, 'Tutar pozitif olmalı'),
  importantNote: z.string().optional(),
  charges: z.array(OrderChargeSchema).default([]),
  discounts: z.array(OrderDiscountSchema).default([]),
  fittings: z.array(OrderFittingSchema).default([]),
})

// Order Update Schema
export const UpdateOrderSchema = CreateOrderSchema.partial().extend({
  id: z.string().min(1, 'Sipariş ID gerekli'),
})

// Add Fitting Schema
export const AddFittingSchema = z.object({
  orderId: z.string().min(1, 'Sipariş ID gerekli'),
  fittingNumber: z.number().int().min(1),
  fittingDate: z.string().min(1, 'Prova tarihi gerekli'),
  notes: z.string().optional(),
})

// Update Order Status Schema
export const UpdateOrderStatusSchema = z.object({
  orderId: z.string().min(1, 'Sipariş ID gerekli'),
  status: z.enum(['STARTED', 'PROGRESS_50', 'PROGRESS_80', 'READY', 'DELIVERED']),
  notes: z.string().optional(),
})

// Add Charge Schema
export const AddChargeSchema = z.object({
  orderDetailId: z.string().min(1, 'Sipariş detay ID gerekli'),
  label: z.string().min(1, 'Masraf etiketi gerekli'),
  amount: z.number().int().min(0, 'Masraf tutarı pozitif olmalı'),
  description: z.string().optional(),
})

// Add Discount Schema
export const AddDiscountSchema = z.object({
  orderDetailId: z.string().min(1, 'Sipariş detay ID gerekli'),
  label: z.string().min(1, 'İndirim etiketi gerekli'),
  amount: z.number().int().min(0, 'İndirim tutarı pozitif olmalı'),
  description: z.string().optional(),
})