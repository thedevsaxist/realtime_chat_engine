import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';

/// Coordinates token refresh so concurrent 401s share one in-flight request.
class TokenRefreshService {
  final AuthSecureStorage _authSecureStorage;
  final Dio _refreshDio;

  Future<String?>? _inFlight;

  TokenRefreshService(this._authSecureStorage, this._refreshDio);

  Future<String?> refresh() {
    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _performRefresh();
    _inFlight = future;
    future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    return future;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _authSecureStorage.getRefreshToken();
    if (refreshToken == null) return null;

    debugPrint('[TokenRefreshService] calling /auth/refresh...');

    final response = await _refreshDio.post(
      "/auth/refresh",
      data: {"refreshToken": refreshToken},
    );

    final newToken = response.data["token"] as String;
    final newRefresh = response.data["refreshToken"] as String;
    await _authSecureStorage.saveToken(newToken, newRefresh);

    debugPrint('[TokenRefreshService] tokens refreshed');
    return newToken;
  }
}
