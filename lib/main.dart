import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_editing_flutter/image_editing_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:  PhotoFilterHomePage(),

    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = "Processing...";

  @override
  void initState() {
    super.initState();
   // _performWithoutCompute() ;
    _performHeavyTask();
  }

  // Future<R> compute<M, R>
  // ( FutureOr<R> Function(M) callback,M message, { String? debugLabel, })

  Future<void> _performHeavyTask() async {
    // Run the heavy computation in a separate isolate
    final result = await compute<int, String>(_heavyComputation, 1000000);
    setState(() {
      _result = result;
    });
  }

  Future<void> _performWithoutCompute() async{
    final result = await _heavyComputation(1000) ;
    setState(() {
      _result = result ;
    });
  }

  static String _heavyComputation(int number) {
    int sum = 0;
    for (int i = 0; i < number; i++) {
      sum += i;
    }
    return "Sum: $sum";
  }

  @override
  Widget build(BuildContext context) {
    return Text(_result, style:const  TextStyle(fontSize: 24));
  }
}