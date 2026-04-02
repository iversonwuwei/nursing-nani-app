import 'package:flutter/material.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class FlowActionCard extends StatelessWidget {
  const FlowActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
    this.tag,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedHeight = constraints.maxHeight.isFinite;
            final isShort = hasBoundedHeight && constraints.maxHeight <= 170;
            final isUltraCompact = hasBoundedHeight && constraints.maxHeight <= 148;
            final isCompact = constraints.maxWidth <= 150 || isShort;
            final resolvedPadding = EdgeInsets.all(
              isUltraCompact ? 12 : isCompact ? 14 : 16,
            );
            final iconSize = isUltraCompact ? 34.0 : isCompact ? 38.0 : 42.0;

            return Padding(
              padding: resolvedPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: isUltraCompact ? 18 : isCompact ? 20 : 24,
                        ),
                      ),
                      const Spacer(),
                      if (isCompact && tag != null)
                        StatusChip(label: tag!, color: color)
                      else
                        const Icon(
                          Icons.arrow_outward_rounded,
                          size: 18,
                          color: AppPalette.textSecondary,
                        ),
                    ],
                  ),
                  SizedBox(height: isUltraCompact ? 10 : isCompact ? 12 : 14),
                  Text(
                    title,
                    maxLines: isCompact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: isUltraCompact ? 16 : null,
                      height: isCompact ? 1.2 : null,
                    ),
                  ),
                  SizedBox(height: isUltraCompact ? 2 : isCompact ? 4 : 6),
                  Text(
                    subtitle,
                    maxLines: isUltraCompact ? 1 : isCompact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isUltraCompact ? 13 : null,
                      height: isCompact ? 1.3 : null,
                    ),
                  ),
                  if (!isCompact && tag != null) ...[
                    const SizedBox(height: 12),
                    StatusChip(label: tag!, color: color),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}