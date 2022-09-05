import 'dart:convert';
import 'dart:typed_data';
import "dart:math";
import 'package:blowfish_ecb/blowfish_ecb.dart';

import 'util.dart';

const blowfishKey = 'HS_APPLICATION';
final blowfish = BlowfishECB(Uint8List.fromList(utf8.encode(blowfishKey)));

num mod = pow(10.0, 6);

final calculateReferencePoint = (double fraction) {
  return ((fraction + 0.0000005) * mod).floor() >> 14 << 14;
};

// NOTE: Reference point from https://github.com/mtilvis/TIoCPS_TX/blob/main/src/lenkki.h
final latitudeReference = calculateReferencePoint(64.940111234);
final longitudeReference = calculateReferencePoint(25.388841234);

enum ApplicationType { huntingSecurity, dog }

enum Direction { north, northEast, east, southEast, south, southWest, west, northWest }

class BTAdvPacket {
  BTAdvPacket(
      {required this.userId,
      required this.latitude,
      required this.longitude,
      required this.battery,
      required this.gpsFix,
      required this.application,
      required this.safetyEnabled,
      required this.messageNumber,
      required this.direction,
      required this.speed,
      required this.barksLastMin,
      required this.barking,
      required this.moving,
      required this.barksLast10Sec});
  final int userId;
  final double latitude;
  final double longitude;
  final int battery;
  final bool gpsFix;
  final ApplicationType? application;
  final bool safetyEnabled;
  final int messageNumber;
  final Direction? direction;
  final double speed;
  final int barksLastMin;
  final bool barking;
  final bool moving;
  final int barksLast10Sec;

  factory BTAdvPacket.from(List<int> data) {
    final plainData = ByteData.view(Uint8List.fromList(data.getRange(0, 5).toList()).buffer);

    final encryptedData = data.getRange(5, 13).toList();
    final decryptedData = ByteData.view(Uint8List.fromList(blowfish.decode(encryptedData)).buffer);
    // TODO: Join plain and decrypted

    final latitude = () {
      final latitude0 = plainData.getUint8(3) >> 4;
      final latitude1 = plainData.getUint8(2);

      var latitude = latitudeReference;
      latitude |= latitude0 << 2;
      latitude |= (latitude1 << 6);

      return latitude / mod;
    }();

    final longitude = () {
      const _longitude0Mask = 0xF; // 1111
      final longitude0 = (plainData.getUint8(3) & _longitude0Mask);
      final longitude1 = plainData.getUint8(4);

      var longitude = longitudeReference;
      longitude |= longitude0 << 2;
      longitude |= longitude1 << 6;

      return longitude / mod;
    }();

    final speed = () {
      const _speedMask = 0x1F; // 00011111
      final speedRaw = decryptedData.getUint8(2) & _speedMask + 2; // 5-0
      // TODO: Latest spec new formula
      return speedRaw + speedRaw / 9;
    }();

    const _batteryMask = 0xF0; // 11110000
    const _gpsFixMask = 0x8; // 1000
    const _applicationMask = 0x6; // 0110
    const _safetyEnabledMask = 0x1; // 0001
    const _directionMask = 0xE0; //11100000
    const _movingMask = 0x40; // 01000000
    const _barksLast10SecMask = 0x3F; // 00111111

    final userId = () {
      final uid0 = plainData.getUint8(1);
      final uid1 = plainData.getUint8(0);
      final uid2 = decryptedData.getUint8(6);
      final uid3 = decryptedData.getUint8(5);
      return uid0 + (uid1 << 8) + (uid2 << 16) + (uid3 << 24);
    }();

    final applicationIndex = decryptedData.getUint8(0) >> 1 & _applicationMask;
    final directionIndex = decryptedData.getUint8(2) >> 6 & _directionMask;

    return BTAdvPacket(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      battery: decryptedData.getUint8(0) >> 4 & _batteryMask,
      gpsFix: decryptedData.getUint8(0) >> 3 & _gpsFixMask == 1,
      application: enumFromIndex<ApplicationType?>(applicationIndex, ApplicationType.values, null),
      safetyEnabled: decryptedData.getUint8(0) & _safetyEnabledMask == 1,
      messageNumber: decryptedData.getUint8(1),
      direction: enumFromIndex<Direction?>(directionIndex, Direction.values, null),
      speed: speed,
      barksLastMin: decryptedData.getUint8(3),
      barking: decryptedData.getUint8(4) >> 7 == 1,
      moving: decryptedData.getUint8(4) >> 6 & _movingMask == 1,
      barksLast10Sec: decryptedData.getUint8(4) & _barksLast10SecMask,
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
      'safetyEnabled': safetyEnabled,
      'messageNumber': messageNumber,
      'direction': direction,
      'speed': speed,
      'barksLastMin': barksLastMin,
      'barking': barking,
      'moving': moving,
      'barksLast10Sec': barksLast10Sec,
    }.map((key, value) => MapEntry(key, '$key: $value')).values.join('\n');
  }
}
