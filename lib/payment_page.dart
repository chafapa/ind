import 'package:flutter/material.dart';
import 'mobile_money_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _phoneController  = TextEditingController(text: '+2335');
  final _amountController = TextEditingController(text: '1.00');
  bool _processing = false;
  String? _status;

  final _mmService = MobileMoneyService(
    subscriptionKey: '203f503ebe7148958eb78f65872e61e8',
    apiUserId:        '375f86ff-6ab6-45da-a312-d89109926d9e',
    apiKey:           'd84c24ae9e714163ba80d299e473b74c',
  );

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
    });

    final phone  = _phoneController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final txId = await _mmService.initPayment(
      phoneNumber: phone,
      amount:      amount,
      currency:    'EUR', // sandbox only
      description: 'WeRank top-up',
    );
    if (txId == null) {
      setState(() {
        _processing = false;
        _status = 'FAILED';
      });
      return;
    }

    final simOk = await _mmService.simulateResult(txId, 'SUCCESSFUL');
    if (!simOk) {
      setState(() {
        _processing = false;
        _status = 'SIM_FAIL';
      });
      return;
    }

    String? status;
    do {
      await Future.delayed(const Duration(seconds: 2));
      status = await _mmService.checkPaymentStatus(txId);
    } while (status == 'PENDING');

    setState(() {
      _processing = false;
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with MoMo'),
        backgroundColor: const Color(0xFF4527A0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+233501234567',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (GHS)',
                hintText: 'e.g. 5.00',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _processing ? null : _doRealPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EA),
                minimumSize: const Size.fromHeight(48),
              ),
              child: _processing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Payment',
                      style: TextStyle(fontSize: 16)),
            ),
            if (_status != null) ...[
              const SizedBox(height: 24),
              Icon(
                (_status == 'SUCCESS' || _status == 'SUCCESSFUL')
                    ? Icons.check_circle
                    : Icons.error,
                size: 48,
                color: (_status == 'SUCCESS' || _status == 'SUCCESSFUL')
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                'Payment $_status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: (_status == 'SUCCESS' || _status == 'SUCCESSFUL')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
