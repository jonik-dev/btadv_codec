import 'btadv_packet.dart';
import 'dev_functions.dart';
import 'received_packets.dart';

void main() {
  print('-------------');
  for (final data in receivedPackets) {
    final packet = BTAdvPacket.fromData(data);
    print(packet);
    br();
  }
}
