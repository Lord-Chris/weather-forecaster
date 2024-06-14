import 'package:flutter/foundation.dart';

import '../../../features/weather/domain/entities/city_location_model.dart';

class AppConstants {
  static const appName = 'Weather Forecast App';

  static const mockImage =
      'https://www.bing.com/th?id=OIP.Sa9ZfKEPzreh38i8xrwQJgHaEo&w=316&h=197&c=8&rs=1&qlt=90&o=6&pid=3.1&rm=2';

  static const appMode = kDebugMode ? 'debug' : 'release';

  static const cities = [
    CityLocationModel(
      id: '1',
      name: 'Silverstone, UK',
      lat: 52.073273,
      lon: -1.014818,
    ),
    CityLocationModel(
      id: '2',
      name: 'São Paulo, Brazil',
      lat: -23.533773,
      lon: -46.625290,
    ),
    CityLocationModel(
      id: '3',
      name: 'Melbourne, Australia',
      lat: -37.840935,
      lon: 144.946457,
    ),
    CityLocationModel(
      id: '4',
      name: 'Monte Carlo, Monaco',
      lat: 43.740070,
      lon: 7.426644,
    ),
  ];
}
