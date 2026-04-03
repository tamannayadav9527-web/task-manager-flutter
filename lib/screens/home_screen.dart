import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    /// FILTERED + SEARCHED TASK LIST
    final filteredTasks = provider.tasks.where((task) {
      final matchesSearch = task.title
          .toLowerCase()
          .contains(provider.searchQuery.toLowerCase());

      final matchesFilter = provider.filterStatus == null ||
          task.status == provider.filterStatus;

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        centerTitle: true,
        elevation: 1,
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                provider.onSearchChanged(value);
              },
            ),
          ),

          /// 🎯 FILTER DROPDOWN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<Status?>(
                value: provider.filterStatus,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text("Filter by Status"),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("All Tasks"),
                  ),
                  ...Status.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(statusToString(status)),
                    );
                  }),
                ],
                onChanged: (value) {
                  provider.setFilter(value); // ✅ FIXED (no direct notifyListeners)
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 📋 TASK LIST / EMPTY STATE
          Expanded(
            child: filteredTasks.isEmpty
                ? const EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final isBlocked = provider.isBlocked(task);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: task,
                          isBlocked: isBlocked,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      /// ➕ ADD TASK BUTTON
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTaskScreen(task: null),
            ),
          );
        },
      ),
    );
  }

  /// STATUS TEXT
  static String statusToString(Status status) {
    switch (status) {
      case Status.todo:
        return "To-Do";
      case Status.inProgress:
        return "In Progress";
      case Status.done:
        return "Done";
    }
  }
}

/// 🌟 EMPTY STATE WIDGET
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.inbox,
            size: 70,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            "No tasks found 😔",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Try adding a new task",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}