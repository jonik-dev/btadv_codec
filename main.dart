import "dart:convert";

import 'btadv_packet.dart';
import 'dev_functions.dart';

void main() {
  for (var i = 0; i < 5; i++) {
    br();
  }

  final data = base64.decode('hA20XM1+5le89+RUKQ==');
  final packet = BTAdvPacket.from(data);
  print(packet);
}
