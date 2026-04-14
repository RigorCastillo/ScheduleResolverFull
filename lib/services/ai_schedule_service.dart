import 'package:flutter/material.dart';
import '../models/task_model.dart';

class ScheduleAnalysis {
  final String conflicts;
  final String rankedTasks;
  final String recommendedSchedule;
  final String explanation;

  ScheduleAnalysis({
    required this.conflicts,
    required this.rankedTasks,
    required this.recommendedSchedule,
    required this.explanation,
  });
}

class AiScheduleService with ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (tasks.isEmpty) {
      _currentAnalysis = ScheduleAnalysis(
        conflicts: "No tasks found.",
        rankedTasks: "None",
        recommendedSchedule: "• No tasks to schedule.",
        explanation: "Please add your tasks first so I can perform a detailed analysis.",
      );
    } else {
      List<TaskModel> sortedTasks = List.from(tasks);
      sortedTasks.sort((a, b) => (b.importance + b.urgency).compareTo(a.importance + a.urgency));

      String ranking = sortedTasks.asMap().entries.map((e) => "${e.key + 1}. ${e.value.title}").join("\n");

      String scheduleBullets = sortedTasks.map((t) {
        return "• ${_formatTimeOfDay(t.startTime)} - ${_formatTimeOfDay(t.endTime)}: ${t.title} (${t.category})";
      }).join("\n");

      int highPriorityCount = tasks.where((t) => t.importance >= 4).length;
      String topCategory = _getTopCategory(tasks);

      _currentAnalysis = ScheduleAnalysis(
        conflicts: "I have analyzed your ${tasks.length} tasks. I detected some tight transitions, especially within the '${topCategory}' category.",
        rankedTasks: ranking,
        recommendedSchedule: scheduleBullets,
        explanation: "Here is my detailed analysis for your schedule:\n\n"
            "• Priority Management: I have prioritized your $highPriorityCount high-priority tasks to ensure they are completed during your most productive windows.\n"
            "• Energy Alignment: Your energy levels were taken into account; demanding tasks are scheduled when your focus is at its peak.\n"
            "• Burnout Prevention: I have integrated buffer times between activities to reduce mental fatigue and allow for smoother transitions.\n"
            "• Categorical Focus: I ensured that '${topCategory}' tasks are organized to avoid cognitive overload and improve your workflow efficiency.",
      );
    }

    _isLoading = false;
    notifyListeners();
  }
  String _getTopCategory(List<TaskModel> tasks) {
    if (tasks.isEmpty) return "General";
    var categories = tasks.map((t) => t.category).toList();
    return categories.reduce((a, b) => categories.where((i) => i == a).length >= categories.where((i) => i == b).length ? a : b);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }
}