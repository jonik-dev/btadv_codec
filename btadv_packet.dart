import 'dart:convert';
import 'dart:typed_data';
import "dart:math";
import 'package:blowfish_ecb/blowfish_ecb.dart';

const blowfishKey = 'HS_APPL';
final blowfish = BlowfishECB(Uint8List.fromList(utf8.encode(blowfishKey)));

num mod = pow(10.0, 6);

int calculateReferencePoint(double fraction) {
  final rounded = ((fraction + 0.0000005) * mod).floor();
  return (rounded ~/ 1000000) * 1000000 + ((rounded % 1000000) >> 15 << 15);
}

class BTAdvPacket {
  BTAdvPacket(
      {required this.userId,
      required this.latitude,
      required this.longitude,
      required this.battery,
      required this.gpsFix,
      required this.application,
      required this.messageNumber,
      required this.direction,
      required this.speed,
      required this.barksLastMin,
      required this.barking,
      required this.moving,
      required this.barksLast10Sec});
  final DateTime timestamp = DateTime.now();
  final int userId;
  final double latitude;
  final double longitude;
  final int battery;
  final bool gpsFix;
  final int application;
  final int messageNumber;
  final int direction;
  final double speed;
  final int barksLastMin;
  final bool barking;
  final bool moving;
  final int barksLast10Sec;

  /// 1111
  static const batteryMask = 0xF;

  /// 0001
  static const gpsFixMask = 0x1;

  /// 11
  static const applicationMask = 0x3;

  /// 11
  static const messageNumberMask = 0x3;

  /// 0111
  static const directionMask = 0x7;

  /// 0001
  static const movingMask = 0x1;

  /// 00111111
  static const barksLast10SecMask = 0x3F;

  factory BTAdvPacket.fromData(int latitudeReference, int longitudeReference, List<int> data) {
    final plainData = data.getRange(0, 5).toList();
    final encryptedData = data.getRange(5, 13).toList();
    final decryptedData = blowfish.decode(encryptedData);
    final byteData = ByteData.view(Uint8List.fromList(plainData + decryptedData).buffer);

    final applicationIndex = byteData.getUint8(5) >> 1 & applicationMask;

    final latitude0 = byteData.getUint8(3) >> 4;
    final latitude1 = byteData.getUint8(2);

    num latitude = latitudeReference;
    latitude += latitude0 << 3;
    latitude += (latitude1 << 7);
    latitude = latitude / mod;

    const longitude0Mask = 0xF; // 1111
    // NOTE: Must use sum, not OR operator.
    final longitude0 = (byteData.getUint8(3) & longitude0Mask);
    final longitude1 = byteData.getUint8(4);

    num longitude = longitudeReference;
    // NOTE: Must use sum, not OR operator.
    longitude += longitude0 << 3;
    longitude += longitude1 << 7;

    longitude = longitude / mod;

    const speedMask = 0x1F; // 00011111
    final speedRaw = (byteData.getUint8(5) & speedMask) + 2;
    final speed = speedRaw + speedRaw / 9;

    final uid0 = byteData.getUint8(1);
    final uid1 = byteData.getUint8(0);
    final uid2 = byteData.getUint8(11);
    final uid3 = byteData.getUint8(10);
    final userId = uid0 + (uid1 << 8) + (uid2 << 16) + (uid3 << 24);

    final directionIndex = byteData.getUint8(7) >> 6 & directionMask;

    return BTAdvPacket(
      userId: userId,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      battery: byteData.getUint8(5) >> 4 & batteryMask,
      gpsFix: byteData.getUint8(5) >> 3 & gpsFixMask == 1,
      application: applicationIndex,
      messageNumber: byteData.getUint8(6),
      direction: directionIndex,
      speed: speed,
      barksLastMin: byteData.getUint8(8),
      barking: byteData.getUint8(9) >> 7 == 1,
      moving: byteData.getUint8(9) >> 6 & movingMask == 1,
      barksLast10Sec: byteData.getUint8(9) & barksLast10SecMask,
    );
  }

  @override
  String toString() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'battery': battery,
      'gpsFix': gpsFix,
      'application': application,
      'messageNumber': messageNumber,
      'direction': direction,
      'speed': speed,
      'barksLastMin': barksLastMin,
      'barking': barking,
      'moving': moving,
      'barksLast10Sec': barksLast10Sec,
    }.map((key, value) => MapEntry(key, '$key: $value')).values.join(', ');
  }
}
