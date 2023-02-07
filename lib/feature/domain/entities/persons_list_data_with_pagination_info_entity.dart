import 'package:equatable/equatable.dart';
import 'package:rick_and_morty_app/feature/data/models/pagination_list_info_model.dart';
import 'package:rick_and_morty_app/feature/data/models/person_model.dart';

class PersonsListDataWithPaginationInfoEntity extends Equatable {
  late PaginationListInfoModel info;
  late List<PersonModel> data;

  PersonsListDataWithPaginationInfoEntity({
    required this.info,
    required this.data,
  });

  @override
  List<Object?> get props => [
        info,
        data,
      ];
}
