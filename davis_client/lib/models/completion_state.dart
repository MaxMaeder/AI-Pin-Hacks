enum CompletionState {
  idle("Hold to Speak", "To use vision, first tap then hold."),
  listening("Listening..."),
  thinking("Thinking..."),
  responding("Responding...", "Tap to cancel.");

  final String message;
  final String? details;

  const CompletionState(this.message, [this.details]);
}
