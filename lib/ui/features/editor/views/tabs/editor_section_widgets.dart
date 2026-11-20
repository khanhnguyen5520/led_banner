import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shared dark-studio section header used across editor tabs.
class EditorSectionTitle extends StatelessWidget {
  const EditorSectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Shared labeled slider card row for consistent editor ergonomics.
class EditorSliderTile extends StatelessWidget {
  const EditorSliderTile({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryCyan,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Interactive color swatch chip that opens the full color picker on tap.
class ColorPickButton extends StatelessWidget {
  const ColorPickButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.colorize_rounded, size: 18, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
