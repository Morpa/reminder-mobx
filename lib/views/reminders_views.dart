import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../dialogs/delete_reminder_dialog.dart';
import '../dialogs/show_textfield_dialog.dart';
import '../state/app_state.dart';
import 'main_popup_menu_button.dart';

class RemindersViews extends StatelessWidget {
  const RemindersViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            onPressed: () async {
              final reminderText = await showTextFieldDialog(
                context: context,
                title: 'What do you want me to remind you about?',
                hintText: 'Enter your reminder text here',
                optionsBuilder: () => {
                  TextFieldDialogButtonType.cancel: 'Cancel',
                  TextFieldDialogButtonType.confirm: 'Save',
                },
              );
              if (reminderText == null) {
                return;
              }
              context.read<AppState>().createReminder(reminderText);
            },
            icon: const Icon(Icons.add),
          ),
          const MainPopupMenuButton(),
        ],
      ),
      body: const RemindersListView(),
    );
  }
}

class RemindersListView extends StatelessWidget {
  const RemindersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Observer(
      builder: (context) {
        return ListView.builder(
          itemCount: appState.sortedReminders.length,
          itemBuilder: (context, index) {
            final reminder = appState.sortedReminders[index];
            return Observer(
              builder: (_) {
                return CheckboxListTile.adaptive(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: reminder.isDone,
                  onChanged: (isDone) {
                    appState.modifyReminder(
                      reminderId: reminder.id,
                      isDone: isDone ?? false,
                    );
                    reminder.isDone = isDone ?? false;
                  },
                  title: Row(
                    children: [
                      Expanded(child: Text(reminder.text)),
                      IconButton(
                        onPressed: () async {
                          final shouldDeleteReminder =
                              await showDeleteReminderDialog(context);
                          if (shouldDeleteReminder) {
                            context.read<AppState>().delete(reminder);
                          }
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
