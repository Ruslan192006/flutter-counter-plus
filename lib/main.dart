import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: CounterPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class CounterPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const CounterPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;
  List<String> _history = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
    await prefs.setStringList('history', _history);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _addToHistory('Увеличено до $_counter');
    });
    _saveCounter();
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _addToHistory('Уменьшено до $_counter');
    });
    _saveCounter();
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _addToHistory('Сброшено до 0');
    });
    _saveCounter();
  }

  void _setCustomValue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Установить значение'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Введите число',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(_controller.text);
              if (value != null) {
                setState(() {
                  _counter = value;
                  _addToHistory('Установлено значение $_counter');
                });
                _saveCounter();
                _controller.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('История изменений'),
        content: SizedBox(
          width: double.maxFinite,
          child: _history.isEmpty
              ? const Text('История пуста')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(_history[_history.length - 1 - index]),
                    );
                  },
                ),
        ),
        actions: [
          if (_history.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _history.clear();
                });
                _saveCounter();
                Navigator.pop(context);
              },
              child: const Text('Очистить'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _addToHistory(String action) {
    _history.add(action);
    if (_history.length > 50) {
      _history.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Plus'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Текущее значение:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  heroTag: 'decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  heroTag: 'increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Сброс'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _setCustomValue,
                  icon: const Icon(Icons.edit),
                  label: const Text('Установить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
