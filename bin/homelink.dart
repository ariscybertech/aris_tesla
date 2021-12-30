import 'dart:async';

import 'package:tesla/tool.dart';

Future main() async {
  var client = getTeslaClient();

  for (var vehicle in await client.listVehicles()) {
    await vehicle.wake();
    var drive = await vehicle.getDriveState();
    await vehicle.triggerHomeLink(
        latitude: drive.latitude, longitude: drive.longitude);
  }

  client.close();
}
