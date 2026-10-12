import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/ai_usecases.dart';

class AiPlannerCubit extends Cubit<List<Map<String, String>>> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => AiPlannerCubit(sl()),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.aiPlanner)),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<AiPlannerCubit, List<Map<String, String>>>(
                builder: (context, messages) {
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return ListTile(
                        title: Text(msg['role'] ?? ''),
                        subtitle: Text(msg['content'] ?? ''),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: l10n.typeMessage))),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      context.read<AiPlannerCubit>().send(text);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
