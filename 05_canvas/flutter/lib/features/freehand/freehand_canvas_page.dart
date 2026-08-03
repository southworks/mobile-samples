import 'package:flutter/material.dart';

import '../canvas/canvas_painter.dart';
import '../canvas/canvas_primitives.dart';

class FreehandCanvasPage extends StatefulWidget {
  const FreehandCanvasPage({super.key});

  @override
  State<FreehandCanvasPage> createState() => _FreehandCanvasPageState();
}

class _FreehandCanvasPageState extends State<FreehandCanvasPage> {
  static const Color _canvasColor = Colors.white;
  static const List<Color> _palette = <Color>[
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final List<Stroke> _strokes = <Stroke>[];
  Stroke? _activeStroke;
  DrawingTool _selectedTool = DrawingTool.pencil;
  Color _selectedColor = _palette.first;

  StrokeStyle get _currentStyle {
    switch (_selectedTool) {
      case DrawingTool.pencil:
        return StrokeStyle(color: _selectedColor, width: 3, opacity: 1);
      case DrawingTool.marker:
        return StrokeStyle(color: _selectedColor, width: 8, opacity: 0.85);
      case DrawingTool.highlighter:
        return StrokeStyle(color: _selectedColor, width: 18, opacity: 0.28);
      case DrawingTool.eraser:
        return const StrokeStyle(
          color: Colors.white,
          width: 20,
          opacity: 1,
          isEraser: true,
        );
      default:
        return StrokeStyle(color: _selectedColor, width: 3, opacity: 1);
    }
  }

  void _startStroke(Offset position) {
    setState(() {
      _activeStroke = Stroke(points: <Offset>[position], style: _currentStyle);
    });
  }

  void _appendPoint(Offset position) {
    final activeStroke = _activeStroke;
    if (activeStroke == null) {
      return;
    }

    setState(() {
      _activeStroke = activeStroke.copyWith(
        points: <Offset>[...activeStroke.points, position],
      );
    });
  }

  void _endStroke() {
    final activeStroke = _activeStroke;
    if (activeStroke == null) {
      return;
    }

    setState(() {
      _strokes.add(activeStroke);
      _activeStroke = null;
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _activeStroke = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPoints =
        _strokes.fold<int>(0, (sum, stroke) => sum + stroke.points.length) +
        (_activeStroke?.points.length ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas basico con dibujo libre'),
        actions: [
          IconButton(
            tooltip: 'Limpiar lienzo',
            onPressed: (_strokes.isEmpty && _activeStroke == null)
                ? null
                : _clearCanvas,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Herramientas de dibujo libre con lapiz, marcador, resaltador y borrador.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ToolChip(
                  label: 'Lapiz',
                  icon: Icons.edit_outlined,
                  selected: _selectedTool == DrawingTool.pencil,
                  onSelected: () => setState(() {
                    _selectedTool = DrawingTool.pencil;
                  }),
                ),
                _ToolChip(
                  label: 'Marcador',
                  icon: Icons.brush_outlined,
                  selected: _selectedTool == DrawingTool.marker,
                  onSelected: () => setState(() {
                    _selectedTool = DrawingTool.marker;
                  }),
                ),
                _ToolChip(
                  label: 'Resaltador',
                  icon: Icons.highlight_alt_outlined,
                  selected: _selectedTool == DrawingTool.highlighter,
                  onSelected: () => setState(() {
                    _selectedTool = DrawingTool.highlighter;
                  }),
                ),
                _ToolChip(
                  label: 'Borrador',
                  icon: Icons.auto_fix_off_outlined,
                  selected: _selectedTool == DrawingTool.eraser,
                  onSelected: () => setState(() {
                    _selectedTool = DrawingTool.eraser;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _palette.map((color) {
                return _ColorSwatch(
                  color: color,
                  selected: _selectedColor == color,
                  onTap: () => setState(() {
                    _selectedColor = color;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Trazos: ${_strokes.length + (_activeStroke == null ? 0 : 1)} | Puntos: $totalPoints',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) =>
                        _startStroke(details.localPosition),
                    onPanUpdate: (details) =>
                        _appendPoint(details.localPosition),
                    onPanEnd: (_) => _endStroke(),
                    onPanCancel: _endStroke,
                    child: CustomPaint(
                      painter: CanvasScenePainter(
                        backgroundColor: _canvasColor,
                        strokes: _strokes,
                        activeStroke: _activeStroke,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
