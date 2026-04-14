class ScheduleAnalysis {

  final String conflicts;
  final String rankedTasks;
  final String recommendationSchedule;
  final String explanations;

  ScheduleAnalysis({
    required this.conflicts, required this.rankedTasks,
    required this.recommendationSchedule, required this.explanations,
});
}