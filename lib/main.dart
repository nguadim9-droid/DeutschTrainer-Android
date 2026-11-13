import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/german_tts_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/dictation/view_models/dictation_view_model.dart';
import 'ui/features/library/views/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeutschTrainerApp());
}

class DeutschTrainerApp extends StatelessWidget {
  const DeutschTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GermanTtsService>(
          create: (_) => GermanTtsService(),
        ),
        ChangeNotifierProxyProvider<GermanTtsService, DictationViewModel>(
          create: (ctx) => DictationViewModel(
            ttsService: ctx.read<GermanTtsService>(),
          ),
          update: (ctx, tts, previous) =>
              previous ?? DictationViewModel(ttsService: tts),
        ),
      ],
      child: MaterialApp(
        title: 'DeutschTrainer Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LibraryScreen(),
      ),
    );
  }
}
