import 'dart:convert';

import 'package:rick_and_morty_app/core/error/exception.dart';
import 'package:rick_and_morty_app/feature/data/models/person_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const CACHED_PERSONS_LIST_KEY = 'CACHED_PERSONS_LIST';

abstract class PersonLocalDataSource {
  Future<List<PersonModel>> getLastPersonsFromCache();
  Future<void> personToCache(List<PersonModel> persons);
}

class PersonLocalDataSourceImpl implements PersonLocalDataSource {
  final SharedPreferences sharedPreferences;

  PersonLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PersonModel>> getLastPersonsFromCache() async {
    final jsonPersonsList =
        sharedPreferences.getStringList(CACHED_PERSONS_LIST_KEY);

    if (jsonPersonsList?.isNotEmpty == true) {
      return Future.value(jsonPersonsList!
          .map((person) => PersonModel.fromJson(json.decode(person)))
          .toList());
    }

    throw CacheException();
  }

  @override
  Future<void> personToCache(List<PersonModel> persons) async {
    final List<String> jsonPersonsList =
        persons.map((person) => json.encode(person.toJson())).toList();

    sharedPreferences.setStringList(CACHED_PERSONS_LIST_KEY, jsonPersonsList);

    print('Persons to write cache: ${jsonPersonsList.length}');
    await Future.value(jsonPersonsList);
  }
}
