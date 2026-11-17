import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/ai_usecases.dart';

class AiPlannerCubit extends SafeCubit<List<Map<String, String>>> {
  AiPlannerCubit(this._chat) : super(const []);
  final AiChat _chat;

  Future<void> send(String text) async {
    final next = [...state, {'role': 'user', 'content': text}];
    emit(next);
    final result = await _chat(next);
    result.fold(
      (f) => emit([...state, {'role': 'assistant', 'content': f.message}]),
      (data) {
        final reply = data['reply']?.toString() ?? data['content']?.toString() ?? data.toString();
        emit([...state, {'role': 'assistant', 'content': reply}]);
      },
    );
  }
}

class AiPlannerPage extends StatefulWidget {
  const AiPlannerPage({super.key});

  @override
  State<AiPlannerPage> createState() => _AiPlannerPageState();
}

class _AiPlannerPageState extends State<AiPlannerPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => AiPlannerCubit(sl()),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(showBack: true, eyebrow: l10n.aiPlanner, title: l10n.aiPlanner, subtitle: l10n.aiSubtitle),
            Expanded(
              child: BlocConsumer<AiPlannerCubit, List<Map<String, String>>>(
                listener: (_, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scroll.hasClients) {
                      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                    }
                  });
                },
                builder: (context, messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 36,
                              backgroundColor: AppTheme.wash,
                              child: Icon(Icons.auto_awesome, color: AppTheme.navy, size: 32),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.aiPlanner, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                            const SizedBox(height: 8),
                            Text(l10n.askPlannerHint, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, height: 1.4)),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final mine = msg['role'] == 'user';
                      return Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: mine ? AppTheme.navy : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(mine ? 18 : 4),
                              bottomRight: Radius.circular(mine ? 4 : 18),
                            ),
                            border: mine ? null : Border.all(color: AppTheme.line),
                          ),
                          child: Text(
                            msg['content'] ?? '',
                            style: TextStyle(color: mine ? Colors.white : AppTheme.ink, height: 1.4),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Material(
              color: Colors.white,
              elevation: 12,
              shadowColor: AppTheme.navy.withValues(alpha: 0.12),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: l10n.typeMessage,
                            filled: true,
                            fillColor: AppTheme.canvas,
                          ),
                          onSubmitted: (_) => _send(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppTheme.yellow,
                        child: IconButton(
                          onPressed: () => _send(context),
                          icon: const Icon(Icons.send_rounded, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    context.read<AiPlannerCubit>().send(text);
    _controller.clear();
  }
}
