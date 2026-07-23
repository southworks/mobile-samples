import 'package:flutter/material.dart';

import 'shared_example_views.dart';

class InputsMenuView extends StatelessWidget {
  const InputsMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return const InputsExampleView();
  }
}

class InputsExampleView extends StatefulWidget {
  const InputsExampleView({super.key});

  @override
  State<InputsExampleView> createState() => _InputsExampleViewState();
}

class _InputsExampleViewState extends State<InputsExampleView> {
  bool notificationsEnabled = false;
  String selectedColor = 'Blue';
  DateTime selectedDate = DateTime.now();
  double amount = 40;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final notesController = TextEditingController(
    text: 'Write a few lines here...',
  );

  final colors = const ['Blue', 'Green', 'Orange'];

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Inputs',
      children: [
        sectionTitle(context, 'Button + Alert'),
        Text(
          'This button triggers an alert.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        FilledButton(
          onPressed: _showAlert,
          child: const Text('Show Alert'),
        ),
        const Divider(),
        sectionTitle(context, 'Toggle + ConfirmationDialog'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Activate notifications'),
          value: notificationsEnabled,
          onChanged: (value) {
            setState(() => notificationsEnabled = value);
            if (value) {
              _showConfirmationDialog();
            }
          },
        ),
        Text(
          notificationsEnabled
              ? 'Notifications enabled'
              : 'Notifications disabled',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Divider(),
        sectionTitle(context, 'Picker + Sheet'),
        SegmentedButton<String>(
          segments: [
            for (final color in colors)
              ButtonSegment(value: color, label: Text(color)),
          ],
          selected: {selectedColor},
          onSelectionChanged: (selection) {
            setState(() => selectedColor = selection.first);
          },
        ),
        OutlinedButton(
          onPressed: _showSelectionSheet,
          child: const Text('Preview Selection'),
        ),
        const Divider(),
        sectionTitle(context, 'DatePicker + Popover'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Choose a date'),
          subtitle: Text(
            MaterialLocalizations.of(context).formatFullDate(selectedDate),
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickDate,
        ),
        OutlinedButton(
          onPressed: _showDatePopover,
          child: const Text('Show Selected Date'),
        ),
        const Divider(),
        sectionTitle(context, 'Slider'),
        Text('Brightness: ${amount.round()}%'),
        Slider(
          value: amount,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${amount.round()}%',
          onChanged: (value) => setState(() => amount = value),
        ),
        Container(
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.yellow.withValues(
              alpha: (amount / 100).clamp(0.15, 1.0),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Live preview',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const Divider(),
        sectionTitle(context, 'TextField'),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Enter your username',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        Text(
          usernameController.text.isEmpty
              ? 'No text entered'
              : 'Current text: ${usernameController.text}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Divider(),
        sectionTitle(context, 'SecureField + FullScreenCover'),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Enter a password',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        FilledButton(
          onPressed: _openFullScreen,
          child: const Text('Open Full Screen'),
        ),
        const Divider(),
        sectionTitle(context, 'TextEditor'),
        TextField(
          controller: notesController,
          maxLines: 8,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAlert() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Button tapped'),
          content: const Text('Alerts are useful for important feedback.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose a notification frequency',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Confirmation dialogs present a few related actions.',
                ),
              ),
              ListTile(
                title: const Text('Daily'),
                onTap: () => Navigator.of(sheetContext).pop('daily'),
              ),
              ListTile(
                title: const Text('Weekly'),
                onTap: () => Navigator.of(sheetContext).pop('weekly'),
              ),
              ListTile(
                title: const Text('Cancel'),
                onTap: () => Navigator.of(sheetContext).pop('cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (result == null || result == 'cancel') {
      setState(() => notificationsEnabled = false);
    }
  }

  Future<void> _showSelectionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.45,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Sheet'),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selected color',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedColor,
                    style: Theme.of(sheetContext).textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _showDatePopover() async {
    // Flutter has no built-in SwiftUI-style popover; approximate with a dialog.
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Date',
                style: Theme.of(dialogContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                MaterialLocalizations.of(dialogContext)
                    .formatFullDate(selectedDate),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _openFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (fullScreenContext) {
          return Scaffold(
            appBar: AppBar(title: const Text('Full Screen')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 60, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Secure content preview',
                    style: Theme.of(fullScreenContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Typed characters: ${passwordController.text.length}',
                    style: TextStyle(
                      color: Theme.of(fullScreenContext)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(fullScreenContext).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
