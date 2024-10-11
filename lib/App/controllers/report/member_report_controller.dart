import 'package:get/get.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MemberReportController extends GetxController {
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredMembers = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> selectedMember = <String, dynamic>{}.obs;
  var isMemberSelected = false.obs;
  final RxString searchQuery = ''.obs;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Database database;
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _dbHelper.database;
    fetchMembers();
  }
  void selectMember(Map<String, dynamic> member) {
    selectedMember.assignAll(member);
    isMemberSelected.value = true;
  }
  Future<void> setMemberSelected(bool selected) async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    filteredMembers.assignAll(memberList);
    isMemberSelected.value = selected;
  }
  Future<void> fetchMembers() async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    members.assignAll(memberList);
    searchMembers(searchQuery.value); // Apply the search if any
  }
  Future<void> syncMembers() async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    filteredMembers.assignAll(memberList);
  }
  void searchMembers(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      // If search query is empty, reset the filtered members list
      filteredMembers.assignAll(members);
    } else {
      filteredMembers.assignAll(
        members.where((member) {
          final name = member['name'].toLowerCase();
          final id = member['m_id'].toString();  // Assuming 'm_id' is an integer or string
          final mobileNumber = member['mobile_number'].toString();

          // Check if the query matches either name, id, or mobile number
          return name.contains(query.toLowerCase()) ||
              id.contains(query) ||
              mobileNumber.contains(query);
        }).toList(),
      );
    }
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    filteredMembers.assignAll(members);
  }

  // Delete a member from the database
  Future<void> deleteMember(int memberId) async {
    await database.delete(
      'members',
      where: 'm_id = ?',
      whereArgs: [memberId],
    );
    fetchMembers(); // Refresh the list after deletion
  }

  Future<Object> getTotalPaidAmount(int memberId) async {
    var result = await database.rawQuery(
        'SELECT SUM(paid_amount) as totalPaidAmount FROM member_payment WHERE m_id = ?', [memberId]);

    if (result.isNotEmpty) {
      return result.first['totalPaidAmount'] ?? 0.0;
    }
    return 0.0;
  }

  // Mock function for Total Bill Amount
  Future<Object> getTotalBillAmount(int memberId) async {
    var result = await database.rawQuery(
        'SELECT SUM(total) as totalBillAmount FROM transactions WHERE m_id = ?', [memberId]);

    if (result.isNotEmpty) {
      return result.first['totalBillAmount'] ?? 0.0;
    }
    return 0.0;
  }
}
