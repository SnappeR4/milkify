class MemberPayment {
  final int billNo;
  final int memberId;
  final double paidAmount;
  final double currentBalance;
  final String date;
  final String time;

  MemberPayment({
    required this.billNo,
    required this.memberId,
    required this.paidAmount,
    required this.currentBalance,
    required this.date,
    required this.time,
  });

  // Convert MemberPayment instance to a Map for saving into the database
  Map<String, dynamic> toMap() {
    return {
      'bill_no': billNo,
      'm_id': memberId,
      'paid_amount': paidAmount,
      'current_balance': currentBalance,
      'date': date,
      'time': time,
    };
  }

  // Create a MemberPayment instance from a Map (used when retrieving data from the DB)
  factory MemberPayment.fromMap(Map<String, dynamic> map) {
    return MemberPayment(
      billNo: map['bill_no'],
      memberId: map['m_id'],
      paidAmount: map['paid_amount'],
      currentBalance: map['current_balance'],
      date: map['date'],
      time: map['time'],
    );
  }
}
