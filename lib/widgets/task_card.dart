import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/screens/add_edit_task_screen.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

// Improved task UI logic
class TaskCard extends StatelessWidget {
  final Task task;
  final bool isBlocked;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
  });

  /// 🟢🔵 STATUS LABEL
  Widget buildStatusLabel(bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isDone ? "Completed" : "Upcoming",
        style: TextStyle(
          color: isDone ? Colors.green : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 🔍 HIGHLIGHT FUNCTION (UNCHANGED)
  Widget buildHighlightedText(
      String text, String query, bool isDone, bool isBlocked) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isBlocked ? Colors.grey : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);

    if (start == -1) {
      return Text(
        text,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isBlocked ? Colors.grey : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final end = start + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, start),
            style: TextStyle(
              color: isBlocked ? Colors.grey : Colors.black,
              decoration: isDone ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          TextSpan(
            text: text.substring(end),
            style: TextStyle(
              color: isBlocked ? Colors.grey : Colors.black,
              decoration: isDone ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final isDone = task.status == Status.done;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: isBlocked
          ? Colors.grey[300]
          : isDone
              ? Colors.green[50]
              : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ CHECKBOX
            Checkbox(
              value: isDone,
              onChanged: isBlocked
                  ? null
                  : (value) {
                      final updatedTask = task.copyWith(
                        status: value! ? Status.done : Status.todo,
                      );
                      provider.updateTask(updatedTask);
                    },
            ),

            /// ✅ CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔍 TITLE
                  buildHighlightedText(
                    task.title,
                    provider.searchQuery,
                    isDone,
                    isBlocked,
                  ),

                  const SizedBox(height: 4),

                  /// 📄 DESCRIPTION
                  Text(
                    task.description,
                    style: TextStyle(
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      color: isBlocked ? Colors.grey : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// 📅 DATE
                  Text(
                    "${task.dueDate.day}-${task.dueDate.month}-${task.dueDate.year}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// 🟢🔵 STATUS BADGE
                  buildStatusLabel(isDone),
                ],
              ),
            ),

            /// ✏️ EDIT + 🗑 DELETE
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(task: task),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteTask(task.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
