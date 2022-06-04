part of 'preblo.dart';

@immutable
class PrebloEcho<T> {
  const PrebloEcho(
    this._event, [
    this._crew = const <Symbol, dynamic>{},
  ]);

  final T _event;
  final Crew _crew;

  T get about => _event;

  Crew get attendant => _crew;

  /// [_crew] ignored at [==] operator.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrebloEcho<T> &&
          runtimeType == other.runtimeType &&
          _event == other._event;

  @override
  int get hashCode => _event.hashCode;
}
