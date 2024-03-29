import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/core/usecases/usecase.dart';
import 'package:rick_and_morty_app/feature/domain/entities/persons_list_data_with_pagination_info_entity.dart';
import 'package:rick_and_morty_app/feature/domain/repositories/person_repository.dart';

class GetAllPersons
    extends UseCase<PersonsListDataWithPaginationInfoEntity, PagePersonParams> {
  final PersonRepository personRepository;

  GetAllPersons(this.personRepository);

  @override
  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>> call(
      PagePersonParams params) async {
    return await personRepository.getAllPersons(params.page);
  }
}

class PagePersonParams extends Equatable {
  final int page;

  const PagePersonParams({required this.page});

  @override
  List<Object?> get props => [page];
}
