import 'package:flutter/cupertino.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: "Kanbasu",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Kanbasu'),
        ),
        child: Stack(
          children: [
            Align(
                alignment: FractionalOffset.center,
                child: CupertinoButton.filled(
                  key: Key('btn'),
                  child: Text('$_counter'),
                  onPressed: () {
                    setState(() {
                      _counter++;
                    });
                  },
                )),
          ],
        ));
  }
}
