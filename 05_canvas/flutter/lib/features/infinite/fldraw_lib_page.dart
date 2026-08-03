import 'package:fldraw/fldraw.dart';
import 'package:flutter/material.dart';

class FldrawLibPage extends StatefulWidget {
  const FldrawLibPage({super.key});

  @override
  State<FldrawLibPage> createState() => _FldrawLibPageState();
}

class _FldrawLibPageState extends State<FldrawLibPage> {
  FlDrawController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('fldraw lib'),
        actions: [
          IconButton(
            tooltip: 'Seleccion',
            onPressed: _controller == null
                ? null
                : () => _controller!.setTool(EditorTool.arrow),
            icon: const Icon(Icons.ads_click_outlined),
          ),
          IconButton(
            tooltip: 'Rectangulo',
            onPressed: _controller == null
                ? null
                : () => _controller!.setTool(EditorTool.square),
            icon: const Icon(Icons.rectangle_outlined),
          ),
          IconButton(
            tooltip: 'Lapiz',
            onPressed: _controller == null
                ? null
                : () => _controller!.setTool(EditorTool.pencil),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Texto',
            onPressed: _controller == null
                ? null
                : () => _controller!.setTool(EditorTool.text),
            icon: const Icon(Icons.text_fields),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Ejemplo usando fldraw. Incluye canvas infinito, toolbar integrada y herramientas de dibujo/diagramacion.',
            ),
          ),
          Expanded(
            child: FlDraw(
              onControllerCreated: (controller) {
                setState(() {
                  _controller = controller;
                });
              },
              child: Stack(
                alignment: Alignment.topCenter,
                children: const [
                  FlDrawCanvas(debug: false),
                  Positioned(
                    top: 16,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: FlToolbar(svgs: []),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
