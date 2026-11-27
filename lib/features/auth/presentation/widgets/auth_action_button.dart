import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/motion/app_press_feedback.dart';

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.filledColor = AppColors.authPrimary,
    this.radius = AppRadius.authField,
    this.outline = AppColors.authSubtleOutline,
    this.trailing,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final Color filledColor;
  final double radius;
  final Color outline;
  final Widget? trailing;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : AppColors.authPrimary;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (trailing != null || loadingLabel != null) ...[
          const SizedBox(width: AppSpacing.small),
          if (loadingLabel case final pending?)
            SizedBox.square(
              dimension: 24,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                  semanticsLabel: pending,
                ),
              ),
            )
          else
            trailing!,
        ],
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    return SizedBox(
      width: double.infinity,
      child: AppPressFeedback(
        builder: (context, states) => filled
            ? FilledButton(
                statesController: states,
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  foregroundColor: foreground,
                  backgroundColor: filledColor,
                  disabledForegroundColor: Colors.white,
                  disabledBackgroundColor: filledColor.withValues(alpha: .65),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: AppTypography.authHeading,
                  shape: shape,
                ),
                child: content,
              )
            : OutlinedButton(
                statesController: states,
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: foreground,
                  disabledForegroundColor: foreground.withValues(alpha: .65),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: outline),
                  textStyle: AppTypography.authHeading,
                  shape: shape,
                ),
                child: content,
              ),
      ),
    );
  }
}
