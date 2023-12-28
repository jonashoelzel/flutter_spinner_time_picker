import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Picker Example',
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimeOfDay selectedTime = TimeOfDay.now();
  late AlwaysChangeValueNotifier<TimeOfDay> timeChangeNotifier;

  Duration selectedDuration =
      const Duration(hours: 1, minutes: 20, seconds: 5, milliseconds: 8);
  late AlwaysChangeValueNotifier<Duration> durationChangeNotifier;

  int selectedNumber = 0;
  late AlwaysChangeValueNotifier<int> numberChangeNotifier;

  int shownPageNumber = 0;

  @override
  void initState() {
    timeChangeNotifier = AlwaysChangeValueNotifier(selectedTime);
    durationChangeNotifier = AlwaysChangeValueNotifier(selectedDuration);
    numberChangeNotifier = AlwaysChangeValueNotifier(selectedNumber);
    super.initState();
  }

  @override
  void dispose() {
    timeChangeNotifier.dispose();
    durationChangeNotifier.dispose();
    super.dispose();
  }

  void _showTimePicker() async {
    final pickedTime = await showSpinnerTimePicker(
      context,
      initTime: selectedTime,
      is24HourFormat: false,
    );

    if (pickedTime != null) {
      setState(() {
        timeChangeNotifier.value = selectedTime = pickedTime;
      });
    }
  }

  void _showDurationPicker() async {
    final pickedNumber = await showSpinnerDurationPicker(
      initDuration: selectedDuration,
      hideMilliseconds: false,
      hideHours: true,
      elementsSpace: 32,
      contentPadding: const EdgeInsets.all(10),
      context,
    );

    if (pickedNumber != null) {
      setState(() {
        durationChangeNotifier.value = selectedDuration = pickedNumber;
      });
    }
  }

  void _showNumberPicker() async {
    final pickedNumber = await showSpinnerNumberPicker(
      initValue: selectedNumber,
      elementsSpace: 75,
      unit: '\$',
      maxValue: 1000,
      context,
    );

    if (pickedNumber != null) {
      setState(() {
        numberChangeNotifier.value = selectedNumber = pickedNumber;
      });
    }
  }

  Widget _pageOne() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Selected Time:',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _showTimePicker,
            child: const Text('Pick a Time'),
          ),
          const SizedBox(height: 40),
          SpinnerTimePicker(
            elementsSpace: 40,
            spinnerHeight: 150,
            spinnerWidth: 80,
            is24HourFormat: false,
            digitHeight: 50,
            forceUpdateTimeNotifier: timeChangeNotifier,
            onChangedSelectedTime: (updatedTime) => setState(() {
              selectedTime = updatedTime;
            }),
            selectedTextStyle:
                const TextStyle(fontSize: 30, color: Colors.deepPurple),
            nonSelectedTextStyle:
                const TextStyle(fontSize: 30, color: Colors.deepPurpleAccent),
            spinnerBgColor: Colors.deepPurpleAccent.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _pageTwo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Selected Duration:',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '${selectedDuration.inHours}:${selectedDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(selectedDuration.inSeconds.remainder(60).toString().padLeft(2, '0'))}.${(selectedDuration.inMilliseconds.remainder(1000) ~/ 100)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _showDurationPicker,
            child: const Text('Pick a Duration'),
          ),
          const SizedBox(height: 40),
          SpinnerDurationPicker(
            forceUpdateDurationNotifier: durationChangeNotifier,
            spinnerHeight: 150,
            spinnerWidth: 50,
            elementsSpace: 40,
            digitHeight: 50,
            spinnerBgColor: Colors.deepPurpleAccent.withOpacity(0.4),
            onChangedSelectedDuration: (updatedDuration) => setState(() {
              selectedDuration = updatedDuration;
            }),
            selectedTextStyle:
                const TextStyle(fontSize: 30, color: Colors.deepPurple),
            nonSelectedTextStyle:
                const TextStyle(fontSize: 30, color: Colors.deepPurpleAccent),
            hideMilliseconds: false,
          ),
        ],
      ),
    );
  }

  Widget _pageThree() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Selected a Number:',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '$selectedNumber \$',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _showNumberPicker,
            child: const Text('Pick a Number'),
          ),
          const SizedBox(height: 40),
          SpinnerNumberPicker(
            forceUpdateValueNotifier: numberChangeNotifier,
            spinnerHeight: 150,
            spinnerWidth: 80,
            elementsSpace: 75,
            digitHeight: 50,
            spinnerBgColor: Colors.deepPurpleAccent.withOpacity(0.4),
            onChangedSelectedValue: (updatedValue) => setState(() {
              selectedNumber = updatedValue;
            }),
            selectedTextStyle:
                const TextStyle(fontSize: 30, color: Colors.deepPurple),
            nonSelectedTextStyle:
                const TextStyle(fontSize: 30, color: Colors.deepPurpleAccent),
            maxValue: 1000,
            unit: '\$',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Picker Example'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              onPressed: () => setState(() => shownPageNumber = 0),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    color: shownPageNumber != 0
                        ? Colors.grey
                        : Colors.deepPurpleAccent,
                  ),
                  const Text('Time'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () => setState(() => shownPageNumber = 1),
              child: Column(
                children: [
                  Icon(
                    Icons.timelapse,
                    color: shownPageNumber != 1
                        ? Colors.grey
                        : Colors.deepPurpleAccent,
                  ),
                  const Text('Duration'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () => setState(() => shownPageNumber = 2),
              child: Column(
                children: [
                  Icon(
                    Icons.numbers,
                    color: shownPageNumber != 2
                        ? Colors.grey
                        : Colors.deepPurpleAccent,
                  ),
                  const Text('Number'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: switch (shownPageNumber) {
        0 => _pageOne(),
        1 => _pageTwo(),
        2 => _pageThree(),
        _ => Container(),
      },
    );
  }
}
