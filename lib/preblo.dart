library preblo;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'preblo_echo.dart';
part 'preblo_ui.dart';

typedef Crew = Map<Symbol, dynamic>;

abstract class Preblo<Event, State> extends Cubit<PrebloEcho<Event>> {
  /// Cubit will emitted the initial event state (as PrebloEcho<Event>), and
  /// user interface should react (via PrebloUI<T extends Preblo>) to that
  /// event independently by returning the predefined widget related to
  /// (at runways getter).
  Preblo(Event initialEvent, State initialState, {Crew? crew})
      : super(
          PrebloEcho<Event>(
            initialEvent,
            crew ?? const <Symbol, dynamic>{},
          ),
        ) {
    /// Set initial Preblo state.
    _state = initialState;

    /// Method `takeoff` called here to execute any potential business logic
    /// for the initial event.
    takeoff(initialEvent, crew: crew);
  }

  late final State _state;

  State get memory => _state;

  Map<Event, List<Function>> get runways;

  @nonVirtual
  void takeoff(
    Event event, {
    Crew? crew,
    void Function()? next,
    bool bypassLogic = false,
  }) {
    final echo = PrebloEcho<Event>(event, crew ?? const <Symbol, dynamic>{});

    super.emit(echo);
    final businessLogic = _runwayOf(event, true);
    if (businessLogic == na || bypassLogic) return;

    debugPrint('Business logic> $event  ${crew ?? <Symbol, dynamic>{}}');
    final dynamic goNext = Function.apply(
      businessLogic,
      null,
      crew ?? <Symbol, dynamic>{},
    );

    if (next != null && (goNext is bool?) && (goNext ?? false)) next();
  }

  Widget _dropInUI(BuildContext context, Event event, {bool forced = false}) {
    final presentation = _runwayOf(event, false);
    if (presentation == na) return const SizedBox();

    if (!forced) debugPrint('UI presentation> $event');
    final widget = Function.apply(
      presentation,
      <dynamic>[context],
      <Symbol, dynamic>{},
    ) as Widget?;

    return widget ?? const SizedBox();
  }

  Function _runwayOf(Event event, bool isLogicLayer) {
    var error = false;
    final bothLayers = runways.entries.firstWhere(
      (MapEntry<Event, List<Function>> element) => element.key == event,
      orElse: () {
        error = true;
        return MapEntry<Event, List<Function>>(event, []);
      },
    ).value;

    if (error) {
      throw Exception(
        "Preblo: Event '$event' "
        "not matching any map entry of '$runtimeType' runways.",
      );
    }

    final len = bothLayers.length;
    if (isLogicLayer) {
      return len > 0 && len <= 2 ? bothLayers[0] : na;
    } else {
      return len == 2 ? bothLayers[1] : na;
    }
  }

  /// Just an alias for () {}.
  @protected
  @nonVirtual
  void na() {}

  @protected
  @nonVirtual
  @override
  void emit(PrebloEcho<Event> state) {
    throw Exception(
      "Preblo: Calling a protected method 'emit' "
      "outside its class '$runtimeType'.",
    );
  }

  @override
  Future<void> close() async {
    await super.close();
    debugPrint("Preblo: Method 'close' of '$runtimeType' called.");
  }
}
