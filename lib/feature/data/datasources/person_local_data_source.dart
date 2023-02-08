import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rick_and_morty_app/core/error/exception.dart';
import 'package:rick_and_morty_app/feature/data/models/pagination_list_info_model.dart';
import 'package:rick_and_morty_app/feature/data/models/person_model.dart';
import 'package:rick_and_morty_app/feature/data/models/persons_list_data_with_pagination_info_model.dart';
import 'package:rick_and_morty_app/feature/domain/entities/persons_list_data_with_pagination_info_entity.dart';

const CACHED_PERSONS_LIST_KEY = 'CACHED_PERSONS_LIST';
const CACHED_PERSONS_LIST_INFO_KEY = 'CACHED_PERSONS_LIST_INFO';

abstract class PersonLocalDataSource {
  Future<PersonsListDataWithPaginationInfoEntity>
      getLastPersonsListDataFromCache();
  Future<void> personToCache(
      PersonsListDataWithPaginationInfoEntity personsListData);
}

class PersonLocalDataSourceImpl implements PersonLocalDataSource {
  final SharedPreferences sharedPreferences;

  PersonLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<PersonsListDataWithPaginationInfoEntity>
      getLastPersonsListDataFromCache() async {
    final jsonPersonsList =
        sharedPreferences.getStringList(CACHED_PERSONS_LIST_KEY);
    final jsonPersonsListInfo =
        sharedPreferences.getString(CACHED_PERSONS_LIST_INFO_KEY);
    late PersonsListDataWithPaginationInfoEntity result =
        PersonsListDataWithPaginationInfoModel(
      data: const [],
      info: const PaginationListInfoModel(
        count: 0,
        pages: 0,
      ),
    );

    if (jsonPersonsList?.isNotEmpty == true) {
      result.data = jsonPersonsList!
          .map((person) => PersonModel.fromJson(json.decode(person)))
          .toList();

      if (jsonPersonsListInfo?.isNotEmpty == true) {
        result.info =
            PaginationListInfoModel.fromJson(json.decode(jsonPersonsListInfo!));

        return Future.value(result);
      }
    }

    throw CacheException();
  }

  @override
  Future<void> personToCache(
      PersonsListDataWithPaginationInfoEntity personsListData) async {
    final List<String> jsonPersonsList = personsListData.data
        .map((person) => json.encode(person.toJson()))
        .toList();
    final String jsonPersonsListInfo = json.encode(personsListData);

    sharedPreferences.setStringList(CACHED_PERSONS_LIST_KEY, jsonPersonsList);
    sharedPreferences.setString(
        CACHED_PERSONS_LIST_INFO_KEY, jsonPersonsListInfo);

    print('Persons to write cache: ${jsonPersonsList.length}');
    await Future.value(jsonPersonsList);
  }
}
