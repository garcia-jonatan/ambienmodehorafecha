import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

void main() {
  initializeDateFormatting('es');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      child: const HomeScreen(title: 'AMBIENTMODE DE FECHA,HORA Y CLIMA'),
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Wear Hello',
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            colorScheme: mode == WearMode.active
                ? const ColorScheme.dark(
                    primary: Color(0xFF00B5FF),
                  )
                : const ColorScheme.dark(
                    primary: Color.fromARGB(179, 144, 140, 140),
                    onBackground: Color.fromARGB(168, 152, 144, 144),
                    onSurface: Color.fromARGB(184, 174, 168, 168),
                  ),
          ),
          home: child,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Timer timer;
  String formattedDateTime = '';
  String formattedDate = '';
  WeatherFactory weatherFactory = WeatherFactory(
      "ca58d3e5edff31e7c39345a5d0048dea",
      language: Language.SPANISH);
  Weather? currentWeather;

  @override
  void initState() {
    super.initState();
    updateDateTime();
    getCurrentWeather();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      updateDateTime();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateDateTime() {
    final DateTime now = DateTime.now();
    final DateFormat dayFormatter = DateFormat('dd', 'es');
    final DateFormat monthFormatter = DateFormat('MMMM', 'es');
    final DateFormat yearFormatter = DateFormat('yyyy', 'es');

    setState(() {
      formattedDateTime = DateFormat.Hm().format(now);
      formattedDate =
          '${dayFormatter.format(now)} de ${monthFormatter.format(now)} de ${yearFormatter.format(now)}';
    });
  }

  Future<void> getCurrentWeather() async {
    Weather? weather =
        await weatherFactory.currentWeatherByLocation(40.7128, -74.0060);
    setState(() {
      currentWeather = weather;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientMode(
        builder: (BuildContext context, dynamic mode, Widget? child) {
          final isAmbientMode = mode == WearMode.ambient;
          final textColor = isAmbientMode
              ? const Color.fromARGB(255, 83, 255, 126)
              : const Color.fromARGB(255, 113, 255, 248);
          final backgroundColor = isAmbientMode
              ? const Color.fromARGB(255, 112, 186, 250)
              : const Color.fromARGB(153, 255, 0, 255);
          final colorHora = isAmbientMode
              ? const Color.fromARGB(255, 43, 0, 255)
              : const Color.fromARGB(255, 179, 255, 0);
          final colorClima = isAmbientMode
              ? const Color.fromARGB(255, 15, 189, 233)
              : const Color.fromARGB(255, 53, 212, 212);
          final colorIcono = isAmbientMode
              ? const Color.fromARGB(255, 66, 66, 66)
              : const Color.fromARGB(255, 13, 0, 255);
          final colorTipoClima = isAmbientMode
              ? const Color.fromARGB(255, 218, 77, 77)
              : const Color.fromARGB(255, 51, 5, 237);

          return Container(
            color: backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorHora,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentWeather != null)
                    Column(
                      children: [
                        Icon(
                          getWeatherIcon(currentWeather!.weatherDescription!),
                          size: 20,
                          color: colorIcono,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${currentWeather!.temperature?.celsius?.toStringAsFixed(3)}°C",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorClima,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentWeather!.weatherDescription!,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorTipoClima,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData getWeatherIcon(String weatherDescription) {
    if (weatherDescription.contains('lluvia')) {
      return WeatherIcons.rain;
    } else if (weatherDescription.contains('nublado')) {
      return WeatherIcons.cloudy;
    } else if (weatherDescription.contains('soleado') ||
        weatherDescription.contains('despejado')) {
      return WeatherIcons.day_sunny;
    } else if (weatherDescription.contains('nieve')) {
      return WeatherIcons.snow;
    } else if (weatherDescription.contains('tormenta')) {
      return WeatherIcons.thunderstorm;
    } else if (weatherDescription.contains('niebla')) {
      return WeatherIcons.fog;
    } else {
      return WeatherIcons.cloudy;
    }
  }
}
