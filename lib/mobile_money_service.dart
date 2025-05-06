import 'dart:convert';
import 'dart:math' as Math;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MobileMoneyService {
  static const _baseUrl = 'https://sandbox.momodeveloper.mtn.com';
  static const _tokenEndpoint = '/collection/token/';
  static const _requestToPay = '/collection/v1_0/requesttopay';

  final String subscriptionKey;
  final String apiUserId;
  final String apiKey;
  String? _accessToken;

  MobileMoneyService({
    required this.subscriptionKey,
    required this.apiUserId,
    required this.apiKey,
  });

  Future<bool> authenticate() async {
    final uri = Uri.parse('$_baseUrl$_tokenEndpoint');
    final creds = base64Encode(utf8.encode('$apiUserId:$apiKey'));

    try {
      // Print debug information
      print('Authenticating with API user ID: $apiUserId');
      print('Using subscription key: $subscriptionKey');
      
      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Basic $creds',
          'Ocp-Apim-Subscription-Key': subscriptionKey,
        },
      );

      print('Authentication response: ${resp.statusCode}');
      
      if (resp.statusCode == 200) {
        final responseBody = jsonDecode(resp.body);
        _accessToken = responseBody['access_token'] as String?;
        print('Access token obtained: ${_accessToken != null ? "Yes" : "No"}');
        if (_accessToken != null) {
          print('Token starts with: ${_accessToken!.substring(0, Math.min(10, _accessToken!.length))}...');
        }
        return _accessToken != null;
      }

      print('Auth failed: ${resp.statusCode} - ${resp.body}');
      return false;
    } catch (e) {
      print('Auth exception: $e');
      return false;
    }
  }

  Future<String?> initPayment({
    required String phoneNumber,
    required double amount,
    required String currency,
    required String description,
  }) async {
    if (_accessToken == null && !await authenticate()) {
      print('Authentication failed');
      return null;
    }

    final refId = const Uuid().v4();
    final uri = Uri.parse('$_baseUrl$_requestToPay');

    final formattedPhone = phoneNumber.replaceAll(RegExp(r'[+\s]'), '');

    final body = jsonEncode({
      'amount': amount.toString(),
      'currency': currency,
      'externalId': 'WeRank_${DateTime.now().millisecondsSinceEpoch}',
      'payer': {'partyIdType': 'MSISDN', 'partyId': formattedPhone},
      'payerMessage': description,
      'payeeNote': 'Payment for WeRank services',
    });

    try {
      // Debug logs to verify headers
      print('Using access token: $_accessToken');
      print('Using subscription key: $subscriptionKey');
      print('Using reference ID: $refId');

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Ocp-Apim-Subscription-Key': subscriptionKey,
          'X-Reference-Id': refId,
          'X-Target-Environment': 'sandbox',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Headers sent: ${{'Authorization': 'Bearer ${_accessToken?.substring(0, 10)}...', 'Ocp-Apim-Subscription-Key': subscriptionKey, 'X-Reference-Id': refId}}');
      
      if (resp.statusCode == 202) {
        print('Payment initiated successfully. Reference: $refId');
        return refId;
      }

      print('Payment initiation failed: ${resp.statusCode} - ${resp.body}');
      return null;
    } catch (e) {
      print('Payment initiation exception: $e');
      return null;
    }
  }

  Future<bool> simulateResult(String referenceId, String status) async {
    if (_accessToken == null && !await authenticate()) {
      print('Authentication failed for simulation');
      return false;
    }

    final uri = Uri.parse('$_baseUrl/sandbox/v1_0/requesttopay/$referenceId');

    try {
      print('Simulating payment result for reference: $referenceId');
      print('Simulation endpoint: $uri');
      
      final resp = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Ocp-Apim-Subscription-Key': subscriptionKey,
          'X-Target-Environment': 'sandbox',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
          'reason': 'Sandbox simulation'
        }),
      );

      print('Simulation response: ${resp.statusCode} - ${resp.body}');
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (e) {
      print('Simulation exception: $e');
      return false;
    }
  }

  Future<String?> checkPaymentStatus(String referenceId) async {
    if (_accessToken == null && !await authenticate()) {
      print('Authentication failed for status check');
      return null;
    }

    final uri = Uri.parse(
      '$_baseUrl/collection/v1_0/requesttopay/$referenceId', // FIXED: Use v1_0 instead of v2_0
    );

    try {
      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Ocp-Apim-Subscription-Key': subscriptionKey,
          'X-Target-Environment': 'sandbox',
        },
      );

      if (resp.statusCode == 200) {
        final status = jsonDecode(resp.body)['status'] as String?;
        print('Payment status: $status');
        return status;
      }

      print('Status check failed: ${resp.statusCode} - ${resp.body}');
      return null;
    } catch (e) {
      print('Status check exception: $e');
      return null;
    }
  }
}