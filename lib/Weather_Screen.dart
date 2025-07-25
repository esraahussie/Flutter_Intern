import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather_Screen extends StatefulWidget {
  const Weather_Screen({super.key});

  @override
  State<Weather_Screen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<Weather_Screen> {
  final cityController = TextEditingController();
  final countryController = TextEditingController();

  String? city;
  double? currentTemp;
  String? description;
  bool isLoading = false;

  List<dynamic> forecastList = [];

  Future<void> fetchWeather() async {
    if (cityController.text.isEmpty || countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both country and city!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      forecastList.clear();
    });

    const apiKey = '5bf73f32230ce5e4e6321a4eef174572';

    final currentUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=${cityController.text},${countryController.text}&appid=$apiKey&units=metric';

    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=${cityController.text},${countryController.text}&appid=$apiKey&units=metric';

    try {
      final currentResponse = await http.get(Uri.parse(currentUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = jsonDecode(currentResponse.body);
        final forecastData = jsonDecode(forecastResponse.body);

        setState(() {
          city = currentData['name'];
          currentTemp = currentData['main']['temp'].toDouble();
          description = currentData['weather'][0]['description'];
          forecastList = forecastData['list'];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch data!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildForecastItem(dynamic item) {
    final dateTime = DateTime.parse(item['dt_txt']);
    final temp = item['main']['temp'];
    final desc = item['weather'][0]['description'];

    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(
          '${dateTime.day}/${dateTime.month} ${dateTime.hour}:00'),
      subtitle: Text('$desc'),
      trailing: Text('${temp.toStringAsFixed(1)}°C'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchWeather,
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (city != null)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$city',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${currentTemp?.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 40),
                    ),
                    Text(
                      '$description',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '5 Days Forecast:',
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: forecastList.length,
                        itemBuilder: (context, index) {
                          return buildForecastItem(forecastList[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
