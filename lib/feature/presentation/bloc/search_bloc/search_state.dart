import 'package:equatable/equatable.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/domain/entities/pagination_list_info_entity.dart';

abstract class PersonSearchState extends Equatable {
  const PersonSearchState();

  @override
  List<Object?> get props => [];
}

class PersonEmpty extends PersonSearchState {}

class PersonSearchLoading extends PersonSearchState {
  final List<PersonEntity> oldPersons;
  final PaginationListInfoEntity oldListInfo;
  final bool isFirstFetch;

  const PersonSearchLoading(this.oldPersons, this.oldListInfo,
      {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldPersons, oldListInfo];
}

class PersonSearchLoaded extends PersonSearchState {
  final List<PersonEntity> persons;
  final PaginationListInfoEntity listInfo;

  const PersonSearchLoaded({
    required this.persons,
    required this.listInfo,
  });

  @override
  List<Object?> get props => [persons, listInfo];
}

class PersonSearchError extends PersonSearchState {
  final String message;

  const PersonSearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
