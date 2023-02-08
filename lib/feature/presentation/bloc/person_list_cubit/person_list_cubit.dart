import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/data/models/pagination_list_info_model.dart';
import 'package:rick_and_morty_app/feature/domain/entities/pagination_list_info_entity.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/domain/usecases/get_all_persons.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/person_list_cubit/person_list_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHED_FAILURE_MESSAGE =
    'Cache Failure, please check your connection to Network';

class PersonListCubit extends Cubit<PersonState> {
  final GetAllPersons getAllPersons;

  PersonListCubit({required this.getAllPersons}) : super(PersonEmpty());
  int page = 1;
  late int perPage = 20;

  Future<void> loadPersons() async {
    if (state is PersonLoading) return;

    final currentState = state;
    var oldPersons = <PersonEntity>[];
    late PaginationListInfoEntity oldPersonsDataListInfo =
        const PaginationListInfoModel(count: 0, pages: 0);
    late PaginationListInfoEntity personsDataListInfo =
        const PaginationListInfoModel(count: 0, pages: 0);

    if (currentState is PersonLoaded) {
      oldPersons = currentState.personsList;
      oldPersonsDataListInfo = currentState.personsListInfo;
      page = oldPersons.isNotEmpty ? oldPersons.length ~/ perPage + 1 : 1;
    }

    if (oldPersonsDataListInfo.pages == 0 ||
        personsDataListInfo.pages != oldPersonsDataListInfo.pages) {
      emit(PersonLoading(oldPersons, oldPersonsDataListInfo,
          isFirstFetch: page == 1));
    }

    late bool isExistingNextPageData = oldPersonsDataListInfo.pages == 0 ||
        page <= oldPersonsDataListInfo.pages;

    if (isExistingNextPageData) {
      final failureOrPersons =
          await getAllPersons(PagePersonParams(page: page));

      failureOrPersons.fold(
          (error) => emit(PersonError(message: _mapFailureToMessage(error))),
          (character) {
        final persons = (state as PersonLoading).oldPersonsList;

        persons.addAll(character.data);
        personsDataListInfo = character.info;

        emit(PersonLoaded(
          personsList: persons,
          personsListInfo: personsDataListInfo,
        ));
      });
    } else {
      emit(PersonLoaded(
        personsList: oldPersons,
        personsListInfo: oldPersonsDataListInfo,
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
