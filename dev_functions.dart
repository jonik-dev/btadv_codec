import "dart:math";

void br() {
  print('\n');
}

extension IntToBinary on int {
  String get toBinary {
    final binary = toRadixString(2).split('').reversed.toList();
    return List.generate((binary.length / 4).ceil(), (i) {
      final index = i * 4;
      return binary.getRange(index, min(index + 4, binary.length)).toList().reversed.join('');
    }).reversed.join(' ');
  }
}
