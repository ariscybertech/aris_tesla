part of tesla;

class SeatHeater {
  const SeatHeater(this.name, this.id);

  static const SeatHeater frontLeft = const SeatHeater("Front Left", 0);
  static const SeatHeater frontRight = const SeatHeater("Front Right", 1);
  static const SeatHeater rearLeft = const SeatHeater("Rear Left", 2);
  static const SeatHeater rearRight = const SeatHeater("Rear Right", 5);
  static const SeatHeater rearCenter = const SeatHeater("Rear Center", 4);
  static const SeatHeater thirdRowLeft = const SeatHeater("3rd Row Left", 7);
  static const SeatHeater thirdRowRight = const SeatHeater("3rd Row Right", 8);
  static const SeatHeater rearLeftBack = const SeatHeater("Rear Left Back", 3);
  static const SeatHeater rearRightBack =
      const SeatHeater("Rear Right Back", 6);

  static const List<SeatHeater> heaters = const <SeatHeater>[
    frontLeft,
    frontRight,
    rearLeft,
    rearRight,
    rearCenter,
    thirdRowLeft,
    thirdRowRight,
    rearLeftBack,
    rearRightBack
  ];

  static const List<SeatHeater> modelSHeaters = const <SeatHeater>[
    frontLeft,
    frontRight,
    rearLeft,
    rearCenter,
    rearRight
  ];

  final String name;
  final int id;
}
