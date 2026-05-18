import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stopwatch_game/core/config/api_config.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => const {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  String channelSourceForPlatform() {
    if (kIsWeb) return 'WEB';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ANDROID';
      case TargetPlatform.iOS:
        return 'IOS';
      default:
        return 'DESKTOP';
    }
  }

  Future<void> requestOtp({required String msisdn}) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.otpRequest),
      headers: _headers,
      body: jsonEncode({'msisdn': msisdn}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw AuthApiException(
      _messageFromBody(response.body) ?? 'Could not send verification code.',
      statusCode: response.statusCode,
    );
  }

  static String usernameFromMsisdn(String msisdn) => msisdn;

  Future<UserModel> verifyOtpAndRegister({
    required String msisdn,
    required String otp,
    required String channelSource,
  }) async {
    final username = usernameFromMsisdn(msisdn);
    final verifyResponse = await _client.post(
      Uri.parse(ApiConfig.otpVerify),
      headers: _headers,
      body: jsonEncode({'msisdn': msisdn, 'otp': otp}),
    );

    if (verifyResponse.statusCode >= 200 && verifyResponse.statusCode < 300) {
      return registerUser(
        msisdn: msisdn,
        username: username,
        channelSource: channelSource,
      );
    }

    if (verifyResponse.statusCode != 404) {
      throw AuthApiException(
        _messageFromBody(verifyResponse.body) ?? 'Invalid verification code.',
        statusCode: verifyResponse.statusCode,
      );
    }

    return registerUser(
      msisdn: msisdn,
      username: username,
      channelSource: channelSource,
      otp: otp,
    );
  }

  Future<UserModel> registerUser({
    required String msisdn,
    required String username,
    required String channelSource,
    String? otp,
  }) async {
    final body = <String, dynamic>{
      'msisdn': msisdn,
      'username': username,
      'channelSource': channelSource,
    };
    if (otp != null) body['otp'] = otp;

    final response = await _client.post(
      Uri.parse(ApiConfig.users),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    }

    throw AuthApiException(
      _messageFromBody(response.body) ?? 'Registration failed.',
      statusCode: response.statusCode,
    );
  }

  String? _messageFromBody(String body) {
    if (body.isEmpty) return null;
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        if (error is Map && error['message'] is String) {
          return error['message'] as String;
        }
        if (json['message'] is String) return json['message'] as String;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
