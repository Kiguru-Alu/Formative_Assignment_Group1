class Validators {
  Validators._();

  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 80) {
      return 'Title must be under 80 characters';
    }
    return null;
  }

  static String? description(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description must be under 500 characters';
    }
    return null;
  }

  static String? assignee(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please assign this task to a team member';
    }
    return null;
  }

  static String? deadline(DateTime? value, {bool isEditingExisting = false, DateTime? originalDeadline}) {
    if (value == null) {
      return 'Please select a due date';
    }
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    if (value.isBefore(startOfToday) &&
        !(isEditingExisting && originalDeadline != null)) {
      return 'Due date cannot be in the past';
    }
    return null;
  }
}