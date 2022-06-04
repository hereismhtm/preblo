part of 'preblo.dart';

@immutable
class PrebloUI<T extends Preblo<dynamic, void>> {
  const PrebloUI({
    this.paintOn = const <dynamic>[],
    this.showOn = const <dynamic>[],
  });

  final List<dynamic> paintOn;
  final List<dynamic> showOn;

  Widget brush() {
    return BlocConsumer<T, PrebloEcho<dynamic>>(
      listenWhen: (PrebloEcho<dynamic> previous, PrebloEcho<dynamic> current) {
        return showOn.isNotEmpty && showOn.contains(current.about);
      },
      listener: (BuildContext context, PrebloEcho<dynamic> echo) {
        BlocProvider.of<T>(context)._dropInUI(context, echo.about);
      },
      buildWhen: (PrebloEcho<dynamic> previous, PrebloEcho<dynamic> current) {
        if (paintOn.isNotEmpty) {
          return paintOn.contains(current.about);
        } else {
          return true;
        }
      },
      builder: (BuildContext context, PrebloEcho<dynamic> echo) {
        final preblo = BlocProvider.of<T>(context);

        if (paintOn.isNotEmpty && !paintOn.contains(echo.about)) {
          /// Catch! it is NOT a valid echo (bypassed buildWhen parameter), so:
          return preblo._dropInUI(context, paintOn.first, forced: true);
        }

        /// Only now ... it is a valid echo:
        return preblo._dropInUI(context, echo.about);
      },
    );
  }
}
