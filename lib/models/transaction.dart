enum TransactionStatus {
  pending,
  accepted,
  declined,
}

class TransactionModel {
  String id;
  String fromUserId;
  String toUserId;
  double amount;
  TransactionStatus status;

  TransactionModel({
    this.id = '',
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'status': status.name,
    };
  }

  factory TransactionModel.fromJson(String id, Map<String, dynamic> json) {
    return TransactionModel(
      id: id,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: TransactionStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
    );
  }
}
