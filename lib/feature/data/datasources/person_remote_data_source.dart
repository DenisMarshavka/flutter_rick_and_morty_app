import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:rick_and_morty_app/core/error/exception.dart';
import 'package:rick_and_morty_app/feature/data/models/person_model.dart';

abstract class PersonRemoteDataSource {
  Future<List<PersonModel>> getAllPersons(int page);
  Future<List<PersonModel>> searchPerson(int page, String query);
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  final http.Client client;

  PersonRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PersonModel>> getAllPersons(int page) => _getPersonFromUrl(
      "https://rickandmortyapi.com/api/character/?page=$page");

  @override
  Future<List<PersonModel>> searchPerson(int page, String query) =>
      _getPersonFromUrl(
          "https://rickandmortyapi.com/api/character/?name=$query&page=$page");

  Future<List<PersonModel>> _getPersonFromUrl(String url) async {
    print('URL: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final persons = json.decode(response.body);

      return (persons['results'] as List)
          .map((person) => PersonModel.fromJson(person))
          .toList();
    } else {
      throw ServerException();
    }
  }
}
