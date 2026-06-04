import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AplicacionEvent {}

// Llamadas que se le pueden hacer al bloc, para que el bloc cambie su estado
final class AplicacionIniciarPartida extends AplicacionEvent {
  final int duracion;

  AplicacionIniciarPartida({required this.duracion});
}

final class AplicacionFinalizoPartida extends AplicacionEvent {}

final class AplicacionVolverMenuPrincipal extends AplicacionEvent {}

// Estado del bloc, solo puede ser uno a la vez.
sealed class AplicacionState {}

final class AplicacionEsperando extends AplicacionState {}

final class AplicacionJugando extends AplicacionState {
  final int duracion;

  AplicacionJugando({required this.duracion});
}

// El bloc es el encargado de manejar el estado de la aplicacion
class AplicacionBloc extends Bloc<AplicacionEvent, AplicacionState> {
  AplicacionBloc() : super(AplicacionEsperando()) {
    //Inicia con el estado de esperando
    // El bloc escucha los eventos que se le envian, y dependiendo del evento, cambia su estado
    // Se llama con BlocProvider.of<AplicacionBloc>(context).add(AplicacionIniciarPartida(duracion: 60));
    on<AplicacionIniciarPartida>((event, emit) {
      emit(AplicacionJugando(duracion: event.duracion));
      /*
      Luego se puede acceder a la duracion con estado = BlocProvider.of<AplicacionBloc>(context).state y verificando que el estado sea AplicacionJugando
      int duracion = estado.duracion
       */
    });

    on<AplicacionFinalizoPartida>((event, emit) {
      emit(AplicacionEsperando());
    });
  }
}
