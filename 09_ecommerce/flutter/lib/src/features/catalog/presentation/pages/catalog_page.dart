import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/catalog_controller.dart';
import '../widgets/product_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required CatalogController controller})
    : _controller = controller;

  final CatalogController _controller;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? _lastPresentedError;

  CatalogController get _controller => widget._controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._controller == widget._controller) {
      return;
    }

    oldWidget._controller.removeListener(_handleControllerChanged);
    widget._controller.addListener(_handleControllerChanged);
    _lastPresentedError = null;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (_controller.status != CatalogStatus.failure) {
      return;
    }

    final errorMessage = _controller.errorMessage ?? 'Unknown error.';

    if (_lastPresentedError == errorMessage || !mounted) {
      return;
    }

    _lastPresentedError = errorMessage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      showDialog<void>(
        context: context,
        builder: (context) => _ErrorDialog(message: errorMessage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shopify Catalog'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBody(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_controller.status) {
      case CatalogStatus.initial:
      case CatalogStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CatalogStatus.configMissing:
        return _InfoState(
          title: 'Missing Shopify configuration',
          message:
              'Run the app or build it with SHOPIFY_SHOP_DOMAIN and '
              'SHOPIFY_STOREFRONT_ACCESS_TOKEN.',
          details: _controller.missingConfigKeys.join(', '),
        );
      case CatalogStatus.failure:
        return _InfoState(
          title: 'Could not load products',
          message: _controller.errorMessage ?? 'Unknown error.',
          actionLabel: 'Retry',
          onAction: _controller.loadCatalog,
        );
      case CatalogStatus.loaded:
        if (_controller.products.isEmpty) {
          return const _InfoState(
            title: 'No products found',
            message: 'The store is reachable, but the catalog is empty.',
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.loadCatalog,
          child: ListView.separated(
            itemCount: _controller.products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ProductCard(product: _controller.products[index]);
            },
          ),
        );
    }
  }
}

class _ErrorDialog extends StatelessWidget {
  const _ErrorDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Integration Error'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: SingleChildScrollView(child: SelectableText(message)),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: message));

            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error copied to clipboard')),
            );
          },
          child: const Text('Copy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.title,
    required this.message,
    this.details,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? details;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(message, style: textTheme.bodyLarge),
                if (details != null) ...[
                  const SizedBox(height: 12),
                  Text(details!, style: textTheme.bodyMedium),
                ],
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 20),
                  FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
