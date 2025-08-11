import '../repositories/profile_repository.dart';
import '../business/profile_browse_bloc.dart';

/// Simple dependency injection container
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  /// Register a service
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Register a factory function
  void registerFactory<T>(T Function() factory) {
    _services[T] = factory;
  }

  /// Get a service
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    
    // If it's a factory function, call it
    if (service is Function) {
      return service() as T;
    }
    
    return service as T;
  }

  /// Check if a service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Reset all services (useful for testing)
  void reset() {
    _services.clear();
  }
}

/// Global service locator instance
final serviceLocator = ServiceLocator();

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Register repositories
  serviceLocator.register<ProfileRepository>(ProfileRepositoryImpl());

  // Register BLoC factory
  serviceLocator.registerFactory<ProfileBrowseBloc>(
    () => ProfileBrowseBloc(
      repository: serviceLocator.get<ProfileRepository>(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  serviceLocator.reset();
} 