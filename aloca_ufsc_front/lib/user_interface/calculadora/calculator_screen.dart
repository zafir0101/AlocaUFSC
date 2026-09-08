import 'package:aloca_ufsc_front/api/api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CalculatorState();
}

class _CalculatorState extends State<CalculatorScreen> {
  final _num1 = TextEditingController();
  final _num2 = TextEditingController();

  Future<String?>? _result;

  void _submit(String op) {
    setState(() {
      _result = Api.calc(
        int.tryParse(_num1.text),
        int.tryParse(_num2.text),
        op,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculadora',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    controller: _num1,
                    decoration: const InputDecoration(
                      labelText: "Número 1",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    controller: _num2,
                    decoration: const InputDecoration(
                      labelText: "Número 2",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.plus),
                  onPressed: () => _submit("sum"),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.minus),
                  onPressed: () => _submit("minus"),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.xmark),
                  onPressed: () => _submit("times"),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.divide),
                  onPressed: () => _submit("div"),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: _result,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center();
              return Center(
                child: Text(
                  snapshot.data!.toString(),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
