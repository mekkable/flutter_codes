final now = DateTime.now();
final baseDate = DateTime(now.year, now.month, now.day);
final List<DateTime> activeDates = List<DateTime>.generate(
  14,
  (i) => baseDate.add(
    Duration(days: i),
  ),
);
final weekCalendar = WidgetbookComponent(
  name: 'WeekCalendar',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return Center(
          child: WeekCalendar(
            activeDates: activeDates,
            focusDate: baseDate,
            onTapDate: (date) {},
          ),
        );
      },
    ),
  ],
);
