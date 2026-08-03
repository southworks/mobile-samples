import 'package:flutter/material.dart';

import '../canvas/canvas_painter.dart';
import '../canvas/canvas_primitives.dart';

class InfiniteCanvasPage extends StatefulWidget {
  const InfiniteCanvasPage({super.key});

  @override
  State<InfiniteCanvasPage> createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  static const Size _canvasSize = Size(3200, 3200);
  static const List<Color> _palette = <Color>[
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final List<Stroke> _strokes = <Stroke>[];
  final List<CanvasShape> _shapes = <CanvasShape>[];
  final List<CanvasTextItem> _textItems = <CanvasTextItem>[];
  final TransformationController _transformationController =
      TransformationController();
  Stroke? _activeStroke;
  DrawingTool _selectedTool = DrawingTool.move;
  Color _selectedColor = _palette.first;

  StrokeStyle get _strokeStyle {
    switch (_selectedTool) {
      case DrawingTool.pencil:
        return StrokeStyle(color: _selectedColor, width: 3, opacity: 1);
      case DrawingTool.marker:
        return StrokeStyle(color: _selectedColor, width: 8, opacity: 0.85);
      case DrawingTool.highlighter:
        return StrokeStyle(color: _selectedColor, width: 18, opacity: 0.28);
      default:
        return StrokeStyle(color: _selectedColor, width: 3, opacity: 1);
    }
  }

  void _handleTap(Offset position) {
    switch (_selectedTool) {
      case DrawingTool.rectangle:
        _addShape(CanvasShapeType.rectangle, position);
      case DrawingTool.oval:
        _addShape(CanvasShapeType.oval, position);
      case DrawingTool.diamond:
        _addShape(CanvasShapeType.diamond, position);
      case DrawingTool.arrow:
        _addShape(CanvasShapeType.arrow, position);
      case DrawingTool.text:
        _addText(position);
      default:
        break;
    }
  }

  void _addShape(CanvasShapeType type, Offset position) {
    setState(() {
      _shapes.add(
        CanvasShape(
          type: type,
          center: position,
          size: const Size(180, 120),
          color: _selectedColor,
        ),
      );
    });
  }

  Future<void> _addText(Offset position) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar texto'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Texto',
              hintText: 'Escribe una etiqueta',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );

    if (!mounted || text == null || text.isEmpty) {
      return;
    }

    setState(() {
      _textItems.add(
        CanvasTextItem(text: text, position: position, color: _selectedColor),
      );
    });
  }

  void _startStroke(Offset position) {
    if (!_isDrawingTool(_selectedTool)) {
      return;
    }

    setState(() {
      _activeStroke = Stroke(points: <Offset>[position], style: _strokeStyle);
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

  bool _isDrawingTool(DrawingTool tool) {
    return tool == DrawingTool.pencil ||
        tool == DrawingTool.marker ||
        tool == DrawingTool.highlighter;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewportLabel = _transformationController.value.isIdentity()
        ? 'x1.0'
        : 'x${_transformationController.value.getMaxScaleOnAxis().toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas gigante'),
        actions: [
          IconButton(
            tooltip: 'Limpiar todo',
            onPressed: () => setState(() {
              _strokes.clear();
              _shapes.clear();
              _textItems.clear();
              _activeStroke = null;
            }),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Usa Mover para pan y zoom. Este ejemplo usa InteractiveViewer.builder para construir el contenido del viewport.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolChip(
                    label: 'Mover',
                    icon: Icons.open_with,
                    selected: _selectedTool == DrawingTool.move,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.move;
                    }),
                  ),
                  _ToolChip(
                    label: 'Lapiz',
                    icon: Icons.edit_outlined,
                    selected: _selectedTool == DrawingTool.pencil,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.pencil;
                    }),
                  ),
                  _ToolChip(
                    label: 'Marcador',
                    icon: Icons.brush_outlined,
                    selected: _selectedTool == DrawingTool.marker,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.marker;
                    }),
                  ),
                  _ToolChip(
                    label: 'Resaltador',
                    icon: Icons.highlight_alt_outlined,
                    selected: _selectedTool == DrawingTool.highlighter,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.highlighter;
                    }),
                  ),
                  _ToolChip(
                    label: 'Rect',
                    icon: Icons.rectangle_outlined,
                    selected: _selectedTool == DrawingTool.rectangle,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.rectangle;
                    }),
                  ),
                  _ToolChip(
                    label: 'Ovalo',
                    icon: Icons.circle_outlined,
                    selected: _selectedTool == DrawingTool.oval,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.oval;
                    }),
                  ),
                  _ToolChip(
                    label: 'Diamante',
                    icon: Icons.diamond_outlined,
                    selected: _selectedTool == DrawingTool.diamond,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.diamond;
                    }),
                  ),
                  _ToolChip(
                    label: 'Flecha',
                    icon: Icons.arrow_right_alt,
                    selected: _selectedTool == DrawingTool.arrow,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.arrow;
                    }),
                  ),
                  _ToolChip(
                    label: 'Texto',
                    icon: Icons.text_fields,
                    selected: _selectedTool == DrawingTool.text,
                    onTap: () => setState(() {
                      _selectedTool = DrawingTool.text;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
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
            const SizedBox(height: 10),
            Text(
              'Escala: $viewportLabel | Trazos: ${_strokes.length} | Formas: ${_shapes.length} | Textos: ${_textItems.length}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer.builder(
                    builder: (context, viewport) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: _selectedTool == DrawingTool.move
                            ? null
                            : (details) => _handleTap(details.localPosition),
                        onPanStart: _selectedTool == DrawingTool.move
                            ? null
                            : (details) => _startStroke(details.localPosition),
                        onPanUpdate: _selectedTool == DrawingTool.move
                            ? null
                            : (details) => _appendPoint(details.localPosition),
                        onPanEnd: _selectedTool == DrawingTool.move
                            ? null
                            : (_) => _endStroke(),
                        onPanCancel: _selectedTool == DrawingTool.move
                            ? null
                            : _endStroke,
                        child: CustomPaint(
                          painter: CanvasScenePainter(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerLowest,
                            strokes: _strokes,
                            activeStroke: _activeStroke,
                            shapes: _shapes,
                            textItems: _textItems,
                            showGrid: true,
                          ),
                          child: SizedBox(
                            width: _canvasSize.width,
                            height: _canvasSize.height,
                          ),
                        ),
                      );
                    },
                    transformationController: _transformationController,
                    minScale: 0.2,
                    maxScale: 4,
                    panEnabled: _selectedTool == DrawingTool.move,
                    scaleEnabled: _selectedTool == DrawingTool.move,
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
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
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
