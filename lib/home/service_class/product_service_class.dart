import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/home/model_class/product_model_class.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const int _timeoutSeconds = 15;

  static Future<ProductDetailsModel> fetchProducts() async {
    try {
      // First verify DNS resolution
      await InternetAddress.lookup('dummyjson.com');

      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        log ( "response data $responseJson");
        return ProductDetailsModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('HTTP ${response.statusCode}');
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load: $e');
    }
  }
}