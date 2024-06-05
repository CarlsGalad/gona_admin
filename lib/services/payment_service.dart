import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl = 'https://api.flutterwave.com/v3';
  final String secretKey = 'your_flutterwave_secret_key';

  Future<void> makeBulkTransfer(List<Map<String, dynamic>> payments) async {
    final url = Uri.parse('$baseUrl/transfers');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $secretKey',
    };

    final body = jsonEncode({
      "title": "Payment to vendors",
      "bulk_data": payments,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Bulk transfer successful');
    } else {
      print('Failed to make bulk transfer: ${response.body}');
    }
  }
}
