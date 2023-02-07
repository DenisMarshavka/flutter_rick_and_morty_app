import 'package:dartz/dartz.dart';
import 'package:rick_and_morty_app/core/error/exception.dart';
import 'package:rick_and_morty_app/core/platform/network_info.dart';
import 'package:rick_and_morty_app/feature/data/datasources/person_local_data_source.dart';
import 'package:rick_and_morty_app/feature/data/datasources/person_remote_data_source.dart';
import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/domain/entities/persons_list_data_with_pagination_info_entity.dart';
import 'package:rick_and_morty_app/feature/domain/repositories/person_repository.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonRemoteDataSource remoteDataSource;
  final PersonLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PersonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>>
      getAllPersons(int page) =>
          _getPersons(() => remoteDataSource.getAllPersons(page));

  @override
  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>> searchPerson(
    int page,
    String query,
  ) =>
      _getPersons(() => remoteDataSource.searchPerson(page, query));

  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>> _getPersons(
      Future<PersonsListDataWithPaginationInfoEntity> Function()
          getPersons) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteDataPersons = await getPersons();
        localDataSource.personToCache(remoteDataPersons);

        return Right(remoteDataPersons);
      } on ServerException {
        return Left(ServerFailure());
      }
    }

    try {
      final locationPerson =
          await localDataSource.getLastPersonsListDataFromCache();
      return Right(locationPerson);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
