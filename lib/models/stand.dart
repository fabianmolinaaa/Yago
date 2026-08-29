enum StandStatus {
  available,
  occupied,
}

class Stand {
  final String id;
  final String number;
  final StandStatus status;
  final String? exhibitorName;
  final double x;
  final double y;
  final double width;
  final double height;

  const Stand({
    required this.id,
    required this.number,
    this.status = StandStatus.available,
    this.exhibitorName,
    required this.x,
    required this.y,
    this.width = 70.0,
    this.height = 70.0,
  });

  bool get isAvailable => status == StandStatus.available;
  bool get isOccupied => status == StandStatus.occupied;

  Stand copyWith({
    String? id,
    String? number,
    StandStatus? status,
    String? exhibitorName,
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return Stand(
      id: id ?? this.id,
      number: number ?? this.number,
      status: status ?? this.status,
      exhibitorName: exhibitorName ?? this.exhibitorName,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
