import 'package:equatable/equatable.dart';

class PaginationListInfoEntity extends Equatable {
  final int count;
  final int pages;

  const PaginationListInfoEntity({
    required this.count,
    required this.pages,
  });

  @override
  List<Object?> get props => [
        count,
        pages,
      ];
}
