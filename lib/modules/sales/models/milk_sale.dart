class MilkSale {
  final String localId;
  final String? serverId;
  final int isSynced;
  final String saleDate;
  final double litres;
  final double pricePerLitre;
  final String? buyerName;
  final String? notes;
  final String createdAt;

  const MilkSale({
    required this.localId,
    this.serverId,
    this.isSynced = 0,
    required this.saleDate,
    required this.litres,
    required this.pricePerLitre,
    this.buyerName,
    this.notes,
    required this.createdAt,
  });

  double get totalAmount => litres * pricePerLitre;

  factory MilkSale.fromMap(Map<String, dynamic> map) => MilkSale(
        localId: map['local_id'],
        serverId: map['server_id'],
        isSynced: map['is_synced'] ?? 0,
        saleDate: map['sale_date'],
        litres: (map['litres'] as num).toDouble(),
        pricePerLitre: (map['price_per_litre'] as num).toDouble(),
        buyerName: map['buyer_name'],
        notes: map['notes'],
        createdAt: map['created_at'],
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'server_id': serverId,
        'is_synced': isSynced,
        'sale_date': saleDate,
        'litres': litres,
        'price_per_litre': pricePerLitre,
        'buyer_name': buyerName,
        'notes': notes,
        'created_at': createdAt,
      };
}
