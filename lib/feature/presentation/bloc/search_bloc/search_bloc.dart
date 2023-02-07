import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/data/models/pagination_list_info_model.dart';
import 'package:rick_and_morty_app/feature/domain/entities/pagination_list_info_entity.dart';
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
    late PaginationListInfoEntity oldPersonsDataListInfo =
        const PaginationListInfoModel(count: 0, pages: 0);
    late PaginationListInfoEntity personsDataListInfo =
        const PaginationListInfoModel(count: 0, pages: 0);

    if (currentState is PersonSearchLoaded) {
      oldPersons = currentState.persons;
      oldPersonsDataListInfo = currentState.listInfo;

      if (event.page == 1) {
        oldPersons = [];
        oldPersonsDataListInfo = const PaginationListInfoModel(
          count: 0,
          pages: 0,
        );
      }
    }

    if (oldPersonsDataListInfo.pages == 0 ||
        event.page <= oldPersonsDataListInfo.pages) {
      emit(PersonSearchLoading(
        oldPersons,
        oldPersonsDataListInfo,
        isFirstFetch: event.page == 1,
      ));

      final failureOrPerson = await searchPerson(
          SearchPersonParams(page: event.page, query: event.personQuery));

      emit(failureOrPerson.fold(
        (failure) => PersonSearchError(message: _mapFailureToMessage(failure)),
        (searchedPersons) {
          final newPersonsData = (state as PersonSearchLoading).oldPersons;
          newPersonsData.addAll(searchedPersons.data);
          personsDataListInfo = searchedPersons.info;

          return PersonSearchLoaded(
            persons: newPersonsData,
            listInfo: personsDataListInfo,
          );
        },
      ));
    }
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
