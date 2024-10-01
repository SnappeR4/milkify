import 'package:flutter/material.dart';
import 'package:milkify/App/user_interface/themes/app_theme.dart';

class MemberWidgets {
  // Empty List Message
  static Widget buildEmptyListMessage() {
    return Center(
      child: Text(
        'No members found',
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
    );
  }

  // Member List Item
  static Widget buildMemberItem({
    required BuildContext context,
    required Map<String, dynamic> member,
    required Function() onTap,
    required Function() onDelete,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Member information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Name and ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          member['name'], // Name of the member
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'ID: ${member['m_id']}', // Member ID
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Mobile number
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.grey),
                        const SizedBox(width: 8.0),
                        Text(
                          member['mobile_number'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Balance
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 18, color: Colors.green),
                        const SizedBox(width: 8.0),
                        Text(
                          'Balance: ₹${member['c_balance'].toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Milk Type and Liters
                    Row(
                      children: [
                        const Icon(Icons.local_drink, size: 18, color: Colors.brown),
                        const SizedBox(width: 8.0),
                        Text(
                          '${member['milk_type']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16.0),
                        const Icon(Icons.opacity, size: 18, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Text(
                          '${member['liters'].toStringAsFixed(2)} Liters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Delete Member',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
