import 'package:flutter/material.dart';

import '../freehand/freehand_canvas_page.dart';
import '../hosted_excalidraw/hosted_excalidraw_page.dart';
import '../infinite/fldraw_lib_page.dart';
import '../infinite/infinite_canvas_lib_page.dart';
import '../infinite/infinite_canvas_page.dart';
import '../shapes/shapes_canvas_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<_CanvasExampleItem> _examples = [
    _CanvasExampleItem(
      title: 'Canvas basico con dibujo libre',
      description:
          'Trazos a mano alzada con lapiz, marcador, resaltador y colores.',
      icon: Icons.draw_outlined,
      builder: (_) => const FreehandCanvasPage(),
    ),
    _CanvasExampleItem(
      title: 'Canvas con formas y diagramas',
      description: 'Rectangulos, ovalos, diamantes y flechas sobre el lienzo.',
      icon: Icons.account_tree_outlined,
      builder: (_) => const ShapesCanvasPage(),
    ),
    _CanvasExampleItem(
      title: 'Canvas infinito',
      description:
          'Lienzo grande con pan y zoom usando InteractiveViewer.builder.',
      icon: Icons.open_with_outlined,
      builder: (_) => const InfiniteCanvasPage(),
    ),
    _CanvasExampleItem(
      title: 'Infinite canvas lib',
      description:
          'Ejemplo separado usando la libreria infinite_canvas para nodos movibles.',
      icon: Icons.hub_outlined,
      builder: (_) => const InfiniteCanvasLibPage(),
    ),
    _CanvasExampleItem(
      title: 'Hosted Excalidraw',
      description:
          'Embebe tu sitio self-hosted de Excalidraw dentro de un webview nativo.',
      icon: Icons.language_outlined,
      builder: (_) => const HostedExcalidrawPage(),
    ),
    _CanvasExampleItem(
      title: 'fldraw lib',
      description:
          'Canvas infinito montado sobre fldraw con toolbar y herramientas propias.',
      icon: Icons.space_dashboard_outlined,
      builder: (_) => const FldrawLibPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplos de Canvas')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final example = _examples[index];
          return Card(
            child: ListTile(
              leading: Icon(example.icon),
              title: Text(example.title),
              subtitle: Text(example.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: example.builder));
              },
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: _examples.length,
      ),
    );
  }
}

class _CanvasExampleItem {
  const _CanvasExampleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}
