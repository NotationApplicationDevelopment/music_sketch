class TimelinePosition {
  late int basePosition;
  late double _subPosition;

  TimelinePosition.fromPosition(double position) {
    this.position = position;
  }
  TimelinePosition({this.basePosition = 0, double subPosition = 0}) {
    this.subPosition = subPosition;
  }

  double get subPosition => _subPosition;
  set subPosition(double value) {
    _subPosition = value.clamp(0.0, 0.999999);
  }

  double get position => basePosition + subPosition;
  set position(double value) {
    var f = value.floor();
    basePosition = f;
    _subPosition = value - f;
  }

  DateTime getAsDateTime(double millisecondsParUnit) {
    var ms = (position * millisecondsParUnit).toInt();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  void setAsDateTime(double millisecondsParUnit, DateTime value) {
    this.position = value.microsecondsSinceEpoch * 0.001 / millisecondsParUnit;
  }

  TimelineRange to(TimelinePosition to) {
    return TimelineRange.fromRange(to.position - position);
  }

  TimelineRange from(TimelinePosition from) {
    return TimelineRange.fromRange(position - from.position);
  }

  bool operator ==(dynamic right) {
    return right is TimelinePosition && position == right.position;
  }

  int get hashCode => position.hashCode;

  bool operator >(TimelinePosition right) {
    return position > right.position;
  }

  bool operator >=(TimelinePosition right) {
    return position >= right.position;
  }

  bool operator <(TimelinePosition right) {
    return position < right.position;
  }

  bool operator <=(TimelinePosition right) {
    return position <= right.position;
  }

  TimelinePosition operator +(TimelineRange right) {
    var ret = TimelinePosition(
        basePosition: this.basePosition, subPosition: this._subPosition);
    ret.position += right.range;
    return ret;
  }

  TimelinePosition operator -(TimelineRange right) {
    var ret = TimelinePosition(
        basePosition: this.basePosition, subPosition: this._subPosition);
    ret.position -= right.range;
    return ret;
  }
}

class TimelineRange {
  late int baseRange;
  late double _subRange;

  TimelineRange.fromRange(double range) {
    this.range = range;
  }

  TimelineRange({this.baseRange = 0, double subRange = 0}) {
    this.subRange = subRange;
  }

  double get subRange => _subRange;
  set subRange(double value) {
    _subRange = value.clamp(0.0, 0.999999);
  }

  double get range => baseRange + subRange;
  set range(double value) {
    var f = value.floor();
    baseRange = f;
    _subRange = value - f;
  }

  Duration getAsDuration(double millisecondsParUnit) {
    var ms = (range * millisecondsParUnit).toInt();
    return Duration(milliseconds: ms);
  }

  void setAsDuration(double millisecondsParUnit, Duration value) {
    this.range = value.inMicroseconds * 0.001 / millisecondsParUnit;
  }

  bool operator ==(dynamic right) {
    return right is TimelineRange && range == right.range;
  }

  int get hashCode => range.hashCode;

  bool operator >(TimelineRange right) {
    return range > right.range;
  }

  bool operator >=(TimelineRange right) {
    return range >= right.range;
  }

  bool operator <(TimelineRange right) {
    return range < right.range;
  }

  bool operator <=(TimelineRange right) {
    return range <= right.range;
  }

  TimelineRange operator +(TimelineRange right) {
    return TimelineRange.fromRange(range + right.range);
  }

  TimelineRange operator -(TimelineRange right) {
    return TimelineRange.fromRange(range - right.range);
  }
  
  TimelineRange operator -() {
    return TimelineRange.fromRange(-range);
  }
}

class TimelinePositionRange {
  late TimelinePosition start;
  late TimelinePosition end;

  TimelinePositionRange(this.start, this.end);
  TimelinePositionRange.fromRange(this.start, TimelineRange range) {
    end = start + range;
  }

  bool get isNegative => end < start;
  TimelineRange get range => start.to(end);
  set range(TimelineRange value) => end = start + value;

  void flip(){
    var s = start;
    start = end;
    end = s;
  }
}