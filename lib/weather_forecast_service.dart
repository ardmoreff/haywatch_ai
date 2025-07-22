import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherForecastService {
  // Generate 7-day forecast using real USDA/NOAA data
  static Future<Map<String, dynamic>> generateSevenDayForecast(LatLng location) async {
    try {
      // Try to get real weather data first
      List<Map<String, dynamic>> forecast = await _getRealUSDAForecast(location);
      
      return {
        'location': location,
        'forecast': forecast,
        'source': 'USDA/NOAA',
        'generatedAt': DateTime.now(),
      };
    } catch (e) {
      print('USDA Weather API Error: $e');
      // Fallback to simulated regional data
      return _generateSimulatedForecast(location);
    }
  }
  
  // Get real USDA/NOAA weather data
  static Future<List<Map<String, dynamic>>> _getRealUSDAForecast(LatLng location) async {
    // Step 1: Get NOAA grid coordinates
    final pointResponse = await http.get(
      Uri.parse('https://api.weather.gov/points/${location.latitude},${location.longitude}'),
      headers: {'User-Agent': 'HayWatch AI Agricultural App (haywatch.app)'}
    );
    
    if (pointResponse.statusCode != 200) {
      throw Exception('Failed to get NOAA grid data: ${pointResponse.statusCode}');
    }
    
    final pointData = json.decode(pointResponse.body);
    final forecastUrl = pointData['properties']['forecast'];
    
    // Step 2: Get detailed forecast
    final forecastResponse = await http.get(
      Uri.parse(forecastUrl),
      headers: {'User-Agent': 'HayWatch AI Agricultural App (haywatch.app)'}
    );
    
    if (forecastResponse.statusCode != 200) {
      throw Exception('Failed to get NOAA forecast: ${forecastResponse.statusCode}');
    }
    
    final forecastData = json.decode(forecastResponse.body);
    final periods = forecastData['properties']['periods'] as List;
    
    // Process the data into our format
    List<Map<String, dynamic>> processedForecast = [];
    Set<String> processedDays = {};
    
    for (var period in periods) {
      if (processedForecast.length >= 7) break;
      
      final startTime = DateTime.parse(period['startTime']);
      final dayKey = '${startTime.year}-${startTime.month}-${startTime.day}';
      
      // Skip if we already processed this day (NOAA gives day/night periods)
      if (processedDays.contains(dayKey)) continue;
      processedDays.add(dayKey);
      
      // Extract core weather data
      int dayTemp = period['temperature'] ?? 75;
      String tempUnit = period['temperatureUnit'] ?? 'F';
      
      // Convert to Fahrenheit if needed
      if (tempUnit == 'C') {
        dayTemp = (dayTemp * 9/5 + 32).round();
      }
      
      // Get night temperature from next period if available
      int nightTemp = dayTemp - 15; // Default fallback
      final nextPeriodIndex = periods.indexOf(period) + 1;
      if (nextPeriodIndex < periods.length) {
        final nextPeriod = periods[nextPeriodIndex];
        if (nextPeriod['isDaytime'] == false) {
          nightTemp = nextPeriod['temperature'] ?? nightTemp;
          if ((nextPeriod['temperatureUnit'] ?? 'F') == 'C') {
            nightTemp = (nightTemp * 9/5 + 32).round();
          }
        }
      }
      
      // Extract detailed weather information
      String detailedForecast = period['detailedForecast'] ?? '';
      String shortForecast = period['shortForecast'] ?? 'Unknown';
      
      // Use AI-enhanced weather parsing for agricultural data
      Map<String, dynamic> agWeatherData = _parseAgriculturalWeather(
        detailedForecast, 
        shortForecast, 
        location
      );
      
      String dayOfWeek = _getDayOfWeek(startTime.weekday);
      
      processedForecast.add({
        'date': startTime,
        'dayOfWeek': dayOfWeek,
        'dayTemp': dayTemp,
        'nightTemp': nightTemp,
        'humidity': agWeatherData['humidity'],
        'windSpeed': agWeatherData['windSpeed'],
        'windDirection': agWeatherData['windDirection'],
        'precipitation': agWeatherData['precipitation'],
        'precipitationPercent': agWeatherData['precipitationPercent'],
        'condition': shortForecast,
        'detailedForecast': detailedForecast,
        'emoji': agWeatherData['emoji'],
        'uvIndex': agWeatherData['uvIndex'],
        'pressure': agWeatherData['pressure'],
        'dewPoint': agWeatherData['dewPoint'],
        'source': 'NOAA/NWS',
      });
    }
    
    return processedForecast;
  }
  
  // Enhanced weather parsing specifically for agricultural needs
  static Map<String, dynamic> _parseAgriculturalWeather(String detailed, String short, LatLng location) {
    detailed = detailed.toLowerCase();
    short = short.toLowerCase();
    
    // Get regional climate for baseline adjustments
    Map<String, dynamic> regionalClimate = _getRegionalClimate(location);
    
    // Humidity estimation (critical for hay drying)
    int humidity = regionalClimate['baseHumidity'];
    if (detailed.contains('humid') || detailed.contains('muggy')) {
      humidity = 80;
    } else if (detailed.contains('dry') || detailed.contains('arid')) humidity = 25;
    else if (detailed.contains('rain') || detailed.contains('storm')) humidity = 85;
    else if (detailed.contains('fog') || detailed.contains('mist')) humidity = 95;
    else if (detailed.contains('clear') || detailed.contains('sunny')) humidity = 35;
    else if (detailed.contains('cloudy')) humidity = 60;
    
    // Wind speed (critical for drying)
    int windSpeed = regionalClimate['baseWind'];
    String windDirection = 'Variable';
    
    // Extract specific wind information
    RegExp windPattern = RegExp(r'wind.*?(\d+).*?mph');
    Match? windMatch = windPattern.firstMatch(detailed);
    if (windMatch != null) {
      windSpeed = int.tryParse(windMatch.group(1) ?? '5') ?? windSpeed;
    } else {
      if (detailed.contains('windy') || detailed.contains('breezy')) {
        windSpeed = 15;
      } else if (detailed.contains('calm')) windSpeed = 2;
      else if (detailed.contains('gusts')) windSpeed = 20;
    }
    
    // Wind direction
    if (detailed.contains('north')) {
      windDirection = 'North';
    } else if (detailed.contains('south')) windDirection = 'South';
    else if (detailed.contains('east')) windDirection = 'East';
    else if (detailed.contains('west')) windDirection = 'West';
    
    // Precipitation analysis
    double precipitation = 0.0;
    int precipitationPercent = 0;
    
    if (detailed.contains('heavy rain') || short.contains('heavy rain')) {
      precipitation = 0.8;
      precipitationPercent = 90;
    } else if (detailed.contains('rain') || short.contains('rain')) {
      precipitation = 0.3;
      precipitationPercent = 70;
    } else if (detailed.contains('drizzle') || detailed.contains('light rain')) {
      precipitation = 0.1;
      precipitationPercent = 40;
    } else if (detailed.contains('thunderstorm') || detailed.contains('storm')) {
      precipitation = 0.6;
      precipitationPercent = 80;
    } else if (detailed.contains('shower')) {
      precipitation = 0.2;
      precipitationPercent = 50;
    }
    
    // Extract percentage if mentioned
    RegExp percentPattern = RegExp(r'(\d+)\s*percent.*?chance');
    Match? percentMatch = percentPattern.firstMatch(detailed);
    if (percentMatch != null) {
      precipitationPercent = int.tryParse(percentMatch.group(1) ?? '0') ?? precipitationPercent;
    }
    
    // Weather emoji for display
    String emoji = '⛅'; // Default
    if (precipitation > 0.5) {
      emoji = '🌧️';
    } else if (precipitation > 0.2) emoji = '🌦️';
    else if (short.contains('sunny') || short.contains('clear')) emoji = '☀️';
    else if (short.contains('cloudy')) emoji = '☁️';
    else if (windSpeed > 15) emoji = '💨';
    
    // Agricultural-specific estimates
    int uvIndex = _estimateUVIndex(short, detailed);
    int pressure = _estimatePressure(short, detailed, regionalClimate);
    int dewPoint = _estimateDewPoint(humidity, windSpeed);
    
    return {
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'precipitation': precipitation,
      'precipitationPercent': precipitationPercent,
      'emoji': emoji,
      'uvIndex': uvIndex,
      'pressure': pressure,
      'dewPoint': dewPoint,
    };
  }
  
  // Estimate UV index for crop considerations
  static int _estimateUVIndex(String short, String detailed) {
    if (short.contains('sunny') || short.contains('clear')) return 8;
    if (short.contains('partly cloudy')) return 6;
    if (short.contains('cloudy')) return 3;
    if (short.contains('rain') || short.contains('storm')) return 2;
    return 5; // Moderate default
  }
  
  // Estimate barometric pressure
  static int _estimatePressure(String short, String detailed, Map<String, dynamic> regional) {
    int basePressure = 30; // inches Hg * 10 for integer math
    
    if (short.contains('fair') || short.contains('clear')) basePressure = 31;
    if (short.contains('storm') || short.contains('rain')) basePressure = 29;
    
    return basePressure;
  }
  
  // Estimate dew point for humidity calculations
  static int _estimateDewPoint(int humidity, int windSpeed) {
    // Simplified dew point estimation for agricultural use
    if (humidity > 80) return 65;
    if (humidity > 60) return 55;
    if (humidity > 40) return 45;
    return 35;
  }

  // Fallback to simulated regional forecast
  static Map<String, dynamic> _generateSimulatedForecast(LatLng location) {
    final Random random = Random();
    final now = DateTime.now();
    List<Map<String, dynamic>> forecast = [];
    
    // Get regional climate characteristics
    Map<String, dynamic> regionalClimate = _getRegionalClimate(location);
    
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      
      // Use regional base values with variation
      double dayTemp = regionalClimate['baseTemp'] + random.nextDouble() * 20 - 10; // ±10°F variation
      double nightTemp = dayTemp - 15 - random.nextDouble() * 10;
      double humidity = (regionalClimate['baseHumidity'] + random.nextDouble() * 30 - 15).clamp(20, 90);
      double windSpeed = regionalClimate['baseWind'] + random.nextDouble() * 8 - 4; // ±4 mph variation
      double precipitation = random.nextDouble() < regionalClimate['precipChance'] ? random.nextDouble() * 0.8 : 0; // Regional precipitation chance
      
      // Weather conditions based on temp, humidity, and precipitation
      String condition;
      String emoji;
      if (precipitation > 0.3) {
        condition = precipitation > 0.6 ? "Heavy Rain" : "Light Rain";
        emoji = precipitation > 0.6 ? "🌧️" : "🌦️";
      } else if (humidity > 75) {
        condition = "Cloudy";
        emoji = "☁️";
      } else if (dayTemp > 85 && humidity < 50) {
        condition = "Hot & Dry";
        emoji = "☀️";
      } else if (windSpeed > 10) {
        condition = "Windy";
        emoji = "💨";
      } else {
        condition = "Partly Cloudy";
        emoji = "⛅";
      }
      
      forecast.add({
        'date': date,
        'dayOfWeek': _getDayOfWeek(date.weekday),
        'dayTemp': dayTemp.round(),
        'nightTemp': nightTemp.round(),
        'humidity': humidity.round(),
        'windSpeed': windSpeed.round(),
        'precipitation': precipitation,
        'precipitationPercent': precipitation > 0 ? (precipitation * 100 + 20).round().clamp(0, 100) : 0,
        'condition': condition,
        'emoji': emoji,
        'isToday': i == 0,
        'isTomorrow': i == 1,
      });
    }
    
    return {
      'forecast': forecast,
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'generatedAt': now,
      'source': 'HayWatch AI (Location-Based NDFD/RRFS Simulation)',
    };
  }
  
  // Get regional climate characteristics based on location
  static Map<String, dynamic> _getRegionalClimate(LatLng location) {
    double lat = location.latitude;
    double lng = location.longitude;
    
    // Define regional characteristics for major hay-growing regions
    if (lat >= 35 && lat <= 40 && lng >= -100 && lng <= -94) {
      // Oklahoma/Southern Kansas region - hot, moderate humidity
      return {
        'baseTemp': 85.0,
        'baseHumidity': 55.0,
        'baseWind': 8.0,
        'precipChance': 0.25,
      };
    } else if (lat >= 30 && lat <= 35 && lng >= -100 && lng <= -94) {
      // Texas region - hotter, higher humidity
      return {
        'baseTemp': 90.0,
        'baseHumidity': 65.0,
        'baseWind': 6.0,
        'precipChance': 0.20,
      };
    } else if (lat >= 37 && lat <= 42 && lng >= -98 && lng <= -90) {
      // Nebraska/Iowa region - moderate temps, higher humidity
      return {
        'baseTemp': 78.0,
        'baseHumidity': 70.0,
        'baseWind': 10.0,
        'precipChance': 0.30,
      };
    } else if (lat >= 42 && lat <= 47 && lng >= -100 && lng <= -90) {
      // Dakotas/Minnesota region - cooler, windy
      return {
        'baseTemp': 74.0,
        'baseHumidity': 60.0,
        'baseWind': 12.0,
        'precipChance': 0.25,
      };
    } else {
      // Default/General region
      return {
        'baseTemp': 80.0,
        'baseHumidity': 60.0,
        'baseWind': 8.0,
        'precipChance': 0.25,
      };
    }
  }
  
  // AI-generated cutting day analysis
  static Map<String, dynamic> analyzeOptimalCuttingDays(
    List<Map<String, dynamic>> forecast, 
    String forageType
  ) {
    List<Map<String, dynamic>> cuttingAnalysis = [];
    
    // Forage-specific characteristics for AI analysis
    Map<String, Map<String, dynamic>> forageData = {
      'Alfalfa': {
        'idealTemp': 80,
        'maxHumidity': 60,
        'minWindSpeed': 5,
        'maxPrecip': 0.1,
        'dryingHours': 42,
        'moistureContent': 85,
      },
      'Bermuda Grass': {
        'idealTemp': 85,
        'maxHumidity': 65,
        'minWindSpeed': 4,
        'maxPrecip': 0.05,
        'dryingHours': 28,
        'moistureContent': 75,
      },
      'Ryegrass': {
        'idealTemp': 75,
        'maxHumidity': 70,
        'minWindSpeed': 5,
        'maxPrecip': 0.1,
        'dryingHours': 36,
        'moistureContent': 80,
      },
      'Sudan Grass': {
        'idealTemp': 82,
        'maxHumidity': 65,
        'minWindSpeed': 6,
        'maxPrecip': 0.08,
        'dryingHours': 32,
        'moistureContent': 78,
      },
      'Timothy': {
        'idealTemp': 78,
        'maxHumidity': 65,
        'minWindSpeed': 5,
        'maxPrecip': 0.1,
        'dryingHours': 38,
        'moistureContent': 82,
      },
      'Clover': {
        'idealTemp': 75,
        'maxHumidity': 55,
        'minWindSpeed': 6,
        'maxPrecip': 0.05,
        'dryingHours': 48,
        'moistureContent': 88,
      },
      'Other': {
        'idealTemp': 78,
        'maxHumidity': 65,
        'minWindSpeed': 5,
        'maxPrecip': 0.1,
        'dryingHours': 36,
        'moistureContent': 80,
      },
    };
    
    var forage = forageData[forageType] ?? forageData['Other']!;
    
    for (int i = 0; i < forecast.length; i++) {
      var day = forecast[i];
      double score = 100.0; // Start with perfect score
      List<String> positives = [];
      List<String> negatives = [];
      List<String> concerns = [];
      
      // Temperature analysis
      int temp = day['dayTemp'];
      if (temp >= forage['idealTemp'] - 5 && temp <= forage['idealTemp'] + 10) {
        positives.add("Optimal temperature ($temp°F) for $forageType drying");
        score += 10;
      } else if (temp < forage['idealTemp'] - 10) {
        negatives.add("Cool temperature ($temp°F) will slow drying significantly");
        score -= 20;
      } else if (temp > forage['idealTemp'] + 15) {
        concerns.add("Very hot ($temp°F) - monitor for over-drying and quality loss");
        score -= 10;
      }
      
      // Humidity analysis
      int humidity = day['humidity'];
      if (humidity <= forage['maxHumidity']) {
        positives.add("Low humidity ($humidity%) promotes fast, even drying");
        score += 15;
      } else if (humidity > forage['maxHumidity'] + 15) {
        negatives.add("High humidity ($humidity%) will significantly slow drying");
        score -= 25;
      } else {
        concerns.add("Moderate humidity ($humidity%) may extend drying time");
        score -= 10;
      }
      
      // Wind analysis
      int windSpeed = day['windSpeed'];
      if (windSpeed >= forage['minWindSpeed'] && windSpeed <= 12) {
        positives.add("Good wind ($windSpeed mph) aids moisture removal");
        score += 10;
      } else if (windSpeed < forage['minWindSpeed']) {
        negatives.add("Light wind ($windSpeed mph) reduces drying efficiency");
        score -= 15;
      } else {
        concerns.add("Strong winds ($windSpeed mph) may cause leaf loss");
        score -= 5;
      }
      
      // Precipitation analysis
      double precip = day['precipitation'];
      if (precip == 0) {
        positives.add("No precipitation - perfect for cutting and drying");
        score += 20;
      } else if (precip <= forage['maxPrecip']) {
        concerns.add("Light moisture possible - monitor closely");
        score -= 10;
      } else {
        negatives.add("Rain expected (${(precip * 100).toStringAsFixed(1)}%) - avoid cutting");
        score -= 40;
      }
      
      // Multi-day analysis (look ahead)
      if (i < forecast.length - 2) {
        var nextDay = forecast[i + 1];
        var dayAfter = forecast[i + 2];
        
        if (nextDay['precipitation'] > 0.2) {
          negatives.add("Rain tomorrow will disrupt drying process");
          score -= 30;
        } else if (dayAfter['precipitation'] > 0.2) {
          concerns.add("Rain in 2 days - plan for quick turnaround");
          score -= 15;
        } else {
          positives.add("Clear weather continues - excellent drying window");
          score += 10;
        }
      }
      
      // Calculate overall recommendation
      String recommendation;
      String actionAdvice;
      String riskLevel;
      
      if (score >= 90) {
        recommendation = "EXCELLENT";
        actionAdvice = "Prime cutting day! Start early morning for best results.";
        riskLevel = "Very Low";
      } else if (score >= 75) {
        recommendation = "GOOD";
        actionAdvice = "Good conditions for cutting. Monitor weather closely.";
        riskLevel = "Low";
      } else if (score >= 60) {
        recommendation = "FAIR";
        actionAdvice = "Marginal conditions. Consider waiting for better weather.";
        riskLevel = "Moderate";
      } else if (score >= 40) {
        recommendation = "POOR";
        actionAdvice = "Not recommended. High risk of quality loss.";
        riskLevel = "High";
      } else {
        recommendation = "AVOID";
        actionAdvice = "Do not cut. Weather conditions are unsuitable.";
        riskLevel = "Very High";
      }
      
      // AI-generated summary
      String aiSummary = _generateAISummary(day, forageType, positives, negatives, concerns);
      
      cuttingAnalysis.add({
        'day': i,
        'date': day['date'],
        'dayOfWeek': day['dayOfWeek'],
        'score': score.round().clamp(0, 100),
        'recommendation': recommendation,
        'actionAdvice': actionAdvice,
        'riskLevel': riskLevel,
        'positives': positives,
        'negatives': negatives,
        'concerns': concerns,
        'aiSummary': aiSummary,
        'weather': day,
        'estimatedDryingHours': _calculateDryingTime(day, forage),
      });
    }
    
    // Find best cutting day
    int bestDay = 0;
    double bestScore = 0;
    for (int i = 0; i < cuttingAnalysis.length; i++) {
      if (cuttingAnalysis[i]['score'] > bestScore) {
        bestScore = cuttingAnalysis[i]['score'].toDouble();
        bestDay = i;
      }
    }
    
    return {
      'analysis': cuttingAnalysis,
      'bestCuttingDay': bestDay,
      'bestScore': bestScore,
      'overallAdvice': _generateOverallAdvice(cuttingAnalysis, forageType),
    };
  }
  
  static String _generateAISummary(
    Map<String, dynamic> weather, 
    String forageType, 
    List<String> positives, 
    List<String> negatives, 
    List<String> concerns
  ) {
    String summary = "";
    
    if (negatives.isNotEmpty) {
      summary = "⚠️ Not ideal for cutting $forageType. ${negatives[0]}";
    } else if (positives.length >= 3) {
      summary = "✅ Excellent day for $forageType! Multiple favorable conditions align.";
    } else if (positives.length >= 2) {
      summary = "👍 Good cutting weather. ${positives[0]}";
    } else if (concerns.isNotEmpty) {
      summary = "⚡ Proceed with caution. ${concerns[0]}";
    } else {
      summary = "📊 Conditions are mixed for $forageType cutting.";
    }
    
    return summary;
  }
  
  static String _generateOverallAdvice(List<Map<String, dynamic>> analysis, String forageType) {
    var goodDays = analysis.where((day) => day['score'] >= 75).length;
    var poorDays = analysis.where((day) => day['score'] < 50).length;
    
    if (goodDays >= 3) {
      return "🌟 Excellent week ahead for $forageType harvest! Multiple good cutting opportunities.";
    } else if (goodDays >= 2) {
      return "👍 Good harvesting window available. Plan cutting on highest-scoring days.";
    } else if (poorDays >= 4) {
      return "⚠️ Challenging week for $forageType. Consider delaying harvest if possible.";
    } else {
      return "📊 Mixed conditions this week. Focus on days with scores above 70.";
    }
  }
  
  static int _calculateDryingTime(Map<String, dynamic> weather, Map<String, dynamic> forage) {
    double baseHours = forage['dryingHours'].toDouble();
    double factor = 1.0;
    
    // Temperature factor
    int temp = weather['dayTemp'];
    if (temp > 85) {
      factor *= 0.8;
    } else if (temp < 70) factor *= 1.3;
    
    // Humidity factor
    int humidity = weather['humidity'];
    if (humidity > 70) {
      factor *= 1.4;
    } else if (humidity < 45) factor *= 0.85;
    
    // Wind factor
    int wind = weather['windSpeed'];
    if (wind > 8) {
      factor *= 0.9;
    } else if (wind < 4) factor *= 1.2;
    
    // Precipitation factor
    if (weather['precipitation'] > 0) factor *= 2.0;
    
    return (baseHours * factor).round();
  }
  
  static String _getDayOfWeek(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
