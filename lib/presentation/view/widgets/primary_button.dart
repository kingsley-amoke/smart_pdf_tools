import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.fontWeight,
    this.iconSize,
    required this.isProcessing,
    required this.progress,
    required this.statusMessage,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? iconSize;
  final bool isProcessing;
  final String statusMessage;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return isProcessing
        ? Card(
            elevation: 1,
            color: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$statusMessage • ${(progress * 100).toStringAsFixed(0)}%',
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  backgroundColor ?? Theme.of(context).primaryColor,
              foregroundColor:
                  foregroundColor ?? Theme.of(context).colorScheme.onPrimary,

              textStyle: TextStyle(
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
              iconSize: iconSize ?? 24,
            ),
          );
  }
}
