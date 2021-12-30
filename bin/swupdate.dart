import 'dart:async';

import 'package:tesla/tool.dart';

Future main() async {
  var client = getTeslaClient();

  for (var vehicle in await client.listVehicles()) {
    await vehicle.wake();
    await vehicle.scheduleSoftwareUpdate();
  }

  client.close();
}
