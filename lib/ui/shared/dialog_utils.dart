import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      icon: Icon(Icons.error, color: colorScheme.error, size: 48),

      title: Text(
        'An Error Occurred!',
        style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        textAlign: TextAlign.center,
      ),

      content: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(fontSize: 16),
        textAlign: TextAlign.center,
      ),

      actions: <Widget>[
        ActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

void showAppSnackBar(BuildContext context, {required String message}) {
  if (!context.mounted) return;

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,

          style: textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, this.actionText, this.onPressed});

  final String? actionText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      child: Text(
        actionText ?? "Okay",

        style: theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
