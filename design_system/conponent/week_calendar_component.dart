class WeekCalendar extends HookWidget {
  const WeekCalendar({
    required this.activeDates,
    required this.focusDate,
    required this.onTapDate,
    super.key,
  });

  final List<DateTime> activeDates;
  final DateTime focusDate;
  final Function(DateTime) onTapDate;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final lastDay = activeDates.lastOrNull ?? DateTime.now();

    final showingMonthForWeekCalendar = useState<DateTime>(today);
    final weekPageController = usePageController();

    final diffDays = lastDay.difference(today).inDays;

    final modifiedDaysForWeekCalendar = diffDays + 7 - (diffDays % 7);
    final allDates = List.generate(
      modifiedDaysForWeekCalendar,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    useEffect(
      () {
        void onWeekPageChanged() {
          final currentWeek = weekPageController.page?.floor();
          if (currentWeek != null) {
            showingMonthForWeekCalendar.value = allDates[currentWeek * 7];
          }
        }

        final weekPageIndex = focusDate.difference(allDates[0]).inDays ~/ 7;
        if (weekPageController.hasClients) {
          weekPageController.animateToPage(
            weekPageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          final currentWeek = weekPageController.page?.floor();
          if (currentWeek != null) {
            showingMonthForWeekCalendar.value = allDates[currentWeek * 7];
          }
        }

        weekPageController.addListener(onWeekPageChanged);

        return () {
          weekPageController.removeListener(onWeekPageChanged);
        };
      },
      [weekPageController, focusDate],
    );
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          DisplayMonth(
            month: showingMonthForWeekCalendar.value.month.toString(),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 7),
            child: VerticalDivider(
              color: AppColors.border(context),
              thickness: 1,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: weekPageController,
              itemCount: allDates.length ~/ 7,
              itemBuilder: (context, index) {
                final weekDates = allDates.sublist(index * 7, (index + 1) * 7);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  key: ValueKey<int>(index),
                  children: [
                    ...weekDates.mapIndexed(
                      (weekIndex, date) {
                        final hasEvent = activeDates.contains(
                          DateTime(
                            date.year,
                            date.month,
                            date.day,
                          ),
                        );
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                            ),
                            child: InkWell(
                              onTap: hasEvent
                                  ? () => onTapDate(
                                        date,
                                      )
                                  : null,
                              child: DisplayDate(
                                showDay: true,
                                date: date,
                                type: date == focusDate
                                    ? DisplayDateType.focus
                                    : activeDates.contains(
                                        DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                        ),
                                      )
                                        ? DisplayDateType.active
                                        : DisplayDateType.disabled,
                                currentMonth: true,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
