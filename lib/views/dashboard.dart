import 'package:ffars_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatelessWidget {
  Future<http.Response> _responseFuture;


  @override
  Widget build(BuildContext context) {
    _responseFuture = http.get('https://jsonkeeper.com/b/RTZ2');

    return Container(
    child: Text("this is a Dashboard"),
    );
  }
}

// class Dashboard extends State<MyHomePage> with AutomaticKeepAliveClientMixin<MyHomePage> {
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   Widget build(BuildContext context) {
//     //Notice the super-call here.
//     super.build(context);
//     return Container(
//    child: Text("this is a Dashboard"),
//      );
//
//   }
// }
