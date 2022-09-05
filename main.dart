import "dart:convert";

import 'btadv_packet.dart';
import 'dev_functions.dart';
import 'received_packets.dart';

void main() {
  print('-------------');
  for (final base64Encoded in receivedPackets) {
    final data = base64.decode(base64Encoded);
    final packet = BTAdvPacket.from(data);
    print(packet);
    br();
  }
}
