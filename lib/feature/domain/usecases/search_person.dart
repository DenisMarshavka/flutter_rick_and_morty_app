import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:rick_and_morty_app/core/usecases/usecase.dart';
import 'package:rick_and_morty_app/feature/domain/repositories/person_repository.dart';
import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';

class SearchPerson extends UseCase<List<PersonEntity>, SearchPersonParams> {
  final PersonRepository personRepository;

  SearchPerson(this.personRepository);

  @override
  Future<Either<Failure, List<PersonEntity>>> call(
      SearchPersonParams params) async {
    return await personRepository.searchPerson(params.page, params.query);
  }
}

class SearchPersonParams extends Equatable {
  final String query;
  final int page;

  const SearchPersonParams({required this.page, required this.query});

  @override
  List<Object?> get props => [query, page];
}
