import 'package:flutter/material.dart';

import '../../utils/design_system.dart';

/// Texto expandible para publicaciones y reportes del feed de Yago.
///
/// Limita la visualización inicial a [maxLines] líneas (por defecto 4) tanto
/// en publicaciones con foto como sin foto, mostrando el botón interactivo
/// "Ver más" / "Ver menos" únicamente cuando el contenido supera dicho límite.
class YagoExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const YagoExpandableText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 4,
  });

  @override
  State<YagoExpandableText> createState() => _YagoExpandableTextState();
}

class _YagoExpandableTextState extends State<YagoExpandableText> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(covariant YagoExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _isExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ??
        const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.5,
          height: 1.35,
          color: AppColors.textPrimary,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: effectiveStyle),
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(
            maxWidth: constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width,
          );

        final exceedsMaxLines = textPainter.didExceedMaxLines;

        if (!exceedsMaxLines) {
          return Text(
            widget.text,
            style: effectiveStyle,
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: effectiveStyle,
                maxLines: _isExpanded ? null : widget.maxLines,
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                _isExpanded ? 'Ver menos' : 'Ver más',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: effectiveStyle.fontSize != null
                      ? effectiveStyle.fontSize! - 0.5
                      : 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
