import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/api/venue_service.dart' as venueService;
import '/api/event_service.dart' as eventService;
import '/api/auth_service.dart' as authService;

import 'models/api_model.dart';
import 'models/event_model.dart';
import 'models/auth_model.dart';
import 'models/venue_model.dart';

class SecureStorage {
    final storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
            // enforceBiometrics: true, 
            // biometricPromptTitle: 'Autenticação Requerida',
        ),
    );

    SecureStorage(); 
    
    void writeRefreshToken(RefreshToken token) async => await storage.write(key: 'refreshToken', value: token);
    Future<RefreshToken?> readRefreshToken() async => await storage.read(key: 'refreshToken');
    void clear() async => await storage.deleteAll(); 
}

class AppState {
    final SecureStorage secureStorage = SecureStorage();

    late AccessToken? accessToken; 
    late RefreshToken? refreshToken;
    
    ValueListenable<bool> get isLoggedIn => _isLoggedIn;
    late ValueNotifier<bool> _isLoggedIn;

    AppState() {
        _loadSecureStore();
        _isLoggedIn = ValueNotifier(false);
    }
    
    void _loadSecureStore() async {
        refreshToken = await secureStorage.readRefreshToken(); 
    }
    
    void _updateAuthInfo(AuthInfo info) {
        accessToken = info.accessToken!;
        refreshToken = info.refreshToken!;
        secureStorage.writeRefreshToken(info.refreshToken!);
    }

    void deleteAuthInfo() async => secureStorage.clear();

    ApiRequest<AuthInfo> _requestAuthInfo() async {
        final refreshToken = await secureStorage.readRefreshToken();

        final request = await authService.requestAuthInfo(refreshToken!);
        if (request.isError) {
            if (request.error == ApiError.invalidSession) _isLoggedIn.value = false;
            return request;
        }

        return Result.ok(request.data!);
    }

    ApiRequest<T> _withAccessToken<T>(ApiRequest<T> Function(AccessToken accessToken) func, {bool retry = true}) async {
        final result = await func(accessToken!);
        if (result.error != ApiError.expiredAccessToken || !retry) return result;

        final request = await _requestAuthInfo();
        if (request.isError) return Result.error(request.error!);
        _updateAuthInfo(request.data!);

        return func(accessToken!);
    }

    ApiRequest<void> rememberMe() async {
        if (refreshToken != null) {
            final result = await authService.requestAuthInfo(refreshToken!);
            if (result.isError) return Result.error(result.error!);

            _isLoggedIn.value = true;
        
            _updateAuthInfo(result.data!);
            return Result.ok(());
        }

        return Result.error(ApiError.invalidSession);
    }

    ApiRequest<void> login(LoginRequest request) async {
        final result = await authService.login(request);
        if (result.isError) return result; 
        
        _isLoggedIn.value = true;

        _updateAuthInfo(result.data!);
        return Result.ok(());
    }

    ApiRequest<void> register(SignUpRequest request) async {
        final result = await authService.register(request);
        if (result.isError) return result;
        
        _isLoggedIn.value = true;

        _updateAuthInfo(result.data!);
        return Result.ok(());
    }

    ApiRequest<List<Venue>> fetchVenues() async {
        return _withAccessToken((accessToken) => venueService.fetchVenues(accessToken));
    }

    ApiRequest<Venue> createVenue(Venue venue) async {
        return _withAccessToken((accessToken) => venueService.createVenue(venue, accessToken));
    }

    ApiRequest<Venue> updateVenue(String id, Venue venue) async {
        return _withAccessToken((accessToken) => venueService.updateVenue(id, venue, accessToken));
    }

    ApiRequest<void> deleteVenue(String id) async{
        return _withAccessToken((accessToken) => venueService.deleteVenue(id, accessToken));
    }

    ApiRequest<List<Event>> fetchMyEvents() async {
        return _withAccessToken((accessToken) => eventService.fetchMyEvents(accessToken));
    }

    ApiRequest<Event> fetchEvent(String id) async {
        return _withAccessToken((accessToken) => eventService.fetchEvent(id, accessToken));
    }

    ApiRequest<Event> createEvent(Event event) async {
        return _withAccessToken((accessToken) => eventService.createEvent(event, accessToken));
    }

    ApiRequest<Event> updateEvent(String id, Event event) async {
        return _withAccessToken((accessToken) => eventService.updateEvent(id, event, accessToken));
    }

    ApiRequest<Event> cancelEvent(String id) async {
        return _withAccessToken((accessToken) => eventService.cancelEvent(id, accessToken));
    }

    ApiRequest<Event> suspendEvent(String id) async {
        return _withAccessToken((accessToken) => eventService.suspendEvent(id, accessToken));
    }

    ApiRequest<Event> reactivateEvent(String id) async {
        return _withAccessToken((accessToken) => eventService.reactivateEvent(id, accessToken));
    }
}
