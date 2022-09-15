T enumFromIndex<T>(int index, List<T> values, T fallback) {
  try {
    return values[index];
  } catch (_) {
    return fallback;
  }
}

class GeoCoordinate {
  GeoCoordinate(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  factory GeoCoordinate.fromLatLon(double latitude, double longitude) => GeoCoordinate(latitude, longitude);
}

extension Remap on num {
  double remap(num fromLow, num fromHigh, num toLow, num toHigh) {
    return (this - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow;
  }
}
