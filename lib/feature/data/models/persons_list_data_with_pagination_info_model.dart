import 'package:rick_and_morty_app/feature/data/models/pagination_list_info_model.dart';
import 'package:rick_and_morty_app/feature/data/models/person_model.dart';
import 'package:rick_and_morty_app/feature/domain/entities/persons_list_data_with_pagination_info_entity.dart';

class PersonsListDataWithPaginationInfoModel
    extends PersonsListDataWithPaginationInfoEntity {
  PersonsListDataWithPaginationInfoModel({
    required super.data,
    required super.info,
  });

  factory PersonsListDataWithPaginationInfoModel.fromJson(
      Map<String, dynamic> json) {
    return PersonsListDataWithPaginationInfoModel(
        data: (json['results'] as List)
            .map((person) => PersonModel.fromJson(person))
            .toList(),
        info: PaginationListInfoModel.fromJson(json));
  }

  Map<String, dynamic> toJson() => ({
        'data': data,
        'info': info,
      });
}
