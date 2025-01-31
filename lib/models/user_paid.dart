import 'package:podeli_smetka/models/user_model.dart';

class UserPaid {
  final AppUser user;
  final double amount;

  UserPaid({
    required this.user,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'amount': amount,
    };
  }

  factory UserPaid.fromJson(Map<String, dynamic> json) {
    return UserPaid(
      user: AppUser.fromJson(json['user']),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
