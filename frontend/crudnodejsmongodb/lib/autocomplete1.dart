import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomCompletePage extends StatefulWidget {
  const CustomCompletePage({super.key});

  @override
  State<CustomCompletePage> createState() => _CustomCompletePageState();
}

class _CustomCompletePageState extends State<CustomCompletePage> {
  final List<Map<String, String>> cities = [
    {'name': 'New York', 'country': 'USA'},
    {'name': 'Los Angeles', 'country': 'USA'},
    {'name': 'London', 'country': 'UK'},
    {'name': 'Yangon', 'country': 'Myanmar'},
  ];

  Future<List<Map<String, String>>> _findCities(String pattern) async {
    return cities
        .where(
          (city) => city['name']!.toLowerCase().contains(pattern.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City Selector')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TypeAheadField<Map<String, String>>(
          suggestionsCallback: _findCities,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              enabled: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'City',
              ),
            );
          },
          itemBuilder: (context, city) {
            return ListTile(
              title: Text(city['name']!),
              subtitle: Text(city['country']!),
            );
          },
          onSelected: (city) {},
        ),
      ),
    );
  }
}
