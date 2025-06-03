import 'package:get/get.dart';
import '../../data/remote/firebase_service.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../repositories/task_repository.dart';
import '../../data/local/database_service.dart';
import '../../presentation/controllers/task_controller.dart';
import '../../presentation/controllers/theme_controller.dart';
import 'notification_service.dart';

class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.putAsync<DatabaseService>(() => DatabaseService().init());
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.putAsync<FirebaseService>(() => FirebaseService().init());

    // Auth Controller (for getting userId)
    Get.lazyPut<AuthController>(
      () => AuthController(firebaseService: Get.find<FirebaseService>()),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<TaskRepository>(
      () => TaskRepository(
        databaseService: Get.find<DatabaseService>(),
        userId: Get.find<AuthController>().currentUser?.uid ?? 'offline',
      ),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<TaskController>(
      () => TaskController(
        taskRepository: Get.find<TaskRepository>(),
        notificationService: Get.find<NotificationService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ThemeController>(
      () => ThemeController(),
      fenix: true,
    );
  }
}
