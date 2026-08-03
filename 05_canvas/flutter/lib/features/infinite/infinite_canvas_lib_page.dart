import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

class InfiniteCanvasLibPage extends StatefulWidget {
  const InfiniteCanvasLibPage({super.key});

  @override
  State<InfiniteCanvasLibPage> createState() => _InfiniteCanvasLibPageState();
}

class _InfiniteCanvasLibPageState extends State<InfiniteCanvasLibPage> {
  late final InfiniteCanvasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InfiniteCanvasController()
      ..add(
        InfiniteCanvasNode(
          key: const ValueKey('start'),
          size: const Size(180, 80),
          offset: const Offset(80, 80),
          child: const _NodeCard(
            title: 'Inicio',
            subtitle: 'Nodo movible',
            color: Colors.green,
          ),
        ),
      )
      ..add(
        InfiniteCanvasNode(
          key: const ValueKey('decision'),
          size: const Size(220, 110),
          offset: const Offset(360, 240),
          child: const _NodeCard(
            title: 'Decision',
            subtitle: 'Puedes arrastrar y seleccionar',
            color: Colors.orange,
          ),
        ),
      )
      ..add(
        InfiniteCanvasNode(
          key: const ValueKey('end'),
          size: const Size(180, 80),
          offset: const Offset(720, 100),
          child: const _NodeCard(
            title: 'Fin',
            subtitle: 'Canvas basado en libreria',
            color: Colors.indigo,
          ),
        ),
      )
      ..addLink(const ValueKey('start'), const ValueKey('decision'))
      ..addLink(const ValueKey('decision'), const ValueKey('end'));
  }

  @override
  void dispose() {
    _controller.transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite canvas lib'),
        actions: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: _controller.zoomIn,
            icon: const Icon(Icons.zoom_in),
          ),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: _controller.zoomOut,
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: _controller.zoomReset,
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Ejemplo con la libreria infinite_canvas. Los nodos se pueden seleccionar, mover y conectar visualmente.',
            ),
          ),
          Expanded(
            child: InfiniteCanvas(
              controller: _controller,
              drawVisibleOnly: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
