import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/domain/usecases/get_all_persons.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/person_list_cubit/person_list_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHED_FAILURE_MESSAGE = 'Cache Failure';

class PersonListCubit extends Cubit<PersonState> {
  final GetAllPersons getAllPersons;

  PersonListCubit({required this.getAllPersons}) : super(PersonEmpty());

  int page = 1;

  Future<void> loadPersons() async {
    if (state is PersonLoading) return;

    final currentState = state;
    var oldPersons = <PersonEntity>[];

    if (currentState is PersonLoaded) {
      oldPersons = currentState.personsList;
    }

    emit(PersonLoading(oldPersons, isFirstFetch: page == 1));

    final failureOrPersons = await getAllPersons(PagePersonParams(page: page));
    failureOrPersons
        .fold((error) => PersonError(message: _mapFailureToMessage(error)),
            (character) {
      page++;

      final persons = (state as PersonLoading).oldPersonsList;
      persons.addAll(character);

      emit(PersonLoaded(persons));
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHED_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}