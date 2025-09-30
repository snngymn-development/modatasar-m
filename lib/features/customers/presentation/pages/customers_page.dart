import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/features/customers/domain/entities/customer.dart';
import 'package:deneme1/features/customers/presentation/widgets/customer_card.dart';
import 'package:deneme1/features/customers/presentation/widgets/customer_search_bar.dart';
import 'package:deneme1/features/customers/presentation/providers/customer_providers.dart';

/// Customers management page
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => const CustomersPage(),
/// ));
/// ```
class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteriler'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showActiveOnly = !_showActiveOnly;
              });
              ref.invalidate(customersProvider);
            },
            icon: Icon(
              _showActiveOnly ? Icons.visibility : Icons.visibility_off,
            ),
            tooltip: _showActiveOnly
                ? 'Tümünü Göster'
                : 'Sadece Aktifleri Göster',
          ),
          IconButton(
            onPressed: () {
              _showAddCustomerDialog(context);
            },
            icon: const Icon(Icons.person_add),
            tooltip: 'Yeni Müşteri Ekle',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomerSearchBar(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          // Customers list
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                // Filter customers based on search query and active status
                final filteredCustomers = customers.where((customer) {
                  final matchesSearch =
                      _searchQuery.isEmpty ||
                      customer.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      customer.email.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );

                  final matchesActiveFilter =
                      !_showActiveOnly || customer.isActive;

                  return matchesSearch && matchesActiveFilter;
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Arama sonucu bulunamadı'
                              : 'Müşteri bulunamadı',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? '"$_searchQuery" için sonuç bulunamadı'
                              : 'Henüz müşteri eklenmemiş',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return CustomerCard(
                      customer: customer,
                      onTap: () => _showCustomerDetails(context, customer),
                      onEdit: () => _showEditCustomerDialog(context, customer),
                      onDelete: () =>
                          _showDeleteCustomerDialog(context, customer),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Müşteriler yüklenirken hata oluştu',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(customersProvider);
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCustomerDialog(),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => EditCustomerDialog(customer: customer),
    );
  }

  void _showDeleteCustomerDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: Text(
          '${customer.name} müşterisini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(deleteCustomerProvider(customer.id).future);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${customer.name} silindi'),
                  action: SnackBarAction(
                    label: 'Geri Al',
                    onPressed: () {
                      ref.read(createCustomerProvider(customer).future);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('E-posta', customer.email),
              if (customer.phone != null)
                _buildDetailRow('Telefon', customer.phone!),
              if (customer.fullAddress.isNotEmpty)
                _buildDetailRow('Adres', customer.fullAddress),
              _buildDetailRow('Durum', customer.isActive ? 'Aktif' : 'Pasif'),
              _buildDetailRow('Kayıt Tarihi', _formatDate(customer.createdAt)),
              if (customer.notes != null && customer.notes!.isNotEmpty)
                _buildDetailRow('Notlar', customer.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditCustomerDialog(context, customer);
            },
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Add customer dialog
class AddCustomerDialog extends ConsumerStatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Müşteri Ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad soyad gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-posta gereklidir';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Şehir',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final customer = Customer(
                id: '', // Will be generated by repository
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim().isNotEmpty
                    ? _phoneController.text.trim()
                    : null,
                address: _addressController.text.trim().isNotEmpty
                    ? _addressController.text.trim()
                    : null,
                city: _cityController.text.trim().isNotEmpty
                    ? _cityController.text.trim()
                    : null,
                notes: _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
                createdAt: DateTime.now(),
              );

              try {
                await ref.read(createCustomerProvider(customer).future);
                if (mounted) {
                  final navigator = Navigator.of(this.context);
                  final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Müşteri başarıyla eklendi')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

/// Edit customer dialog
class EditCustomerDialog extends ConsumerStatefulWidget {
  final Customer customer;

  const EditCustomerDialog({super.key, required this.customer});

  @override
  ConsumerState<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends ConsumerState<EditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _notesController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _emailController = TextEditingController(text: widget.customer.email);
    _phoneController = TextEditingController(text: widget.customer.phone ?? '');
    _addressController = TextEditingController(
      text: widget.customer.address ?? '',
    );
    _cityController = TextEditingController(text: widget.customer.city ?? '');
    _notesController = TextEditingController(text: widget.customer.notes ?? '');
    _isActive = widget.customer.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Müşteriyi Düzenle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad soyad gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-posta gereklidir';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Şehir',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final updatedCustomer = widget.customer.copyWith(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim().isNotEmpty
                    ? _phoneController.text.trim()
                    : null,
                address: _addressController.text.trim().isNotEmpty
                    ? _addressController.text.trim()
                    : null,
                city: _cityController.text.trim().isNotEmpty
                    ? _cityController.text.trim()
                    : null,
                notes: _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
                isActive: _isActive,
                updatedAt: DateTime.now(),
              );

              try {
                await ref.read(updateCustomerProvider(updatedCustomer).future);
                if (mounted) {
                  final navigator = Navigator.of(this.context);
                  final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Müşteri başarıyla güncellendi'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Güncelle'),
        ),
      ],
    );
  }
}
