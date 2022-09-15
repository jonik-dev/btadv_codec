import 'btadv_packet.dart';
import 'received_packets.dart';

// NOTE: Reference point from https://github.com/mtilvis/TIoCPS_TX/blob/main/src/lenkki.h
final latitudeReference = calculateReferencePoint(64.94011);
final longitudeReference = calculateReferencePoint(25.38884);

void main() {
  print('-------------');
  for (final data in receivedPackets) {
    final packet = BTAdvPacket.fromData(latitudeReference, longitudeReference, data);
    print('packet: $data, $packet');
  }
}
