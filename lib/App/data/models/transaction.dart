class Transactions {
  final int id;
  final String receiptNo;
  final String billType;
  final int memberId;
  final int productId;
  final double productRate;
  final double liters;
  final double addOn;
  final double total;
  final String date;
  final String time;
  final String timestamp;
  final String editedTimestamp;
  final String paymentMode;
  final int paymentReceivedFlag;
  final double memberOpeningBalance;
  final int voidBillFlag;

  Transactions({
    required this.id,
    required this.receiptNo,
    required this.billType,
    required this.memberId,
    required this.productId,
    required this.productRate,
    required this.liters,
    required this.addOn,
    required this.total,
    required this.date,
    required this.time,
    required this.timestamp,
    required this.editedTimestamp,
    required this.paymentMode,
    required this.paymentReceivedFlag,
    required this.memberOpeningBalance,
    required this.voidBillFlag,
  });

  // Convert a Transaction object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'tr_id': id,
      'receipt_no': receiptNo,
      'bill_type': billType,
      'm_id': memberId,
      'p_id': productId,
      'p_rate': productRate,
      'liters': liters,
      'addOn': addOn,
      'total': total,
      'date': date,
      'time': time,
      'timestamp': timestamp,
      'edited_timestamp': editedTimestamp,
      'payment_mode': paymentMode,
      'payment_received_flag': paymentReceivedFlag,
      'm_opening_balance': memberOpeningBalance,
      'void_bill_flag': voidBillFlag,
    };
  }

  // Extract a Transaction object from a Map object
  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['tr_id'],
      receiptNo: map['receipt_no'],
      billType: map['bill_type'],
      memberId: map['m_id'],
      productId: map['p_id'],
      productRate: map['p_rate'],
      liters: map['liters'],
      addOn: map['addOn'],
      total: map['total'],
      date: map['date'],
      time: map['time'],
      timestamp: map['timestamp'],
      editedTimestamp: map['edited_timestamp'],
      paymentMode: map['payment_mode'],
      paymentReceivedFlag: map['payment_received_flag'],
      memberOpeningBalance: map['m_opening_balance'],
      voidBillFlag: map['void_bill_flag'],
    );
  }
}
