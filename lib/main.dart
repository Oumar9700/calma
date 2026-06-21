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
import 'firebase_options.dart';
import 'shared/blocs/theme/theme_bloc.dart';
import 'shared/blocs/theme/theme_event.dart';
import 'shared/blocs/theme/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupInjection();

  runApp(const CalmaApp());
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

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    _themeBloc = sl<ThemeBloc>()..add(const ThemeLoaded());
    router = buildRouter(_authBloc);
  }

  @override
  void dispose() {
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
