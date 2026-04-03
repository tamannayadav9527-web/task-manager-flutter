enum Status { todo, inProgress, done }

///  ENUM FOR RECURRING
enum RecurringType { none, daily, weekly }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  Status status;
  String? blockedByTaskId;

  ///  RECURRING FIELD
  RecurringType recurringType;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedByTaskId,
    this.recurringType = RecurringType.none,
  });

  ///  TASK → JSON (SAVE)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status.index,
      'blockedByTaskId': blockedByTaskId,
      'recurringType': recurringType.index,
    };
  }

  ///  JSON → TASK (LOAD)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),

      ///  SAFE STATUS PARSING
      status: (json['status'] != null &&
              json['status'] < Status.values.length)
          ? Status.values[json['status']]
          : Status.todo,

      blockedByTaskId: json['blockedByTaskId'],

      /// SAFE RECURRING PARSING
      recurringType: (json['recurringType'] != null &&
              json['recurringType'] < RecurringType.values.length)
          ? RecurringType.values[json['recurringType']]
          : RecurringType.none,
    );
  }

  ///  COPY WITH (VERY IMPORTANT FOR CLEAN CODE)
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Status? status,
    String? blockedByTaskId,
    RecurringType? recurringType,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedByTaskId: blockedByTaskId ?? this.blockedByTaskId,
      recurringType: recurringType ?? this.recurringType,
    );
  }
}
