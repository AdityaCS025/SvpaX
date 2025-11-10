import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _cityController = TextEditingController();
  final List<String> _popularCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai',
    'Pune',
    'Hyderabad',
    'Kolkata',
    'Ahmedabad',
    'Surat',
    'Jaipur',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _fetchInitialData() async {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    await provider.fetchWeather();
    await provider.fetchMultipleCities();
  }

  void _fetchWeatherForCity(String city) async {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    provider.setSelectedCity(city);
    await provider.fetchWeather(city: city);
    await provider.fetchForecast(city: city);
  }

  String _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case "01d":
        return "☀️"; // Clear sky day
      case "01n":
        return "🌙"; // Clear sky night
      case "02d":
      case "02n":
        return "⛅"; // Few clouds
      case "03d":
      case "03n":
      case "04d":
      case "04n":
        return "☁️"; // Clouds
      case "09d":
      case "09n":
        return "🌧️"; // Shower rain
      case "10d":
      case "10n":
        return "🌦️"; // Rain
      case "11d":
      case "11n":
        return "⛈️"; // Thunderstorm
      case "13d":
      case "13n":
        return "❄️"; // Snow
      case "50d":
      case "50n":
        return "🌫️"; // Mist
      default:
        return "🌤️";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.location_city), text: "Current"),
            Tab(icon: Icon(Icons.public), text: "Cities"),
            Tab(icon: Icon(Icons.calendar_today), text: "Forecast"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchInitialData,
            tooltip: "Refresh Weather",
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentWeatherTab(),
          _buildMultipleCitiesTab(),
          _buildForecastTab(),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherTab() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${provider.error}", textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchWeather(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (provider.currentWeather == null) {
          return const Center(child: Text("No weather data available"));
        }

        final weather = provider.currentWeather!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF7C83FD),
                const Color(0xFF7C83FD).withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // City Search
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (_cityController.text.isNotEmpty) {
                            _fetchWeatherForCity(_cityController.text);
                            _cityController.clear();
                          }
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _fetchWeatherForCity(value);
                        _cityController.clear();
                      }
                    },
                  ),
                ),

                // Popular Cities
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularCities.length,
                    itemBuilder: (context, index) {
                      final city = _popularCities[index];
                      final isSelected = city == provider.selectedCity;
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          label: Text(city),
                          selected: isSelected,
                          onSelected: (selected) => _fetchWeatherForCity(city),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          selectedColor: Colors.white.withOpacity(0.4),
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${weather.cityName}, ${weather.country}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getWeatherIcon(weather.iconCode),
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${weather.temperature.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherDetail(
                                  Icons.arrow_downward,
                                  "${weather.minTemp.toStringAsFixed(1)}°C",
                                  "Min",
                                ),
                                _buildWeatherDetail(
                                  Icons.arrow_upward,
                                  "${weather.maxTemp.toStringAsFixed(1)}°C",
                                  "Max",
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherDetail(
                                  Icons.water_drop,
                                  "${weather.humidity}%",
                                  "Humidity",
                                ),
                                _buildWeatherDetail(
                                  Icons.air,
                                  "${weather.windSpeed} m/s",
                                  "Wind",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultipleCitiesTab() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${provider.error}", textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchMultipleCities(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (provider.multipleCities.isEmpty) {
          return const Center(child: Text("No weather data available"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.multipleCities.length,
          itemBuilder: (context, index) {
            final cityWeather = provider.multipleCities[index];
            if (cityWeather.error != null) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text(cityWeather.city),
                  subtitle: Text("Error: ${cityWeather.error}"),
                ),
              );
            }

            if (cityWeather.data == null) {
              return Card(
                child: ListTile(
                  leading: const CircularProgressIndicator(),
                  title: Text(cityWeather.city),
                  subtitle: const Text("Loading..."),
                ),
              );
            }

            final weather = cityWeather.data!;
            return Card(
              child: ListTile(
                leading: Text(
                  _getWeatherIcon(weather.iconCode),
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text("${weather.cityName}, ${weather.country}"),
                subtitle: Text(weather.condition),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${weather.temperature.toStringAsFixed(1)}°C",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "H:${weather.maxTemp.toStringAsFixed(0)}° L:${weather.minTemp.toStringAsFixed(0)}°",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: () {
                  _fetchWeatherForCity(weather.cityName);
                  _tabController.animateTo(0);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildForecastTab() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${provider.error}", textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchForecast(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (provider.forecast.isEmpty) {
          return const Center(child: Text("No forecast data available"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.forecast.length,
          itemBuilder: (context, index) {
            final forecast = provider.forecast[index];
            final date = forecast.dateTime;

            return Card(
              child: ListTile(
                leading: Text(
                  _getWeatherIcon(forecast.iconCode),
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(
                  "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                ),
                subtitle: Text(forecast.condition),
                trailing: Text(
                  "${forecast.temperature.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
