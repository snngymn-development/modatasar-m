enum CustomerStatus { active, passive, banned }

extension CustomerStatusX on CustomerStatus {
  String get label => switch (this) {
    CustomerStatus.active => 'Aktif',
    CustomerStatus.passive => 'Pasif',
    CustomerStatus.banned => 'Yasaklı',
  };
}
