import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/error/error_handler.dart';
import '../../../providers/calendar_provider.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';

/// ============================================
/// 캘린더 페이지
/// ============================================

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  void _goToPreviousMonth() {
    setState(() {
      currentMonth = CalendarLogic.getPreviousMonth(currentMonth);
    });
  }

  void _goToNextMonth() {
    setState(() {
      currentMonth = CalendarLogic.getNextMonth(currentMonth);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  Future<void> _showAddScheduleDialog() async {
    if (selectedDate == null) return;

    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('일정 추가 - ${DateHelper.formatShort(selectedDate!)}'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: titleController,
              placeholder: '일정 제목',
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: timeController,
              placeholder: '시간 (예: 14:00)',
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: locationController,
              placeholder: '장소',
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('추가'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      try {
        await ScheduleLogic.addSchedule(
          date: selectedDate!,
          title: titleController.text,
          time: timeController.text.isNotEmpty ? timeController.text : null,
          location: locationController.text.isNotEmpty
              ? locationController.text
              : null,
        );

        if (mounted) {
          await context.read<CalendarProvider>().loadData();
          await DialogHelper.showSuccess(
            context,
            content: '일정이 추가되었습니다',
          );
        }
      } catch (e) {
        if (mounted) {
          await ErrorHandler.showError(context, e);
        }
      }
    }
  }

  Future<void> _deleteSchedule(int index) async {
    if (selectedDate == null) return;

    try {
      await ScheduleLogic.deleteSchedule(
        date: selectedDate!,
        index: index,
      );

      if (mounted) {
        await context.read<CalendarProvider>().loadData();
      }
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('캘린더'),
            ),
            child: const AppLoadingIndicator(),
          );
        }

        if (provider.error != null) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('캘린더'),
            ),
            child: ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadData(),
            ),
          );
        }

        final datesWithData = <String, bool>{};
        for (final dateKey in provider.schedules.keys) {
          datesWithData[dateKey] = true;
        }
        for (final dateKey in provider.outfits.keys) {
          datesWithData[dateKey] = true;
        }

        final selectedDateKey =
            selectedDate != null ? DateHelper.toDateKey(selectedDate!) : null;
        final selectedSchedules = selectedDateKey != null
            ? provider.getSchedulesByDate(selectedDateKey)
            : <Map<String, dynamic>>[];
        final selectedOutfits = selectedDateKey != null
            ? provider.getOutfitsByDate(selectedDateKey)
            : <Map<String, dynamic>>[];

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('캘린더'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showAddScheduleDialog,
              child: const Icon(CupertinoIcons.add),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                MonthSelector(
                  currentMonth: currentMonth,
                  onPrevious: _goToPreviousMonth,
                  onNext: _goToNextMonth,
                ),
                CalendarGrid(
                  currentMonth: currentMonth,
                  selectedDate: selectedDate,
                  datesWithData: datesWithData,
                  onDateSelected: _selectDate,
                ),
                Container(
                  height: 1,
                  color: AppColors.border,
                ),
                if (selectedDate != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateHelper.formatFull(selectedDate!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${DateHelper.getWeekday(selectedDate!)})',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScheduleList(
                          schedules: selectedSchedules,
                          onDelete: _deleteSchedule,
                        ),
                        if (selectedOutfits.isNotEmpty) ...[
                          Container(
                            height: 1,
                            color: AppColors.border,
                          ),
                          OutfitList(
                            outfits: selectedOutfits,
                            onTap: () {},
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
