import 'package:flutter/material.dart';
import 'mobile_money_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _phoneController = TextEditingController(text: '233');
  final _amountController = TextEditingController(text: '1');
  bool _processing = false;
  String? _status;
  String? _errorMessage;
  String? _transactionId;

  // Hide sensitive data in a production environment
  late final MobileMoneyService _mmService;
  
  @override
  void initState() {
    super.initState();
    _mmService = MobileMoneyService(
      subscriptionKey: '203f503ebe7148958eb78f65872e61e8',
      apiUserId: '375f86ff-6ab6-45da-a312-d89109926d9e',
      apiKey: 'd84c24ae9e714163ba80d299e473b74c',
    );
    
    // Test authentication immediately
    _testAuthentication();
  }
  
  Future<void> _testAuthentication() async {
    setState(() {
      _errorMessage = 'Testing API connection...';
    });
    
    final authSuccess = await _mmService.authenticate();
    
    setState(() {
      if (authSuccess) {
        _errorMessage = 'API connection successful!';
      } else {
        _errorMessage = 'API connection failed. Please check credentials.';
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _doRealPayment() async {
    setState(() {
      _processing = true;
      _status = null;
      _errorMessage = null;
      _transactionId = null;
    });

    try {
      final phone = _phoneController.text.trim();
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      if (phone.isEmpty || phone.length < 9) {
        setState(() {
          _processing = false;
          _errorMessage = 'Please enter a valid phone number (e.g. 233501234567)';
        });
        return;
      }

      if (amount <= 0) {
        setState(() {
          _processing = false;
          _errorMessage = 'Please enter a valid amount (minimum 1 EUR)';
        });
        return;
      }

      // Initialize payment
      final txId = await _mmService.initPayment(
        phoneNumber: phone,
        amount: amount,
        currency: 'EUR',
        description: 'WeRank top-up',
      );

      if (txId == null) {
        setState(() {
          _processing = false;
          _status = 'INIT_FAILED';
          _errorMessage = 'Payment initialization failed';
        });
        return;
      }

      _transactionId = txId;
      
      // Simulate payment success in sandbox
      final simOk = await _mmService.simulateResult(txId, 'SUCCESSFUL');
      if (!simOk) {
        setState(() {
          _processing = false;
          _status = 'SIM_FAIL';
          _errorMessage = 'Payment simulation failed. Please check the logs for details.';
        });
        return;
      }


      String? status;
      int attempts = 0;
      const maxAttempts = 5;

      while (status == null || (status == 'PENDING' && attempts < maxAttempts)) {
        await Future.delayed(const Duration(seconds: 2));
        status = await _mmService.checkPaymentStatus(txId);
        attempts++;
      }

      setState(() {
        _processing = false;
        _status = status ?? 'UNKNOWN';
        if (status == null) {
          _errorMessage = 'Could not verify payment status';
        } else if (status != 'SUCCESSFUL') {
          _errorMessage = 'Payment failed with status: $status';
        }
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _status = 'ERROR';
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with MoMo'),
        backgroundColor: const Color(0xFF4527A0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '233501234567',
                prefixText: '+',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              enabled: !_processing,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (EUR)',
                hintText: 'e.g. 1.00',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_processing,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _processing ? null : _doRealPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EA),
                minimumSize: const Size.fromHeight(48),
              ),
              child: _processing
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Processing...', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : const Text('Submit Payment', style: TextStyle(fontSize: 16)),
            ),
            if (_status != null) ...[
              const SizedBox(height: 24),
              Icon(
                _status == 'SUCCESSFUL' ? Icons.check_circle : Icons.error,
                size: 48,
                color: _status == 'SUCCESSFUL' ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                _status == 'SUCCESSFUL' ? 'Payment Successful' : 'Payment Failed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _status == 'SUCCESSFUL' ? Colors.green : Colors.red,
                ),
              ),
              if (_status != 'SUCCESSFUL') ...[
                const SizedBox(height: 8),
                Text(
                  'Status: $_status',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              if (_transactionId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Transaction ID: $_transactionId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}