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
      title: 'Spinner Picker Example',
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

class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  late AlwaysChangeValueNotifier<TimeOfDay> timeChangeNotifier;
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    timeChangeNotifier = AlwaysChangeValueNotifier(selectedTime);
    super.initState();
  }

  @override
  void dispose() {
    timeChangeNotifier.dispose();
    super.dispose();
  }

  void _showTimePicker() async {
    final options =
        SpinnerTimePickerDialogOptions.fromContext(context).copyWith(
      showNowButton: true,
      pickerOptions: SpinnerTimePickerOptions.fromContext(context).copyWith(
        is24HourFormat: false,
      ),
    );

    final pickedTime = await showSpinnerTimePicker(
      context,
      initTime: selectedTime,
      options: options,
    );

    if (pickedTime != null) {
      setState(() {
        timeChangeNotifier.value = selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickerOptions =
        SpinnerTimePickerOptions.fromContext(context).copyWith(
      elementsSpace: 40,
      is24HourFormat: false,
      spinnerOptions: RawNumberSpinnerOptions.fromContext(context).copyWith(
        height: 150,
        width: 80,
        digitHeight: 50,
        selectedTextStyle:
            const TextStyle(fontSize: 30, color: Colors.deepPurple),
        nonSelectedTextStyle:
            const TextStyle(fontSize: 30, color: Colors.deepPurpleAccent),
        spinnerBgColor: Colors.deepPurpleAccent.withOpacity(0.4),
      ),
    );

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
            forceUpdateTimeNotifier: timeChangeNotifier,
            options: pickerOptions,
            onChangedSelectedTime: (updatedTime) => setState(() {
              selectedTime = updatedTime;
            }),
          ),
        ],
      ),
    );
  }
}

class DurationPage extends StatefulWidget {
  const DurationPage({super.key});

  @override
  State<DurationPage> createState() => _DurationPageState();
}

class _DurationPageState extends State<DurationPage> {
  late AlwaysChangeValueNotifier<Duration> durationChangeNotifier;
  Duration selectedDuration =
      const Duration(hours: 1, minutes: 20, seconds: 5, milliseconds: 8);
  bool showInfinityInDurationPicker = false;

  @override
  void initState() {
    durationChangeNotifier = AlwaysChangeValueNotifier(selectedDuration);
    super.initState();
  }

  @override
  void dispose() {
    durationChangeNotifier.dispose();
    super.dispose();
  }

  void _showDurationPicker() async {
    final options =
        SpinnerDurationPickerDialogOptions.fromContext(context).copyWith(
      showInfinityButton: true,
      contentPadding: const EdgeInsets.all(10),
      infinityButtonLabel: 'Infinite',
      pickerOptions: SpinnerDurationPickerOptions.fromContext(context).copyWith(
        hideMilliseconds: false,
        elementsSpace: 40,
        spinnerOptions: RawNumberSpinnerOptions.fromContext(context).copyWith(
          height: 150,
          width: 65,
          digitHeight: 50,
          selectedTextStyle:
              const TextStyle(fontSize: 30, color: Colors.deepPurple),
        ),
        showInfinityBetweenSmallestAndLargestValue:
            showInfinityInDurationPicker,
      ),
    );

    final pickedDuration = await showSpinnerDurationPicker(
      context,
      initDuration: selectedDuration,
      options: options,
    );

    if (pickedDuration != null) {
      setState(() {
        if (pickedDuration.isNegative) {
          showInfinityInDurationPicker = true;
        }
        durationChangeNotifier.value = selectedDuration = pickedDuration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickerOptions =
        SpinnerDurationPickerOptions.fromContext(context).copyWith(
      elementsSpace: 40,
      hideMilliseconds: false,
      spinnerOptions: RawNumberSpinnerOptions.fromContext(context).copyWith(
        height: 150,
        width: 50,
        digitHeight: 50,
        selectedTextStyle:
            const TextStyle(fontSize: 30, color: Colors.deepPurple),
        nonSelectedTextStyle:
            const TextStyle(fontSize: 30, color: Colors.deepPurpleAccent),
        spinnerBgColor: Colors.deepPurpleAccent.withOpacity(0.4),
        showInfinityBetweenSmallestAndLargestValue:
            showInfinityInDurationPicker,
      ),
    );

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
            _getDurationString(selectedDuration),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _showDurationPicker,
            child: const Text('Pick a Duration'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Show infinity value'),
              Checkbox(
                value: showInfinityInDurationPicker,
                onChanged: (bool? value) {
                  setState(() {
                    showInfinityInDurationPicker = value ?? false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          SpinnerDurationPicker(
            forceUpdateDurationNotifier: durationChangeNotifier,
            options: pickerOptions,
            onChangedSelectedDuration: (updatedDuration) => setState(() {
              selectedDuration = updatedDuration;
            }),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                durationChangeNotifier.value = const Duration(
                    hours: 3, minutes: 20, seconds: 1, milliseconds: 100);
                selectedDuration = const Duration(
                    hours: 3, minutes: 20, seconds: 1, milliseconds: 100);
              });
            },
            child: const Text('Set: 3:20:1.1'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                durationChangeNotifier.value =
                    const Duration(hours: 1, minutes: 5, seconds: 2);
                selectedDuration =
                    const Duration(hours: 1, minutes: 5, seconds: 2);
              });
            },
            child: const Text('Set: 1:5:25:2'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                showInfinityInDurationPicker = true;
                durationChangeNotifier.value = const Duration(
                    hours: -1, minutes: -1, seconds: -1, milliseconds: -1);
                selectedDuration = const Duration(
                    hours: -1, minutes: -1, seconds: -1, milliseconds: -1);
              });
            },
            child: const Text('Set: ∞'),
          ),
        ],
      ),
    );
  }

  String _getDurationString(Duration duration) {
    final hours = duration.inHours.toString();
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds =
        (duration.inMilliseconds.remainder(1000) ~/ 100).toString();

    return '$hours:$minutes:$seconds.$milliseconds';
  }
}

class NumberPage extends StatefulWidget {
  const NumberPage({super.key});

  @override
  State<NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  late AlwaysChangeValueNotifier<int> numberChangeNotifier;
  int selectedNumber = 0;
  bool showInfinityBetweenSmallestAndLargestValue = false;
  bool padNumbers = false;

  @override
  void initState() {
    numberChangeNotifier = AlwaysChangeValueNotifier(selectedNumber);
    super.initState();
  }

  @override
  void dispose() {
    numberChangeNotifier.dispose();
    super.dispose();
  }

  void _showNumberPicker() async {
    final options =
        SpinnerNumberPickerDialogOptions.fromContext(context).copyWith(
      showInfinityButton: true,
      pickerOptions: SpinnerNumberPickerOptions.fromContext(context).copyWith(
        elementsSpace: 75,
        unit: '\$',
        spinnerOptions: RawNumberSpinnerOptions.fromContext(context).copyWith(
          padNumbers: padNumbers,
        ),
      ),
    );

    final pickedNumber = await showSpinnerNumberPicker(
      context,
      initValue: selectedNumber,
      maxValue: 1000,
      steps: 10,
      options: options,
    );

    if (pickedNumber != null) {
      setState(() {
        numberChangeNotifier.value = selectedNumber = pickedNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickerOptions =
        SpinnerNumberPickerOptions.fromContext(context).copyWith(
      elementsSpace: 75,
      unit: '\$',
      spinnerOptions: RawNumberSpinnerOptions.fromContext(context).copyWith(
        height: 150,
        width: 80,
        digitHeight: 50,
        selectedTextStyle:
            const TextStyle(fontSize: 30, color: Colors.deepPurple),
        nonSelectedTextStyle:
            const TextStyle(fontSize: 30, color: Colors.deepPurpleAccent),
        spinnerBgColor: Colors.deepPurpleAccent.withOpacity(0.4),
        showInfinityBetweenSmallestAndLargestValue:
            showInfinityBetweenSmallestAndLargestValue,
        padNumbers: padNumbers,
      ),
    );

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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Show infinity value'),
              Checkbox(
                value: showInfinityBetweenSmallestAndLargestValue,
                onChanged: (bool? value) {
                  setState(() {
                    showInfinityBetweenSmallestAndLargestValue = value ?? false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pad numbers'),
              Checkbox(
                value: padNumbers,
                onChanged: (bool? value) {
                  setState(() {
                    padNumbers = value ?? false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          SpinnerNumberPicker(
            forceUpdateValueNotifier: numberChangeNotifier,
            maxValue: 10000,
            steps: 10,
            options: pickerOptions,
            onChangedSelectedValue: (updatedValue) => setState(() {
              selectedNumber = updatedValue;
            }),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int shownPageNumber = 0;

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
      body: SingleChildScrollView(
        child: switch (shownPageNumber) {
          0 => const TimePage(),
          1 => const DurationPage(),
          2 => const NumberPage(),
          _ => Container(),
        },
      ),
    );
  }
}
