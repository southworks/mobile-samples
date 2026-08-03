import 'package:flutter/material.dart';

import '../canvas/canvas_painter.dart';
import '../canvas/canvas_primitives.dart';

class ShapesCanvasPage extends StatefulWidget {
  const ShapesCanvasPage({super.key});

  @override
  State<ShapesCanvasPage> createState() => _ShapesCanvasPageState();
}

class _ShapesCanvasPageState extends State<ShapesCanvasPage> {
  static const List<Color> _palette = <Color>[
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.brown,
  ];

  final List<CanvasShape> _shapes = <CanvasShape>[];
  CanvasShapeType _selectedShape = CanvasShapeType.rectangle;
  Color _selectedColor = _palette.first;

  void _addShape(Offset position) {
    setState(() {
      _shapes.add(
        CanvasShape(
          type: _selectedShape,
          center: position,
          size: const Size(140, 90),
          color: _selectedColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas con formas'),
        actions: [
          IconButton(
            tooltip: 'Limpiar formas',
            onPressed: _shapes.isEmpty
                ? null
                : () => setState(() {
                    _shapes.clear();
                  }),
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
              'Selecciona una forma y toca el lienzo para agregarla.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ShapeChip(
                  label: 'Rectangulo',
                  icon: Icons.rectangle_outlined,
                  selected: _selectedShape == CanvasShapeType.rectangle,
                  onTap: () => setState(() {
                    _selectedShape = CanvasShapeType.rectangle;
                  }),
                ),
                _ShapeChip(
                  label: 'Ovalo',
                  icon: Icons.circle_outlined,
                  selected: _selectedShape == CanvasShapeType.oval,
                  onTap: () => setState(() {
                    _selectedShape = CanvasShapeType.oval;
                  }),
                ),
                _ShapeChip(
                  label: 'Diamante',
                  icon: Icons.diamond_outlined,
                  selected: _selectedShape == CanvasShapeType.diamond,
                  onTap: () => setState(() {
                    _selectedShape = CanvasShapeType.diamond;
                  }),
                ),
                _ShapeChip(
                  label: 'Flecha',
                  icon: Icons.arrow_right_alt,
                  selected: _selectedShape == CanvasShapeType.arrow,
                  onTap: () => setState(() {
                    _selectedShape = CanvasShapeType.arrow;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            Text('Formas agregadas: ${_shapes.length}'),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) => _addShape(details.localPosition),
                  child: CustomPaint(
                    painter: CanvasScenePainter(
                      backgroundColor: theme.colorScheme.surfaceContainerLowest,
                      shapes: _shapes,
                    ),
                    child: const SizedBox.expand(),
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

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({
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
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
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
