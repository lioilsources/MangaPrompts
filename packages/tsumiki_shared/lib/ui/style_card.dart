import 'package:flutter/material.dart';

/// One style to pick: a bundled preview over its name. The previews are the
/// bench's own output on one synthetic face, so a row compares the style and
/// nothing else; a style without a picture keeps its name over a plain tile.
class StyleCard extends StatelessWidget {
  const StyleCard({
    super.key,
    required this.label,
    required this.preview,
    required this.selected,
    required this.onTap,
    this.fallbackIcon = Icons.face,
    this.width = 96,
  });

  final String label;

  /// Asset path (`Hairstyle.preview`, `Glasses.preview`, `Beard.previewPath`).
  final String preview;
  final bool selected;
  final VoidCallback? onTap;
  final IconData fallbackIcon;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.asset(
                  preview,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(fallbackIcon, color: scheme.primary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? scheme.primary : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
