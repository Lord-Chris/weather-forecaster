import 'package:flutter/material.dart';

/// Shows an OpenWeatherMap condition icon, e.g. `10d`.
class WeatherIcon extends StatelessWidget {
  final String? icon;
  final double size;

  const WeatherIcon({super.key, required this.icon, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.cloud_outlined,
      size: size * 0.7,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final icon = this.icon;
    return SizedBox(
      width: size,
      height: size,
      child: icon == null
          ? fallback
          : Image.network(
              'https://openweathermap.org/img/wn/$icon@2x.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => fallback,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : fallback,
            ),
    );
  }
}
