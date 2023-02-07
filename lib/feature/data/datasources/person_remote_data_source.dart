import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:rick_and_morty_app/core/error/exception.dart';
import 'package:rick_and_morty_app/feature/data/models/persons_list_data_with_pagination_info_model.dart';

abstract class PersonRemoteDataSource {
  Future<PersonsListDataWithPaginationInfoModel> getAllPersons(int page);
  Future<PersonsListDataWithPaginationInfoModel> searchPerson(
      int page, String query);
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  final http.Client client;

  PersonRemoteDataSourceImpl({required this.client});

  @override
  Future<PersonsListDataWithPaginationInfoModel> getAllPersons(int page) =>
      _getPersonFromUrl(
          "https://rickandmortyapi.com/api/character/?page=$page");

  @override
  Future<PersonsListDataWithPaginationInfoModel> searchPerson(
          int page, String query) =>
      _getPersonFromUrl(
          "https://rickandmortyapi.com/api/character/?name=$query&page=$page");

  Future<PersonsListDataWithPaginationInfoModel> _getPersonFromUrl(
      String url) async {
    print('URL: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return PersonsListDataWithPaginationInfoModel.fromJson(data);
    } else {
      throw ServerException();
    }
  }
}
