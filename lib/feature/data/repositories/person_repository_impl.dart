import 'package:dartz/dartz.dart';
import 'package:rick_and_morty_app/core/error/exception.dart';
import 'package:rick_and_morty_app/core/platform/network_info.dart';
import 'package:rick_and_morty_app/feature/data/datasources/person_local_data_source.dart';
import 'package:rick_and_morty_app/feature/data/datasources/person_remote_data_source.dart';
import 'package:rick_and_morty_app/core/error/failure.dart';
import 'package:rick_and_morty_app/feature/data/models/pagination_list_info_model.dart';
import 'package:rick_and_morty_app/feature/data/models/persons_list_data_with_pagination_info_model.dart';
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
      _getPersons(() => remoteDataSource.searchPerson(page, query), true);

  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>> _getPersons(
      Future<PersonsListDataWithPaginationInfoEntity> Function() getPersons,
      [bool isSearchFetch = false]) async {
    if (await networkInfo.isConnected) {
      try {
        final oldCache = await _getLastPersonsListDataFromCache();
        final remoteDataPersons = await getPersons();
        final newCache = PersonsListDataWithPaginationInfoModel(
          data: const [],
          info: const PaginationListInfoModel(count: 0, pages: 0),
        );

        if (isSearchFetch) return Right(remoteDataPersons);
        return oldCache.fold((error) {
          // If old Cache Data is Empty
          localDataSource.personToCache(remoteDataPersons);
          return Right(remoteDataPersons);
        }, (character) {
          if (character.data.isNotEmpty) {
            final newData = remoteDataPersons.data
                .where((item) => character.data
                    .where((oldItem) => item.id == oldItem.id)
                    .isEmpty)
                .toList();

            newCache.data = [...character.data, ...newData];
            newCache.info = remoteDataPersons.info;

            localDataSource.personToCache(newCache);
            return Right(remoteDataPersons);
          }

          localDataSource.personToCache(remoteDataPersons);
          return Right(remoteDataPersons);
        });
      } on ServerException {
        return Left(ServerFailure());
      }
    }

    return _getLastPersonsListDataFromCache();
  }

  Future<Either<Failure, PersonsListDataWithPaginationInfoEntity>>
      _getLastPersonsListDataFromCache() async {
    try {
      final locationPerson =
          await localDataSource.getLastPersonsListDataFromCache();

      return Right(locationPerson);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
