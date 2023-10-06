import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import 'dialogs/show_auth_error.dart';
import 'firebase_options.dart';
import 'loading/loading_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/reminders_provider.dart';
import 'state/app_state.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/reminders_views.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    Provider(
      create: (_) => AppState(
        authProvider: FirebaseAuthProvider(),
        remindersProvider: FirestoreRemindersProvider(),
      )..initialize(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: ReactionBuilder(
        builder: (context) {
          return autorun(
            (_) {
              // handle loading screen
              final isLoading = context.read<AppState>().isLoading;
              if (isLoading) {
                LoadingScreen.instance()
                    .show(context: context, text: 'Loading...');
              } else {
                LoadingScreen.instance().hide();
              }
              final authError = context.read<AppState>().authError;
              if (authError != null) {
                showAuthError(authError: authError, context: context);
              }
            },
          );
        },
        child: Observer(
          //! name for debugging
          name: 'CurrentScreen',
          builder: (context) {
            switch (context.read<AppState>().currentScreen) {
              case AppScreen.login:
                return const LoginView();
              case AppScreen.register:
                return const RegisterView();
              case AppScreen.reminders:
                return const RemindersViews();
            }
          },
        ),
      ),
    );
  }
}
