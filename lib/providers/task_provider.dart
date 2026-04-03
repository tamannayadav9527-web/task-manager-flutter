import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/models/task.dart';
import 'dart:async';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  bool isLoading = false;
  String searchQuery = '';
  Status? filterStatus;

  Timer? _debounce;

  /// Draft (persistent)
  String draftTitle = '';
  String draftDescription = '';
  DateTime? draftDate;

  ///  DEBOUNCED SEARCH
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery = query;
      notifyListeners();
    });
  }

  /// LOAD EVERYTHING
  Future<void> loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    /// LOAD TASKS
    final taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      _tasks = taskList.map((t) => Task.fromJson(jsonDecode(t))).toList();
    }

    /// LOAD DRAFT
    draftTitle = prefs.getString('draftTitle') ?? '';
    draftDescription = prefs.getString('draftDescription') ?? '';

    final dateString = prefs.getString('draftDate');
    if (dateString != null) {
      draftDate = DateTime.parse(dateString);
    }

    notifyListeners();
  }

  /// SAVE TASKS
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final taskList = _tasks.map((t) => jsonEncode(t.toJson())).toList();

    await prefs.setStringList('tasks', taskList);

    debugPrint('Saved tasks count: ${_tasks.length}');
  }

  /// SAVE DRAFT
  Future<void> saveDraft({
    required String title,
    required String description,
    DateTime? date,
  }) async {
    draftTitle = title;
    draftDescription = description;
    draftDate = date;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('draftTitle', title);
    await prefs.setString('draftDescription', description);

    if (date != null) {
      await prefs.setString('draftDate', date.toIso8601String());
    }
  }

  /// CLEAR DRAFT
  Future<void> clearDraft() async {
    draftTitle = '';
    draftDescription = '';
    draftDate = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draftTitle');
    await prefs.remove('draftDescription');
    await prefs.remove('draftDate');

    notifyListeners();
  }

  /// FILTERED TASKS
  List<Task> get tasks {
    List<Task> filtered = _tasks;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (filterStatus != null) {
      filtered = filtered.where((t) => t.status == filterStatus).toList();
    }

    return filtered;
  }

  /// ADD TASK
  Future<void> addTask(Task task) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _tasks.add(task);
    await saveTasks();

    isLoading = false;
    notifyListeners();
  }

  /// DELETE TASK
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await saveTasks();
    notifyListeners();
  }

  /// UPDATED TASK WITH RECURRING LOGIC
  Future<void> updateTask(Task updatedTask) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);

    if (index != -1) {
      _tasks[index] = updatedTask;
    }

    /// RECURRING LOGIC
    if (updatedTask.status == Status.done &&
        updatedTask.recurringType != RecurringType.none) {

      DateTime newDate = updatedTask.dueDate;

      if (updatedTask.recurringType == RecurringType.daily) {
        newDate = newDate.add(const Duration(days: 1));
      } else if (updatedTask.recurringType == RecurringType.weekly) {
        newDate = newDate.add(const Duration(days: 7));
      }

      final newTask = Task(
        id: DateTime.now().toString(),
        title: updatedTask.title,
        description: updatedTask.description,
        dueDate: newDate,
        status: Status.todo,
        blockedByTaskId: updatedTask.blockedByTaskId,
        recurringType: updatedTask.recurringType,
      );

      _tasks.add(newTask);
    }

    /// SAVE AFTER EVERYTHING
    await saveTasks();

    isLoading = false;
    notifyListeners();
  }

  /// BLOCKING LOGIC
  bool isBlocked(Task task) {
    if (task.blockedByTaskId == null) return false;

    final blockedTask = _tasks.firstWhere(
      (t) => t.id == task.blockedByTaskId,
      orElse: () => task,
    );

    if (blockedTask.id == task.id) return false;

    return blockedTask.status != Status.done;
  }

  void setFilter(Status? value) {}
}
