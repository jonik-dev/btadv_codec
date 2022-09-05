T enumFromIndex<T>(int index, List<T> values, T fallback) {
  try {
    return values[index];
  } catch (_) {
    return fallback;
  }
}
