final now = DateTime.now();
final baseDate = DateTime(now.year, now.month, now.day);
final List<DateTime> hasEventsDate = List<DateTime>.generate(
  42,
  (i) => baseDate.add(
    Duration(days: i),
  ),
);

final monthCalendar = WidgetbookComponent(
  name: 'MonthCalendar',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return Center(
          child: MonthCalendar(
            activeDates: hasEventsDate,
            focusDate: baseDate,
            onTapDate: (date) {},
          ),
        );
      },
    ),
  ],
);
