import 'btadv_packet.dart';
import 'received_packets.dart';
import 'util.dart';

// // NOTE: Reference point from https://github.com/mtilvis/TIoCPS_TX/blob/main/src/lenkki.h
// final polarReferencePoint = GeoCoordinate.fromLatLon(64.94011, 25.38884);

final polarReferencePoint = GeoCoordinate.fromLatLon(64.697006, 25.981080);

void main() {
  print('-------------');
  for (final data in receivedPackets) {
    final packet = BTAdvPacket.fromData(polarReferencePoint, data);
    print('packet: $data, $packet');
  }
}
