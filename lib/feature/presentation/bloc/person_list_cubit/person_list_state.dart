import 'package:equatable/equatable.dart';
import 'package:rick_and_morty_app/feature/domain/entities/pagination_list_info_entity.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';

abstract class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object?> get props => [];
}

class PersonEmpty extends PersonState {}

class PersonLoading extends PersonState {
  final List<PersonEntity> oldPersonsList;
  final PaginationListInfoEntity oldPersonsListInfo;
  final bool isFirstFetch;

  const PersonLoading(this.oldPersonsList, this.oldPersonsListInfo,
      {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldPersonsList];
}

class PersonLoaded extends PersonState {
  final List<PersonEntity> personsList;
  final PaginationListInfoEntity personsListInfo;

  const PersonLoaded({
    required this.personsList,
    required this.personsListInfo,
  });

  @override
  List<Object?> get props => [personsList, personsListInfo];
}

class PersonError extends PersonState {
  final String message;

  const PersonError({required this.message});

  @override
  List<Object?> get props => [message];
}
