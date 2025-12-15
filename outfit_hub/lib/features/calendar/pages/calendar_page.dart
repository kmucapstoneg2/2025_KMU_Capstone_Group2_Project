import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/services/google_calendar_service.dart';
import '../../../providers/calendar_provider.dart';
import '../../../providers/auth_provider.dart';
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
  bool _showGoogleBanner = true;  // 구글 연동 배너 표시 여부

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    // 구글 캘린더 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().checkGoogleCalendarStatus();
    });
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

  /// 구글 캘린더 연동 시작
  Future<void> _linkGoogleCalendar() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.accessToken;
      
      if (token == null) {
        if (mounted) {
          await DialogHelper.showAlert(
            context,
            title: '로그인 필요',
            content: '먼저 로그인해주세요',
          );
        }
        return;
      }

      final authUrl = GoogleCalendarService.getGoogleAuthUrl();
      final uri = Uri.parse(authUrl);
      
      // 외부 브라우저에서 OAuth 인증 페이지 열기
      if (await canLaunchUrl(uri)) {
        // 외부 브라우저로 열기
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // 사용자에게 안내 메시지
        if (mounted) {
          await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('구글 캘린더 연동'),
              content: const Column(
                children: [
                  SizedBox(height: 12),
                  Text(
                    '브라우저에서 구글 계정으로 로그인하고\n'
                    '권한을 승인해주세요.\n\n'
                    '완료 후 아래 버튼을 눌러주세요.',
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('취소'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('연동 확인'),
                  onPressed: () async {
                    Navigator.pop(context);
                    // 백엔드에서 연동 상태 확인
                    await _checkGoogleLinkStatus();
                  },
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          await DialogHelper.showAlert(
            context,
            title: '오류',
            content: '브라우저를 열 수 없습니다',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }
  
  /// 구글 캘린더 연동 상태 확인
  Future<void> _checkGoogleLinkStatus() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.accessToken;
      
      if (token == null) {
        if (mounted) {
          await DialogHelper.showAlert(
            context,
            title: '로그인 필요',
            content: '앱에 먼저 로그인해주세요',
          );
        }
        return;
      }

      // 백엔드에서 구글 캘린더 일정 가져오기 시도
      await GoogleCalendarService.fetchSchedules(userToken: token);
      
      // 성공하면 연동 완료 (구글 이메일 입력받기)
      if (mounted) {
        final googleEmail = await showCupertinoDialog<String>(
          context: context,
          builder: (context) {
            final controller = TextEditingController();
            return CupertinoAlertDialog(
              title: const Text('구글 계정 입력'),
              content: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text('방금 로그인한 구글 계정 이메일을 입력하세요:'),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: controller,
                    placeholder: 'example@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('취소'),
                  onPressed: () => Navigator.pop(context, null),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('확인'),
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                ),
              ],
            );
          },
        );

        if (googleEmail != null && googleEmail.isNotEmpty) {
          await context.read<CalendarProvider>().linkGoogleCalendar(
            accessToken: token,
            email: googleEmail,
          );
          
          if (mounted) {
            await DialogHelper.showSuccess(
              context,
              content: '구글 캘린더가 연동되었습니다\n($googleEmail)',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        await DialogHelper.showAlert(
          context,
          title: '연동 실패',
          content: '구글 캘린더 연동에 실패했습니다.\n브라우저에서 로그인을 완료하셨나요?',
        );
      }
    }
  }
  
  /// 구글 캘린더 연동 해제
  Future<void> _unlinkGoogleCalendar() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('연동 해제'),
        content: const Text('구글 캘린더 연동을 해제하시겠습니까?\n\n연동 해제 후에도 이미 추가된 일정은 유지됩니다.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('연동 해제'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    if (result == true && mounted) {
      await context.read<CalendarProvider>().unlinkGoogleCalendar();
      await DialogHelper.showSuccess(
        context,
        content: '구글 캘린더 연동이 해제되었습니다',
      );
    }
  }
  
  /// 구글 캘린더 동기화
  Future<void> _syncGoogleCalendar() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.accessToken;
      
      if (token == null) {
        if (mounted) {
          await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('알림'),
              content: const Text('로그인이 필요합니다'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('확인'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        return;
      }
      
      await context.read<CalendarProvider>().syncGoogleCalendar(userToken: token);
      
      if (mounted) {
        await DialogHelper.showSuccess(
          context,
          content: '일정이 동기화되었습니다',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _showAddScheduleDialog() async {
    if (selectedDate == null) return;
    
    final provider = context.read<CalendarProvider>();
    final isGoogleLinked = provider.isGoogleLinked;

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
            if (isGoogleLinked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      size: 14,
                      color: Color(0xFF1976D2),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '구글 캘린더에도 추가됩니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        if (isGoogleLinked) {
          // 구글 캘린더 연동 시 - 구글 캘린더 + 로컬 모두 저장
          final authProvider = context.read<AuthProvider>();
          final token = authProvider.accessToken;
          
          if (token != null) {
            await provider.addScheduleToGoogle(
              userToken: token,
              dateKey: DateHelper.toDateKey(selectedDate!),
              title: titleController.text,
              time: timeController.text.isNotEmpty ? timeController.text : null,
              location: locationController.text.isNotEmpty
                  ? locationController.text
                  : null,
            );
          } else {
            // 토큰 없으면 로컬에만 저장
            await ScheduleLogic.addSchedule(
              date: selectedDate!,
              title: titleController.text,
              time: timeController.text.isNotEmpty ? timeController.text : null,
              location: locationController.text.isNotEmpty
                  ? locationController.text
                  : null,
            );
          }
        } else {
          // 구글 캘린더 미연동 시 - 로컬에만 저장
          await ScheduleLogic.addSchedule(
            date: selectedDate!,
            title: titleController.text,
            time: timeController.text.isNotEmpty ? timeController.text : null,
            location: locationController.text.isNotEmpty
                ? locationController.text
                : null,
          );
        }

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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 새로고침 버튼 (구글 연동 시에만 동기화 표시)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: provider.isSyncing ? null : () async {
                    if (provider.isGoogleLinked) {
                      await _syncGoogleCalendar();
                    } else {
                      await provider.loadData();
                    }
                  },
                  child: provider.isSyncing
                      ? const CupertinoActivityIndicator()
                      : const Icon(CupertinoIcons.arrow_2_circlepath),
                ),
                // 일정 추가 버튼
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showAddScheduleDialog,
                  child: const Icon(CupertinoIcons.add),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 구글 캘린더 연동 배너
                if (_showGoogleBanner)
                  GoogleCalendarBanner(
                    isLinked: provider.isGoogleLinked,
                    linkedEmail: provider.googleLinkedEmail,
                    isSyncing: provider.isSyncing,
                    onLinkPressed: _linkGoogleCalendar,
                    onUnlinkPressed: _unlinkGoogleCalendar,
                    onSyncPressed: _syncGoogleCalendar,
                  ),
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
