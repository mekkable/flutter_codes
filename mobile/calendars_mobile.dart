
final isCalendarExpandedProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class DatePicker extends HookConsumerWidget {
  const DatePicker({
    required this.hasEventsDate,
    super.key,
  });

  final List<DateTime> hasEventsDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final today = DateTime.now();

    final activeDate = useState<DateTime>(today);
    final isScrolling = useState(false);

    final _isCalendarExpanded = ref.watch(isCalendarExpandedProvider);

    final isDateSelected = useState(false);

    Future<void> handleDateTapInWeekCalendar(DateTime date) async {
      activeDate.value = date;
      isScrolling.value = true;
      final eventIndex = hasEventsDate.indexWhere(
        (eventDate) => eventDate.isAtSameMomentAs(
          date,
        ),
      );

      await ref
          .read(
            itemScrollControllerProvider,
          )
          .scrollTo(
            index: eventIndex != -1 ? eventIndex + 2 : 2,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeInOut,
          );
      isScrolling.value = false;
    }

    Future<void> handleDateTapInMonthCalendar(DateTime date) async {
      activeDate.value = date;
      isDateSelected.value = true;
      ref.read(isCalendarExpandedProvider.notifier).state = false;
      if (isDateSelected.value) {
        isScrolling.value = true;

        final index = hasEventsDate.indexWhere(
          (eventDate) => eventDate.isAtSameMomentAs(activeDate.value),
        );

        await ref.read(itemScrollControllerProvider).scrollTo(
              index: index + 2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
        isScrolling.value = false;
        isDateSelected.value = false;
      }
    }

    useEffect(
      () {
        void onItemPositionChanged() {
          // スクロール中は遷移先の日付で固定させる
          if (isScrolling.value) {
            return;
          }
          final positions =
              ref.read(itemPositionsListenerProvider).itemPositions.value;
          // 2つに跨るときは、上の日付を選択する
          final minimumIndex = positions.map((e) => e.index).reduce(math.min);
          // 上にバナーと「いますぐ」が入るため、その場合は最初の日付にする。
          final index = math.max(minimumIndex - 2, 0);
          // DatePickerの範囲外の日付の場合は、最後の日付にする
          final safeIndex = math.min(index, hasEventsDate.length - 1);
          activeDate.value = hasEventsDate[safeIndex];
        }

        final itemPositionsListener =
            ref.read(itemPositionsListenerProvider).itemPositions;
        itemPositionsListener.addListener(onItemPositionChanged);
        return () =>
            itemPositionsListener.removeListener(onItemPositionChanged);
      },
      const [],
    );

    return SizedBox(
      width: screenWidth,
      child: SurfaceEffect(
        child: ColoredBox(
          color: AppColors.surface$primary(context),
          child: AnimatedCrossFade(
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            sizeCurve: Curves.easeInOut,
            duration: const Duration(milliseconds: 150),
            firstChild: SizedBox(
              height: 86,
              child: Column(
                children: [
                  WeekCalendar(
                    focusDate: activeDate.value,
                    activeDates: hasEventsDate,
                    onTapDate: handleDateTapInWeekCalendar,
                  ),
                  GestureDetector(
                    onTap: () => ref
                        .read(isCalendarExpandedProvider.notifier)
                        .state = true,
                    child: SizedBox(
                      width: screenWidth,
                      child: AppAssets.icons.chevronDown.widget(
                        size: 22,
                        color: AppColors.surface$disabled(context),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              ),
            ),
            secondChild: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ),
                  ),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 4,
                ),
                height: 426,
                child: Column(
                  children: [
                    MonthCalendar(
                      focusDate: activeDate.value,
                      activeDates: hasEventsDate,
                      onTapDate: handleDateTapInMonthCalendar,
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(isCalendarExpandedProvider.notifier)
                          .state = false,
                      child: SizedBox(
                        width: screenWidth,
                        child: AppAssets.icons.chevronUp.widget(
                          size: 22,
                          color: AppColors.surface$disabled(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState: _isCalendarExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ),
      ),
    );
  }
}
