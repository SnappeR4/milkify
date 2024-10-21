class Member {
  final int id;
  final String name;
  final String address;
  final String mobileNumber;
  final double recentlyPaid;
  final double currentBalance;
  final String milkType;
  final double liters;
  final String qr_code;

  Member({
    required this.id,
    required this.name,
    required this.address,
    required this.mobileNumber,
    required this.recentlyPaid,
    required this.currentBalance,
    required this.milkType,
    required this.liters,
    required this.qr_code,
  });

  // Convert a Member object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'm_id': id,
      'name': name,
      'address': address,
      'mobile_number': mobileNumber,
      'recently_paid': recentlyPaid,
      'c_balance': currentBalance,
      'milk_type': milkType,
      'liters': liters,
    };
  }

  // Extract a Member object from a Map object
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['m_id'],
      name: map['name'],
      address: map['address'],
      mobileNumber: map['mobile_number'],
      recentlyPaid: map['recently_paid'],
      currentBalance: map['c_balance'],
      milkType: map['milk_type'],
      liters: map['liters'],
      qr_code: map['qr_code'],
    );
  }
}
