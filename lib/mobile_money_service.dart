import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MobileMoneyService {
  static const _baseUrl       = 'https://sandbox.momodeveloper.mtn.com';
  static const _tokenEndpoint = '/collection/token/';
  static const _requestToPay  = '/collection/v1_0/requesttopay';

  final String subscriptionKey;
  final String apiUserId;
  final String apiKey;
  String?   _accessToken;

  MobileMoneyService({
    required this.subscriptionKey,
    required this.apiUserId,
    required this.apiKey,
  });

  Future<bool> authenticate() async {
    final uri   = Uri.parse('$_baseUrl$_tokenEndpoint');
    final creds = base64Encode(utf8.encode('$apiUserId:$apiKey'));
    final resp  = await http.post(uri, headers: {
      'Authorization': 'Basic $creds',
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/json',
    });
    if (resp.statusCode == 200) {
      _accessToken = jsonDecode(resp.body)['access_token'] as String?;
      return _accessToken != null;
    }
    print('Auth failed: ${resp.statusCode} ${resp.body}');
    return false;
  }

  Future<String?> initPayment({
    required String phoneNumber,
    required double amount,
    required String currency,
    required String description,
  }) async {
    if (_accessToken == null && !await authenticate()) return null;

    final refId = const Uuid().v4();
    final uri   = Uri.parse('$_baseUrl$_requestToPay');
    final body  = jsonEncode({
      'amount': amount.toStringAsFixed(2),
      'currency': currency,
      'externalId': 'WeRankReward',
      'payer': {'partyIdType': 'MSISDN', 'partyId': phoneNumber},
      'payerMessage': description,
      'payeeNote': 'Thanks for using WeRank!',
    });

    final resp = await http.post(uri, headers: {
      'Authorization': 'Bearer $_accessToken',
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'X-Reference-Id': refId,
      'X-Target-Environment': 'sandbox',
      'Content-Type': 'application/json',
    }, body: body);

    if (resp.statusCode == 202) return refId;
    print('initPayment failed: ${resp.statusCode} ${resp.body}');
    return null;
  }

  /// **Corrected** simulate endpoint
  Future<bool> simulateResult(String referenceId, String status) async {
    final uri = Uri.parse(
      '$_baseUrl/collection/sandbox/v1_0/requesttopay/$referenceId/simulate'
    );
    final resp = await http.post(uri, headers: {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'X-Target-Environment': 'sandbox',
      'Content-Type': 'application/json',
    }, body: jsonEncode({'status': status}));

    print('simulateResult → ${resp.statusCode}: ${resp.body}');
    return resp.statusCode == 200;
  }

  Future<String?> checkPaymentStatus(String referenceId) async {
    final uri  = Uri.parse('$_baseUrl$_requestToPay/$referenceId');
    final resp = await http.get(uri, headers: {
      'Authorization': 'Bearer $_accessToken',
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'X-Target-Environment': 'sandbox',
    });

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['status'] as String?;
    }
    print('checkPaymentStatus failed: ${resp.statusCode} ${resp.body}');
    return null;
  }
}
