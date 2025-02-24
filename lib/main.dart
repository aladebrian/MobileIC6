import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    // Provide the model to all widgets within the app. We're using
    // ChangeNotifierProvider because that's a simple way to rebuild
    // widgets when a model changes. We could also just use
    // Provider, but then we would have to listen to Counter ourselves.
    //
    // Read Provider's docs to learn about all the available providers.
    ChangeNotifierProvider(
      // Initialize the model in the builder. That way, Provider
      // can own Counter's lifecycle, making sure to call `dispose`
      // when not needed anymore.
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 360;
const double windowHeight = 640;
void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}

/// Simplest possible model, with just one field.
///
/// [ChangeNotifier] is a class in `flutter:foundation`. [Counter] does
/// _not_ depend on Provider.
class Counter with ChangeNotifier {
  int value = 7;
  void increment() {
    value += 1;
    notifyListeners();
  }

  void decrement() {
    value -= 1;
    notifyListeners();
  }

  void setValue(int val) {
    value = val;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static List<String> milestones = [
    "Baby", // 0-2 = 0
    "Child", // 3-12 = 1
    "Teenager", // 13-19 = 2
    "The Dark Ages", // 20-29
    "The Dark Ages Pt. 2", // 30-39
    "Unc Status", // 40-49
    "Retirement", // 50-59
    "Dementia's knocking", // 60+
  ];
  static List<MaterialColor> colors = [
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.orange,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.grey,
    Colors.blueGrey,
  ];
  int index(int value) {
    if (value < 20) {
      return ((7 + value) ~/ 10).clamp(0, 2);
    } else {
      return min(milestones.length - 1, (value ~/ 10) + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age Counter')),
      body: Center(
        child: Container(
          color: colors[index(context.read<Counter>().value)],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Consumer looks for an ancestor Provider widget
              // and retrieves its model (Counter, in this case).
              // Then it uses that model to build widgets, and will trigger
              // rebuilds if the model is updated.
              Consumer<Counter>(
                builder:
                    (context, counter, child) =>
                        Text(milestones[index(counter.value)]),
              ),
              Consumer<Counter>(
                builder:
                    (context, counter, child) => Text(
                      'I am ${counter.value} years old',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
              ),
              Consumer<Counter>(
                builder:
                    (context, counter, child) => Slider(
                      value: counter.value.toDouble(),
                      min: 0.0,
                      max: 100.0,
                      onChanged: (value) {
                        counter.setValue(value.toInt());
                      },
                    ),
              ),
              ElevatedButton(
                onPressed: () {
                  var counter = context.read<Counter>();
                  counter.increment();
                },
                child: Text("Increase Age"),
              ),
              ElevatedButton(
                onPressed: () {
                  var counter = context.read<Counter>();
                  counter.decrement();
                },
                child: Text("Reduce Age"),
              ),

              // You can access your providers anywhere you have access
              // to the contextZ. One way is to use Provider.of<Counter>(context).
              // The provider package also defines extension methods on the context
              // itself. You can call context.watch<Counter>() in a build method
              // of any widget to access the current state of Counter, and to ask
              // Flutter to rebuild your widget anytime Counter changes.
              //
              // You can't use context.watch() outside build methods, because that
              // often leads to subtle bugs. Instead, you should use
              // context.read<Counter>(), which gets the current state
              // but doesn't ask Flutter for future rebuilds.
              //
              // Since we're in a callback that will be called whenever the user
              // taps the FloatingActionButton, we are not in the build method here.
              // We should use context.read().
            ],
          ),
        ),
      ),
    );
  }
}
