import '../../../features/weather/data/dtos/city_location_model.dart';

class AppConstants {
  static const appName = 'Weather Forecast App';
  static const basePath = 'https://api.openweathermap.org/data/2.5/';

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
