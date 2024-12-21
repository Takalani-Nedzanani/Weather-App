import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'South Africa Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  String apiKey =
      "f394f26033874343a57200318242112"; // Replace with your API key
  String selectedProvince = "Gauteng";
  Map weatherData = {};
  bool isLoading = true;

  // Map of provinces and their corresponding major cities
  final Map<String, String> provinces = {
    "Gauteng": "Johannesburg",
    "Western Cape": "Cape Town",
    "KwaZulu-Natal": "Durban",
    "Eastern Cape": "Port Elizabeth",
    "Free State": "Bloemfontein",
    "Limpopo": "Polokwane",
    "Mpumalanga": "Nelspruit",
    "Northern Cape": "Kimberley",
    "North West": "Mahikeng",
  };

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    final city = provinces[selectedProvince];
    final url =
        "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load weather data");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  // Determine the cloud color or image based on the weather condition
  Widget getWeatherIcon(String description) {
    if (description.contains("Sunny") || description.contains("Clear")) {
      return Icon(Icons.wb_sunny, size: 100, color: Colors.orange);
    } else if (description.contains("Rain") ||
        description.contains("Drizzle")) {
      return Icon(Icons.grain, size: 100, color: Colors.blue);
    } else if (description.contains("Cloudy")) {
      return Icon(Icons.cloud, size: 100, color: Colors.grey);
    } else if (description.contains("Thunder") ||
        description.contains("Storm")) {
      return Icon(Icons.flash_on, size: 100, color: Colors.yellow);
    } else {
      return Icon(Icons.cloud, size: 100, color: Colors.lightBlue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('South Africa Weather'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : weatherData.isEmpty
              ? Center(child: Text("Error fetching data."))
              : Container(
                  color: Colors.white, // White background
                  child: ListView(
                    children: [
                      // Searched Province Weather Display
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.lightBlue.shade400, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              weatherData["location"]["name"] ?? "City",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            getWeatherIcon(weatherData["current"]["condition"]
                                    ["text"] ??
                                ""), // Weather icon
                            SizedBox(height: 10),
                            Text(
                              "${weatherData["current"]["temp_c"].toString()}°C",
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              weatherData["current"]["condition"]["text"] ?? "",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Other Provinces List
                      ...provinces.keys
                          .where((province) => province != selectedProvince)
                          .map((province) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedProvince = province;
                                    fetchWeather();
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade200,
                                        Colors.blue
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        province,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          // ignore: unnecessary_to_list_in_spreads
                          .toList(),
                    ],
                  ),
                ),
    );
  }
}
