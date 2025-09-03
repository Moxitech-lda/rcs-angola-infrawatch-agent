import 'package:flutter/material.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String message,
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // não fecha clicando fora
    builder: (BuildContext ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Confirmação",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // só fecha
            child: const Text("Não"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // fecha primeiro
              onConfirm(); // executa a função passada
            },
            child: const Text("Sim"),
          ),
        ],
      );
    },
  );
}

class AsyncIconButton extends StatefulWidget {
  final String tooltip;
  final Future<void> Function() onPressed;
  final Icon icon;

  const AsyncIconButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });
  @override
  State<AsyncIconButton> createState() => _AsyncIconButtonState();
}

class _AsyncIconButtonState extends State<AsyncIconButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;
    if (context.mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await widget.onPressed();
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: _isLoading ? null : _handlePress,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : widget.icon,
    );
  }
}
