import 'package:flutter/material.dart';
import 'feedback_bottom_sheet.dart';
import 'parental_gate_dialog.dart';

class FeedbackFab extends StatelessWidget {
  final bool isExtended;
  final String label;
  final String tooltip;

  const FeedbackFab({
    super.key,
    this.isExtended = false,
    this.label = 'Feedback',
    this.tooltip = 'Enviar sugerencias o comentarios',
  });

  void _abrirFeedbackConPuertaParental(BuildContext context) {
    ParentalGateDialog.verificar(
      context,
      onExito: () => FeedbackBottomSheet.show(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: () => _abrirFeedbackConPuertaParental(context),
        icon: const Icon(Icons.feedback_outlined, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        tooltip: tooltip,
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    }

    return FloatingActionButton(
      onPressed: () => _abrirFeedbackConPuertaParental(context),
      tooltip: tooltip,
      backgroundColor: primaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.rate_review_outlined, color: Colors.white),
    );
  }
}
