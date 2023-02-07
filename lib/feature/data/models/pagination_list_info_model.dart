import 'package:rick_and_morty_app/feature/domain/entities/pagination_list_info_entity.dart';

class PaginationListInfoModel extends PaginationListInfoEntity {
  const PaginationListInfoModel({
    required super.count,
    required super.pages,
  });

  factory PaginationListInfoModel.fromJson(Map<String, dynamic> json) {
    return PaginationListInfoModel(
      count: json['info']['count'],
      pages: json['info']['pages'],
    );
  }

  Map<String, dynamic> toJson() => ({
        'count': count,
        'pages': pages,
      });
}
