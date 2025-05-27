import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'utils.dart';

// 🏙️ City Model
class City {
  final String name;
  final String country;

  City({required this.name, required this.country});
}

// 🌐 City Service (Mock Search)
class CityService {
  static List<City> cities = [
    City(name: "Yangon", country: "Myanmar"),
    City(name: "Mandalay", country: "Myanmar"),
    City(name: "Naypyidaw", country: "Myanmar"),
    City(name: "Bangkok", country: "Thailand"),
    City(name: "Chiang Mai", country: "Thailand"),
    City(name: "Tokyo", country: "Japan"),
    City(name: "Osaka", country: "Japan"),
    City(name: "Seoul", country: "South Korea"),
    City(name: "Busan", country: "South Korea"),
  ];

  static List<City> find(String query) {
    if (query.isEmpty) return [];

    return cities
        .where(
          (city) =>
              city.name.toLowerCase().contains(query.toLowerCase()) ||
              city.country.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}

class AutoCompleteExample extends StatelessWidget {
  final List<String> suggestions = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Fig',
    'Grape',
    'Kiwi',
    'Mango',
    'Orange',
    'Peach',
    'Pear',
    'Pineapple',
    'Strawberry',
    'Watermelon',
  ];

  final List<String> cities = [
    "Yangon",
    "Mandalay",
    "Naypyidaw",
    "Bangkok",
    "Chiang Mai",
    "Tokyo",
    "Osaka",
    "Seoul",
    "Busan",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Autocomplete Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TypeAheadField<String>(
                suggestionsCallback: (pattern) {
                  return suggestions
                      .where(
                        (fruit) =>
                            fruit.toLowerCase().contains(pattern.toLowerCase()),
                      )
                      .toList();
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fruits',
                    ),
                  );
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSelected: (suggestion) {
                  // Handle the selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You selected $suggestion')),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TypeAheadField<City>(
                suggestionsCallback: (pattern) async {
                  return CityService.find(pattern);
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'City',
                    ),
                  );
                },
                itemBuilder: (context, city) {
                  return ListTile(
                    title: Text(city.name),
                    subtitle: Text(city.country),
                  );
                },
                onSelected: (city) {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => CityPage(city: city),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TypeAheadField<String>(
                suggestionsCallback: (pattern) async {
                  return cities
                      .where(
                        (city) =>
                            city.toLowerCase().contains(pattern.toLowerCase()),
                      )
                      .toList();
                },
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
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSelected: (suggestion) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Selected: $suggestion")),
                  );
                },
              ),
            ),
            customeAutoCompleteStrings(
              suggestions: cities,
              labelText: "Search City",
              onSelected: (suggestion) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Selected: $suggestion")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CityPage extends StatelessWidget {
  final City city;

  const CityPage({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${city.name} Page")),
      body: Center(
        child: Text(
          "${city.name}, ${city.country}",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
