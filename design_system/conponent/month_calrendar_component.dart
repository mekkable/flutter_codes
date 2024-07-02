class MonthCalendar extends HookWidget {
  const MonthCalendar({
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
    final lastDay = activeDates.lastOrNull ?? DateTime.now();

    /// すべての月に対する日付リスト
    final allDates = _generateAllDates(today, lastDay);
    final monthPageController = usePageController();

    final monthCount = _calculateMonthCount(today, lastDay);

    useEffect(
      () {
        final monthPageIndex = _calculateMonthCount(today, focusDate) - 1;
        if (monthPageController.hasClients) {
          monthPageController.jumpToPage(
            monthPageIndex,
          );
        }

        return null;
      },
      [focusDate],
    );

    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: monthPageController,
        itemCount: monthCount,
        itemBuilder: (context, index) {
          final monthDates = _getDatesForPage(index, allDates);
          final showingDate = DateTime(today.year, today.month + index);
          return Container(
            height: 400,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    today.month == showingDate.month &&
                            today.year == showingDate.year
                        ? InlineMButton.outlined(
                            text: '前月',
                            onPressed: null,
                            leftIcon: AppAssets.icons.arrowLeft,
                          )
                        : InlineMButton.outlined(
                            text: '前月',
                            onPressed: () {
                              monthPageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            leftIcon: AppAssets.icons.arrowLeft,
                          ),
                    DisplayMonth(month: showingDate.month.toString()),
                    lastDay.month == showingDate.month &&
                            lastDay.year == showingDate.year
                        ? InlineMButton.outlined(
                            text: '次月',
                            onPressed: null,
                            rightIcon: AppAssets.icons.arrowRight,
                          )
                        : InlineMButton.outlined(
                            text: '次月',
                            onPressed: () {
                              monthPageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            rightIcon: AppAssets.icons.arrowRight,
                          ),
                  ],
                ),
                for (int i = 0; i < monthDates.length; i += 7)
                  Row(
                    children: monthDates
                        .sublist(
                          i,
                          i + 7 > monthDates.length ? monthDates.length : i + 7,
                        )
                        .take(7)
                        .mapIndexed(
                          (index, date) => Expanded(
                            child: InkWell(
                              onTap: activeDates.contains(
                                DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                ),
                              )
                                  ? () {
                                      onTapDate(
                                        date,
                                      );
                                    }
                                  : null,
                              child: DisplayDate(
                                date: date,
                                showDay: i == 0,
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
                                currentMonth:
                                    date.month == monthDates[17].month,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final today = DateTime.now();

/// 今日を含む月の最初の週の日曜日から、最後のイベントがある日を含む月の最後の週の土曜日までの日付リストを生成する
List<DateTime> _generateAllDates(DateTime startDate, DateTime endDate) {
  final startOfMonth = DateTime(
    startDate.year,
    startDate.month,
  );
  final firstDayToShow =
      startOfMonth.subtract(Duration(days: startOfMonth.weekday % 7));

  final endOfMonth = DateTime(endDate.year, endDate.month + 1, 0);
  final lastDayToShow = endOfMonth.weekday == DateTime.sunday
      ? endOfMonth.add(const Duration(days: 6))
      : endOfMonth.add(Duration(days: 6 - endOfMonth.weekday));

  final allDays = <DateTime>[];
  for (var d = firstDayToShow;
      !d.isAfter(lastDayToShow);
      d = d.add(const Duration(days: 1))) {
    allDays.add(d);
  }

  return allDays;
}

/// ページインデックスに基づいて、そのページの月だけの日付リストを_generateAllDatesと同じように生成する
List<DateTime> _getDatesForPage(int pageIndex, List<DateTime> allDates) {
  final baseMonth = DateTime(
    today.year,
    today.month + pageIndex,
  );
  final startOfMonth = DateTime(
    baseMonth.year,
    baseMonth.month,
  );
  final endOfMonth = DateTime(baseMonth.year, baseMonth.month + 1, 0);

  final firstDayToShow =
      startOfMonth.subtract(Duration(days: startOfMonth.weekday % 7));
  final lastDayToShow = endOfMonth.weekday == DateTime.sunday
      ? endOfMonth.add(const Duration(days: 6))
      : endOfMonth.add(Duration(days: 6 - endOfMonth.weekday));

  final monthStartIndex = allDates.indexWhere((date) => date == firstDayToShow);
  final monthEndIndex = allDates.indexWhere((date) => date == lastDayToShow);

  return allDates.sublist(monthStartIndex, monthEndIndex + 1);
}

// todayからlastDayまでの月数を計算
int _calculateMonthCount(DateTime start, DateTime end) {
  return (end.year - start.year) * 12 + end.month - start.month + 1;
}

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
