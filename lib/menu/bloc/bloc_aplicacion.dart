import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AplicacionEvent {}

final class AplicacionIniciarPartida extends AplicacionEvent {
  final int duracion;

  AplicacionIniciarPartida({required this.duracion});
}

final class AplicacionFinalizoPartida extends AplicacionEvent {}

final class AplicacionVolverMenuPrincipal extends AplicacionEvent {}

sealed class AplicacionState {}

final class AplicacionEsperando extends AplicacionState {}

final class AplicacionJugando extends AplicacionState {
  final int duracion;

  AplicacionJugando({required this.duracion});
}

class AplicacionBloc extends Bloc<AplicacionEvent, AplicacionState> {
  AplicacionBloc() : super(AplicacionEsperando()) {
    on<AplicacionIniciarPartida>((event, emit) {
      emit(AplicacionJugando(duracion: event.duracion));
    });

    on<AplicacionFinalizoPartida>((event, emit) {
      emit(AplicacionEsperando());
    });
  }
}
