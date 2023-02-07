import 'package:dartz/dartz.dart';
import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/domain/entities/persons_list_data_with_pagination_info_entity.dart';

abstract class PersonRepository {
  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>>
      getAllPersons(int page);
  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>> searchPerson(
    int page,
    String query,
  );
}
