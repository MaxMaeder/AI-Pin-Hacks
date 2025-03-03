import 'package:davis_client/models/completion_state.dart';

class AssistantState {
  final CompletionState completionState;
  final String? errorMessage;

  AssistantState({required this.completionState, this.errorMessage});

  AssistantState copyWith({
    CompletionState? completionState,
    String? errorMessage,
  }) {
    return AssistantState(
      completionState: completionState ?? this.completionState,
      errorMessage: errorMessage,
    );
  }
}
