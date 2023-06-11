import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: "Hello First Demo App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }

}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

//It's a sample format for showing the section
  final String jsonData = '''
                   [
                    {
                       "title": "Section 1",
                       "description": "This is section 1",
                       "color": "#FF0000",
                       "height":"200",
                       "fontSize":"10",
                       "fontFamily":"Arial"
                    },
                  ]
                  ''';
  late List<Map<String, dynamic>> layoutData;
  ScrollController _scrollController = ScrollController();
  TextEditingController _sectionNameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  double sectionHeight = 70; // Default section height
  final screenHeight = window.physicalSize.height / window.devicePixelRatio;
  double fontSize = 16.0;
  static const double maxFontSize = 30.0;
  // Define a list of font families
  List<String> fontFamilies = ['Arial', 'Times New Roman', 'Verdana', 'Helvetica'];

  // Define a variable to store the selected font family
  String selectedFontFamily = "Arial"; // Set the initial selected font family


  @override
  void initState() {
    super.initState();
   // layoutData = List<Map<String, dynamic>>.from(jsonDecode(jsonData));
    layoutData = List<Map<String, dynamic>>.from([]);
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the scroll controller
    _sectionNameController.dispose(); // Dispose the text controller
    super.dispose();
  }


  void _scrollToSectionEnd() {
    // Scroll to the end of the list by setting the offset to the maximum scroll extent
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  void _addNewSection() {
    final String sectionName = _sectionNameController.text;
    if (sectionName.isNotEmpty && _selectedColor != null && sectionHeight != null && selectedFontFamily != null) {
      Faker faker = Faker();
      String paragraph = '';
      for (int i = 0; i < 5; i++) {
        String sentence = Faker().lorem.sentences(1).join(' ');
        paragraph += sentence + ' ';
      }
      setState(() {
        final newSection = {
          "title": sectionName,
          "description": paragraph,
          "color": '#${_selectedColor.value.toRadixString(16).substring(2)}',
          "height":sectionHeight,
          "fontSize" : fontSize,
          "fontFamily":selectedFontFamily,
        };

        layoutData.add(newSection);
        _sectionNameController.clear();
        //_selectedColor = Colors.blue;

        _scrollToSectionEnd(); // Scroll to the end of the section
      });
    } else {
      // Handle validation error (e.g., show a snackbar or display an error message)
      // You can customize this part based on your requirements
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Error'),
            content: const Text('Please enter a section name'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            'Dynamically Creating Section',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: layoutData.length,
        itemBuilder: (context, index) {
          final section = layoutData[index];
          final title = section['title'];
          final description = section['description'];
          final color = Color(int.parse(section['color']?.substring(1, 7), radix: 16) + 0xFF000000);
          final _height = section["height"];
          final _fontSize = section["fontSize"];
          final _selectedFontFamily = section["fontFamily"];
          final List<double> columnWidths = section["columnWidths"] ?? [1.0]; // Default width is 1.0


          return Container(
            padding: const EdgeInsets.all(5),
            color: color,
            width: double.infinity,
            child: SizedBox(
              height: _height > screenHeight ? screenHeight : _height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxHeight: _height - 40), // Adjust the value as needed
                    child: SingleChildScrollView(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontFamily:_selectedFontFamily
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
             onPressed: () 
             {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                 // Color _selectedColor = Colors.blue; // Initially selected color
                  return AlertDialog(
                    title: const Text('Create New Section'),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: _sectionNameController,
                              decoration: const InputDecoration(
                                labelText: 'Section Name',
                              ),
                            ),
                             Slider(
                              value: sectionHeight,
                              min: 70,
                              max: screenHeight,
                              divisions: 100,
                              onChanged: (value) {
                                setState(() {
                                  sectionHeight = value;
                                });
                              },
                              label: sectionHeight.round().toString(),
                            ),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Section Height: ${sectionHeight.round()}'),
                              Text('Max Height: ${screenHeight.round()}'),
                            ],
                            ),
                            Slider(
                              value: fontSize,
                              min: 10,
                              max: maxFontSize,
                              divisions: 20,
                              onChanged: (value) {
                                setState(() {
                                  fontSize = value;
                                });
                              },
                              label: fontSize.round().toString(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Font Size: ${fontSize.round()}'),
                                Text('Max Font Size: ${maxFontSize.round()}'),
                              ],
                            ),
                             DropdownButton<String>(
                              value: selectedFontFamily,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedFontFamily = newValue!;
                                });
                              },
                              items: fontFamilies.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Selected fontFamily: ${selectedFontFamily}'),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Choose a Color'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: _selectedColor,
                                          onColorChanged: (color) {
                                            setState(() {
                                              _selectedColor = color;
                                            });
                                          },
                                          showLabel: true,
                                          pickerAreaHeightPercent: 0.8,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Select'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text('Choose Color'),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Choosen Color'),
                                 Container(
                                  width: 40,
                                  height: 40,
                                  color: _selectedColor,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _addNewSection();
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  );
                },
              );

            },
            tooltip: 'Add Section',
            child: const Icon(Icons.add),
          ),
    );
  }
}
