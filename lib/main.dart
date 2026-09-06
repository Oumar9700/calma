import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'firebase_options.dart';
import 'shared/blocs/theme/theme_bloc.dart';
import 'shared/blocs/theme/theme_event.dart';
import 'shared/blocs/theme/theme_state.dart';
import 'shared/services/notification_service.dart';

void main() async {

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[BOOT] 1 - bindings ok');

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('[BOOT] 2 - orientation ok');

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('[BOOT] 3 - firebase ok');

    await setupInjection();
    debugPrint('[BOOT] 4 - injection ok');

    // Notifications : pas critique au démarrage, on lance sans bloquer
    sl<NotificationService>().initialize().catchError((e, s) {
      debugPrint('[NOTIF] init failed: $e');
    });
    debugPrint('[BOOT] 5 - notifications launched (async)');

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}');
      debugPrint('STACK: ${details.stack}');
    };

    debugPrint('[BOOT] 6 - calling runApp');
    runApp(const CalmaApp());
  }, (error, stack) {
    debugPrint('UNCAUGHT: $error');
    debugPrint(stack.toString());
  });
}

class CalmaApp extends StatefulWidget {
  const CalmaApp({super.key});

  @override
  State<CalmaApp> createState() => _CalmaAppState();
}

class _CalmaAppState extends State<CalmaApp> {
  late final AuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final GoRouter router;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    _themeBloc = sl<ThemeBloc>()..add(const ThemeLoaded());
    router = buildRouter(_authBloc);

    // Attache le router pour la navigation depuis les notifications
    sl<NotificationService>().attachRouter(router);

    // Sauvegarde / suppression du token FCM selon l'état d'auth
    String? _lastUid;
    _authSub = _authBloc.stream.listen((state) {
      if (state is Authenticated) {
        _lastUid = state.user.uid;
        sl<NotificationService>().saveToken(state.user.uid);
      } else if (state is Unauthenticated && _lastUid != null) {
        sl<NotificationService>().clearToken(_lastUid!);
        _lastUid = null;
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authBloc.close();
    _themeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'CALMA',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(primary: themeState.primaryColor),
                darkTheme: AppTheme.dark(primary: themeState.primaryColor),
                themeMode: themeState.mode,
                routerConfig: router,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('fr'),
                  Locale('en'),
                ],
                locale: const Locale('fr'),
              );
            },
          );
        },
      ),
    );
  }
}
