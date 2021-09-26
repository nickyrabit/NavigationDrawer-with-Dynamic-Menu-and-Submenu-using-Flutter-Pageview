import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Receipts extends StatelessWidget {
  Future<http.Response> _responseFuture;

  @override
  Widget build(BuildContext context) {
    _responseFuture = http.get('https://jsonkeeper.com/b/RTZ2');

    return Container();
  }
}

