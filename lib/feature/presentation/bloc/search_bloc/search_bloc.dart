import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/domain/usecases/search_person.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_event.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHED_FAILURE_MESSAGE = 'Cache Failure';

class PersonSearchBloc extends Bloc<PersonSearchEvent, PersonSearchState> {
  final SearchPerson searchPerson;

  PersonSearchBloc({
    required this.searchPerson,
  }) : super(PersonEmpty()) {
    on<SearchPersons>(_onEvent);
  }

  FutureOr<void> _onEvent(
      SearchPersons event, Emitter<PersonSearchState> emit) async {
    if (state is PersonSearchLoading) return;

    final currentState = state;
    var oldPersons = <PersonEntity>[];

    if (currentState is PersonSearchLoaded) {
      oldPersons = currentState.persons;

      if (event.page == 1) {
        oldPersons = [];
      }
    }

    emit(PersonSearchLoading(oldPersons, isFirstFetch: event.page == 1));

    final failureOrPerson = await searchPerson(
        SearchPersonParams(page: event.page, query: event.personQuery));

    emit(failureOrPerson.fold(
      (failure) => PersonSearchError(message: _mapFailureToMessage(failure)),
      (searchedPersons) {
        final newPersons = (state as PersonSearchLoading).oldPersons;
        newPersons.addAll(searchedPersons);

        return PersonSearchLoaded(persons: newPersons);
      },
    ));
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
