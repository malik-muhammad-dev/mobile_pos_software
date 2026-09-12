enum StaffRole { owner, cashier }

StaffRole staffRoleFromDb(String value) {
  return value == 'owner' ? StaffRole.owner : StaffRole.cashier;
}

String staffRoleToDb(StaffRole role) => role == StaffRole.owner ? 'owner' : 'cashier';

class Staff {
  final int id;
  final String name;
  final StaffRole role;
  final bool active;

  const Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.active,
  });

  factory Staff.fromRow(Map<String, Object?> row) {
    return Staff(
      id: row['id'] as int,
      name: row['name'] as String,
      role: staffRoleFromDb(row['role'] as String),
      active: (row['active'] as int) == 1,
    );
  }
}