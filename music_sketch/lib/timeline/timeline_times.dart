class TimelinePosition {
  late final int _basePosition;
  late final double _subPosition;

  TimelinePosition({int basePosition = 0, double subPosition = 0}) {
    var f = subPosition.floor();
    _basePosition = basePosition + f;
    _subPosition = subPosition - f;
  }

  TimelinePosition.fromPosition(double position) {
    var f = position.floor();
    _basePosition = f;
    _subPosition = position - f;
  }

  TimelinePosition.fromDateTime(DateTime dateTime, DateTime zero,
      {double millisecondsParUnit = 1000}) {
    var d = dateTime.difference(zero);
    var f = (d.inMicroseconds * 0.001 / millisecondsParUnit).floor();
    _basePosition = f;
    _subPosition = position - f;
  }

  int get basePosition => _basePosition;
  double get subPosition => _subPosition;
  double get position => _basePosition + subPosition;

  DateTime getAsDateTime(DateTime zero, {double millisecondsParUnit = 1000}) {
    var ms = (position * millisecondsParUnit * 1000).toInt();
    return zero.add(Duration(microseconds: ms));
  }

  TimelineRange to(TimelinePosition to) {
    return TimelineRange(
        baseRange: to._basePosition - _basePosition,
        subRange: to._subPosition - _subPosition);
  }

  TimelineRange from(TimelinePosition from) {
    return TimelineRange(
        baseRange: _basePosition - from._basePosition,
        subRange: _subPosition - from._subPosition);
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
    return TimelinePosition(
        basePosition: _basePosition + right._baseRange,
        subPosition: _subPosition + right._subRange);
  }

  TimelinePosition operator -(TimelineRange right) {
    return TimelinePosition(
        basePosition: _basePosition - right._baseRange,
        subPosition: _subPosition - right._subRange);
  }
}

class TimelineRange {
  late final int _baseRange;
  late final double _subRange;

  static final TimelineRange zero = TimelineRange();

  TimelineRange({int baseRange = 0, double subRange = 0}) {
    var f = range.floor();
    _baseRange = baseRange + f;
    _subRange = range - f;
  }

  TimelineRange.fromRange(double range) {
    var f = range.floor();
    _baseRange = f;
    _subRange = range - f;
  }

  TimelineRange.fromDuration(Duration duration,
      {double millisecondsParUnit = 1000}) {
    var range = duration.inMicroseconds * 0.001 / millisecondsParUnit;
    var f = range.floor();
    _baseRange = f;
    _subRange = range - f;
  }

  int get baseRange => _baseRange;
  double get subRange => _subRange;
  double get range => baseRange + subRange;

  Duration getAsDuration({double millisecondsParUnit = 1000}) {
    var ms = (range * millisecondsParUnit * 1000).toInt();
    return Duration(microseconds: ms);
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
  late final TimelinePosition _start;
  late final TimelinePosition _end;

  TimelinePositionRange(this._start, this._end);
  TimelinePositionRange.fromRange(this._start, TimelineRange range) {
    _end = _start + range;
  }

  TimelinePosition get start => _start;
  TimelinePosition get end => _end;
  bool get isNegative => _end < _start;
  TimelineRange get range => _start.to(_end);

  TimelinePositionRange flip() {
    return TimelinePositionRange(_end, _start);
  }

  TimelinePositionRange shift(TimelineRange shift) {
    return set(start: this._start + shift, end: this._end + shift);
  }

  TimelinePositionRange move({
    TimelineRange? start,
    TimelineRange? end,
  }) {
    return set(
        start: this._start + (start ?? TimelineRange.zero),
        end: this._end + (end ?? TimelineRange.zero));
  }

  TimelinePositionRange set({TimelinePosition? start, TimelinePosition? end}) {
    return TimelinePositionRange(start ?? this._start, end ?? this._end);
  }
}
