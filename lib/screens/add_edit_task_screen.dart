import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDate;
  Status selectedStatus = Status.todo;
  String? selectedBlockedTaskId;

  /// ✅ NEW: Recurring
  RecurringType selectedRecurring = RecurringType.none;

  String? get currentTaskId => widget.task?.id;

  /// STATUS TEXT
  String statusToString(Status status) {
    switch (status) {
      case Status.todo:
        return "To-Do";
      case Status.inProgress:
        return "In Progress";
      case Status.done:
        return "Done";
    }
  }

  /// ✅ NEW: RECURRING TEXT
  String recurringToString(RecurringType type) {
    switch (type) {
      case RecurringType.none:
        return "No Repeat";
      case RecurringType.daily:
        return "Daily";
      case RecurringType.weekly:
        return "Weekly";
    }
  }

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.task != null) {
      final t = widget.task!;
      titleController.text = t.title;
      descriptionController.text = t.description;
      selectedDate = t.dueDate;
      selectedStatus = t.status;
      selectedBlockedTaskId = t.blockedByTaskId;

      /// ✅ LOAD RECURRING WHEN EDITING
      selectedRecurring = t.recurringType;
    } else {
      titleController.text = provider.draftTitle;
      descriptionController.text = provider.draftDescription;
      selectedDate = provider.draftDate;

      selectedRecurring = RecurringType.none;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// TITLE
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                onChanged: (value) {
                  provider.saveDraft(
                    title: value,
                    description: descriptionController.text,
                    date: selectedDate,
                  );
                },
              ),

              const SizedBox(height: 10),

              /// DESCRIPTION
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (value) {
                  provider.saveDraft(
                    title: titleController.text,
                    description: value,
                    date: selectedDate,
                  );
                },
              ),

              const SizedBox(height: 15),

              /// DATE PICKER
              Row(
                children: [
                  Text(
                    selectedDate == null
                        ? "No Date Selected"
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                  ),
                  const Spacer(),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Pick Date"),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });

                        provider.saveDraft(
                          title: titleController.text,
                          description: descriptionController.text,
                          date: picked,
                        );
                      }
                    },
                  ),

                  const SizedBox(width: 8),

                  if (selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selectedDate = null;
                        });

                        provider.saveDraft(
                          title: titleController.text,
                          description: descriptionController.text,
                          date: null,
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(height: 15),

              /// STATUS DROPDOWN
              DropdownButton<Status>(
                value: selectedStatus,
                isExpanded: true,
                items: Status.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(statusToString(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              /// ✅ NEW: RECURRING DROPDOWN
              DropdownButton<RecurringType>(
                value: selectedRecurring,
                isExpanded: true,
                items: RecurringType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(recurringToString(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRecurring = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              /// BLOCKED BY DROPDOWN
              DropdownButton<String?>(
                hint: const Text("Blocked By Task"),
                value: selectedBlockedTaskId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Blocked By (Optional)"),
                  ),
                  ...provider.tasks
                      .where((t) => t.id != currentTaskId)
                      .map((t) {
                    return DropdownMenuItem(
                      value: t.id,
                      child: Text(
                        t.status == Status.done
                            ? "${t.title} (Done)"
                            : t.title,
                      ),
                    );
                  }),
                ],
                onChanged: provider.tasks.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          selectedBlockedTaskId = value;
                        });
                      },
              ),

              const SizedBox(height: 25),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty &&
                              selectedDate == null) {
                            showError(
                                "Please enter title and select a date");
                            return;
                          }

                          if (titleController.text.trim().isEmpty) {
                            showError("Please enter title");
                            return;
                          }

                          if (selectedDate == null) {
                            showError("Please select a date");
                            return;
                          }

                          final task = Task(
                            id: widget.task?.id ??
                                DateTime.now().toString(),
                            title: titleController.text,
                            description: descriptionController.text,
                            dueDate: selectedDate!,
                            status: selectedStatus,
                            blockedByTaskId:
                                selectedBlockedTaskId,

                            /// ✅ PASS RECURRING
                            recurringType: selectedRecurring,
                          );

                          if (widget.task == null) {
                            await provider.addTask(task);
                            await provider.clearDraft();
                          } else {
                            await provider.updateTask(task);
                          }

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}