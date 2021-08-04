class TimelinePosition {
  late final int _basePosition;
  late final double _subPosition;

  TimelinePosition(int basePosition, double subPosition) {
    var f = subPosition.floor();
    _basePosition = basePosition + f;
    _subPosition = subPosition - f;
  }

  TimelinePosition.fromPosition(double position) : this(0, position);

  TimelinePosition.fromDateTime(DateTime dateTime, DateTime zero,
      {double millisecondsParUnit = 1000})
      : this(
            0,
            dateTime.difference(zero).inMicroseconds *
                0.001 /
                millisecondsParUnit);

  int get basePosition => _basePosition;
  double get subPosition => _subPosition;
  double get position => _basePosition + subPosition;

  DateTime getAsDateTime(DateTime zero, {double millisecondsParUnit = 1000}) {
    var ms = (position * millisecondsParUnit * 1000).toInt();
    return zero.add(Duration(microseconds: ms));
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
    return TimelinePosition(
        _basePosition + right._baseRange, _subPosition + right._subRange);
  }

  TimelinePosition operator -(TimelineRange right) {
    return TimelinePosition(
        _basePosition - right._baseRange, _subPosition - right._subRange);
  }
}

class TimelineRange {
  late final int _baseRange;
  late final double _subRange;

  static final TimelineRange zero = TimelineRange(0, 0);

  TimelineRange(int baseRange, double subRange) {
    var f = subRange.floor();
    _baseRange = baseRange + f;
    _subRange = subRange - f;
  }

  TimelineRange.fromRange(double range) : this(0, range);

  TimelineRange.fromDuration(Duration duration,
      {double millisecondsParUnit = 1000})
      : this(0, duration.inMicroseconds * 0.001 / millisecondsParUnit);

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

  TimelinePositionRange(TimelinePosition start, TimelinePosition end) {
    _start = start;
    _end = end;
  }

  TimelinePositionRange.fromRange(TimelinePosition start, TimelineRange range)
      : this(start, start + range);

  TimelinePosition get start => _start;
  TimelinePosition get end => _end;
  bool get isNegative => _end < _start;
  bool get isPositive => _end > _start;
  bool get isZeroLength => _end == _start;
  TimelineRange get range => _start.to(_end);

  TimelinePositionRange fliped() {
    return TimelinePositionRange(_end, _start);
  }

  TimelinePositionRange shifted(TimelineRange shift) {
    return TimelinePositionRange(this._start + shift, this._end + shift);
  }

  TimelinePositionRange moved({
    TimelineRange? start,
    TimelineRange? end,
  }) {
    return TimelinePositionRange(this._start + (start ?? TimelineRange.zero),
        this._end + (end ?? TimelineRange.zero));
  }

  bool operator ==(dynamic right) {
    return right is TimelinePositionRange &&
        _start == right._start &&
        _end == right._end;
  }

  @override
  int get hashCode => _start.hashCode ^ _end.hashCode;
}
