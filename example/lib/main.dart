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

  Duration selectedDuration = const Duration(hours: 1, minutes: 20, seconds: 5);
  late AlwaysChangeValueNotifier<Duration> durationChangeNotifier;

  bool showSecondPage = false;

  @override
  void initState() {
    timeChangeNotifier = AlwaysChangeValueNotifier(selectedTime);
    durationChangeNotifier = AlwaysChangeValueNotifier(selectedDuration);
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
    final pickedDuration = await showSpinnerDurationPicker(
      initDuration: selectedDuration,
      context,
    );

    if (pickedDuration != null) {
      setState(() {
        durationChangeNotifier.value = selectedDuration = pickedDuration;
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
            '${selectedDuration.inHours}:${selectedDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(selectedDuration.inSeconds.remainder(60).toString().padLeft(2, '0'))}',
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
            spinnerWidth: 80,
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
              onPressed: () => setState(() => showSecondPage = false),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    color:
                        showSecondPage ? Colors.grey : Colors.deepPurpleAccent,
                  ),
                  const Text('Time'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () => setState(() => showSecondPage = true),
              child: Column(
                children: [
                  Icon(
                    Icons.timelapse,
                    color:
                        showSecondPage ? Colors.deepPurpleAccent : Colors.grey,
                  ),
                  const Text('Duration'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: showSecondPage ? _pageTwo() : _pageOne(),
    );
  }
}
