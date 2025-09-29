class Sale {
  final String id;
  final String title;
  final double total;

  const Sale({required this.id, required this.title, required this.total});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale &&
        other.id == id &&
        other.title == title &&
        other.total == total;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ total.hashCode;

  @override
  String toString() {
    return 'Sale(id: $id, title: $title, total: $total)';
  }
}
