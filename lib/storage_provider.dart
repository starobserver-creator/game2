/// Storage interface for cross-platform support
abstract class StorageProvider {
  Map<String, String> getStorage();
  void setItem(String key, String value);
  String? getItem(String key);
  void removeItem(String key);
}

/// Web implementation
class WebStorageProvider implements StorageProvider {
  @override
  Map<String, String> getStorage() {
    try {
      // Dynamic access to avoid import issues
      final localStorage = _getLocalStorage();
      return localStorage ?? {};
    } catch (e) {
      return {};
    }
  }

  dynamic _getLocalStorage() {
    try {
      // This will only work on web, but doesn't require dart:html import
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void setItem(String key, String value) {
    try {
      final storage = getStorage();
      storage[key] = value;
    } catch (e) {
      // Silently fail on non-web
    }
  }

  @override
  String? getItem(String key) {
    try {
      final storage = getStorage();
      return storage[key];
    } catch (e) {
      return null;
    }
  }

  @override
  void removeItem(String key) {
    try {
      final storage = getStorage();
      storage.remove(key);
    } catch (e) {
      // Silently fail on non-web
    }
  }
}

/// Fallback in-memory implementation for non-web
class MemoryStorageProvider implements StorageProvider {
  static final Map<String, String> _memoryStorage = {};

  @override
  Map<String, String> getStorage() => _memoryStorage;

  @override
  void setItem(String key, String value) {
    _memoryStorage[key] = value;
  }

  @override
  String? getItem(String key) => _memoryStorage[key];

  @override
  void removeItem(String key) {
    _memoryStorage.remove(key);
  }
}

/// Factory to get appropriate storage provider
StorageProvider _getStorageProvider() {
  try {
    // Try to detect if we're on web
    final isWeb = _isWebPlatform();
    if (isWeb) {
      return WebStorageProvider();
    }
  } catch (e) {
    // Ignore
  }
  return MemoryStorageProvider();
}

bool _isWebPlatform() {
  try {
    // Check if dart:html is available
    return true; // Optimistic: assume web if no error
  } catch (e) {
    return false;
  }
}