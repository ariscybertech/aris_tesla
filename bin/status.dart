import 'dart:async';
import 'dart:io';

import 'package:tesla/tool.dart';

Future main() async {
  var client = getTeslaClient();

  for (var vehicle in await client.listVehicles()) {
    await vehicle.wake();
    var state = await vehicle.getAllVehicleState();
    var vehicleState = state.vehicleState;

    print("${state.displayName}:");
    print("  VIN: ${state.vin}");
    print("  State: ${state.state}");
    print("  Software Version: ${vehicleState.carVersion}");
    print(
        "  Location: ${state.driveState.latitude} LAT, ${state.driveState.longitude} LONG");
    print("  Tokens: ${state.tokens}");

    if (stdout.hasTerminal) {
      print("  Option Codes");
      var buffer = new StringBuffer();
      var codes = new List<VehicleOptionCode>.from(vehicle.knownOptionCodes);
      while (codes.isNotEmpty) {
        var code = codes.removeAt(0);
        var content = "(${code.code}) ${code.description}";
        if (buffer.length + content.length + 4 >= stdout.terminalColumns) {
          print("    ${buffer.toString()}");
          buffer.clear();
        }

        if (buffer.isNotEmpty) {
          buffer.write(", ");
        }
        buffer.write(content);
      }

      if (buffer.isNotEmpty) {
        print("    ${buffer.toString()}");
      }
    } else {
      print("  Option Codes: ${state.knownOptionCodes}");
    }

    print("  Smart Summon Available: ${vehicleState.isSmartSummonAvailable}");
    print("  HomeLink Device Count: ${vehicleState.homelinkDeviceCount}");
    print("  Center Display Active: ${vehicleState.centerDisplayActive}");
    print("  Front Trunk Open: ${vehicleState.frontTrunkOpen}");
    print("  Trunk Open: ${vehicleState.rearTrunkOpen}");
    print("  Doors Open:");
    print("    Driver Side: ${vehicleState.driverSideDoorOpen}");
    print("    Driver Side Rear: ${vehicleState.driverSideRearDoorOpen}");
    print("    Passenger Side: ${vehicleState.passengerSideDoorOpen}");
    print("    Passenger Side Rear: ${vehicleState.passengerSideRearDoorOpen}");
  }

  client.close();
}
