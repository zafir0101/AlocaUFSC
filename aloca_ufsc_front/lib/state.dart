import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api/venue_service.dart' as venueService;
import 'api/event_service.dart' as eventService;
import 'api/auth_service.dart' as authService;
import 'api/notification_service.dart' as notificationService;

import 'models/api_model.dart';
import 'models/event_model.dart';
import 'models/auth_model.dart';
import 'models/venue_model.dart';
import 'models/notification_model.dart';


typedef AccessToken = String;
typedef RefreshToken = String;

class SecureStorage {
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // enforceBiometrics: true, 
      // biometricPromptTitle: 'Autenticação Requerida',
    ),
  );

  SecureStorage(); 
  
  Future<void> writeRefreshToken(RefreshToken token) async => await storage.write(key: 'refreshToken', value: token);
  Future<RefreshToken?> readRefreshToken() async => await storage.read(key: 'refreshToken');
  Future<void> clear() async => await storage.deleteAll(); 
}

class AppState {
  final SecureStorage secureStorage = SecureStorage();

  AccessToken? accessToken; 
  RefreshToken? refreshToken;
  
  String? userRole;
  bool get isAdmin => userRole == 'MANAGER';

  ValueListenable<bool> get isLoggedIn => _isLoggedIn;
  late ValueNotifier<bool> _isLoggedIn;

  AppState() {
    _isLoggedIn = ValueNotifier(false);
  }
  
  void _updateAuthInfo(AuthInfo info) {
    accessToken = info.accessToken;
    refreshToken = info.refreshToken;
    userRole = info.entity; 
    
    if (info.refreshToken != null) {
      secureStorage.writeRefreshToken(info.refreshToken!);
    }
  }

  void logout() async {
    accessToken = null;
    refreshToken = null;
    userRole = null;
    await secureStorage.clear();
    _isLoggedIn.value = false;
  }

  ApiRequest<AuthInfo> _requestAuthInfo() async {
    final token = await secureStorage.readRefreshToken();
    if (token == null) return Result.error(ApiError.invalidSession);

    final request = await authService.refreshToken(token);
    if (request.isError) {
      if (request.error == ApiError.invalidSession) _isLoggedIn.value = false;
      return request;
    }

    return Result.ok(request.data!);
  }

  ApiRequest<T> _withAccessToken<T>(ApiRequest<T> Function(AccessToken accessToken) func, {bool retry = true}) async {
    if (accessToken == null) {
      final req = await _requestAuthInfo();
      if (req.isError) return Result.error(req.error!);
      _updateAuthInfo(req.data!);
    }

    final result = await func(accessToken!);
    
    if (result.error == ApiError.expiredAccessToken && retry) {
      final request = await _requestAuthInfo();
      if (request.isError) return Result.error(request.error!);
      
      _updateAuthInfo(request.data!);
      return func(accessToken!);
    }

    return result;
  }

  ApiRequest<void> rememberMe() async {
    refreshToken = await secureStorage.readRefreshToken();
    
    if (refreshToken != null) {
      final result = await authService.refreshToken(refreshToken!);
      if (result.isError) return Result.error(result.error!);

      _updateAuthInfo(result.data!);
      _isLoggedIn.value = true;
      return Result.ok(null);
    }

    return Result.error(ApiError.invalidSession);
  }

  ApiRequest<void> login(LoginRequest request) async {
    final result = await authService.login(request);
    if (result.isError) return result; 
    
    _updateAuthInfo(result.data!);
    _isLoggedIn.value = true;
    return Result.ok(null);
  }

  ApiRequest<void> register(SignUpRequest request) async {
    final result = await authService.register(request);
    if (result.isError) return result;
    
    _updateAuthInfo(result.data!);
    _isLoggedIn.value = true;
    return Result.ok(null);
  }

  ApiRequest<List<Venue>> fetchVenues() async {
    return _withAccessToken((accessToken) => venueService.fetchVenues(accessToken));
  }

  ApiRequest<List<CampusCenter>> fetchCampus() async {
    return _withAccessToken((accessToken) => venueService.fetchCampus(accessToken));
  }

  ApiRequest<Venue> createVenue(Venue venue) async {
    return _withAccessToken((accessToken) => venueService.createVenue(venue, accessToken));
  }

  ApiRequest<Venue> updateVenue(String id, Venue venue) async {
    return _withAccessToken((accessToken) => venueService.updateVenue(id, venue, accessToken));
  }

  ApiRequest<void> deleteVenue(String id) async {
    return _withAccessToken((accessToken) => venueService.deleteVenue(id, accessToken));
  }

  ApiRequest<List<Event>> fetchMyEvents() async {
    return _withAccessToken((accessToken) => eventService.fetchMyEvents(accessToken));
  }

  ApiRequest<Event> fetchEvent(int id) async {
    return _withAccessToken((accessToken) => eventService.fetchEvent(id, accessToken));
  }

  ApiRequest<Event> createEvent(Event event) async {
    return _withAccessToken((accessToken) => eventService.createEvent(event, accessToken));
  }

  ApiRequest<Event> updateEvent(int id, Event event) async {
    return _withAccessToken((accessToken) => eventService.updateEvent(id, event, accessToken));
  }

  ApiRequest<Event> cancelEvent(int id) async {
    return _withAccessToken((accessToken) => eventService.cancelEvent(id, accessToken));
  }

  ApiRequest<Event> suspendEvent(int id) async {
    return _withAccessToken((accessToken) => eventService.suspendEvent(id, accessToken));
  }

  ApiRequest<Event> reactivateEvent(int id) async {
    return _withAccessToken((accessToken) => eventService.reactivateEvent(id, accessToken));
  }

  ApiRequest<int> fetchUnreadCount() async {
    return _withAccessToken((accessToken) => notificationService.fetchUnreadCount(accessToken));
  }

  ApiRequest<List<AppNotification>> fetchNotifications() async {
    return _withAccessToken((accessToken) => notificationService.fetchNotifications(accessToken));
  }

  ApiRequest<void> markNotificationAsRead(int id) async {
    return _withAccessToken((accessToken) => notificationService.markAsRead(id, accessToken));
  }

  ApiRequest<void> markAllNotificationsAsRead() async {
    return _withAccessToken((accessToken) => notificationService.markAllAsRead(accessToken));
  }

  ApiRequest<void> deleteNotification(int id) async {
    return _withAccessToken((accessToken) => notificationService.delete(id, accessToken));
  }

  ApiRequest<void> deleteReadNotifications() async {
    return _withAccessToken((accessToken) => notificationService.deleteRead(accessToken));
  }
}
