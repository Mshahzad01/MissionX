import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/task_creation_screen.dart';
import '../screens/task_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/statistics_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.TASK_CREATION,
      page: () => const TaskCreationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.TASK_DETAIL,
      page: () => const TaskDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.STATISTICS,
      page: () => const StatisticsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
} 