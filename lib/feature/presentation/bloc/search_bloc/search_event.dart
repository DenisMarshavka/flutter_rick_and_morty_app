import 'package:equatable/equatable.dart';

abstract class PersonSearchEvent extends Equatable {
  const PersonSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchPersons extends PersonSearchEvent {
  final String personQuery;
  final int page;

  const SearchPersons(this.page, this.personQuery);
}
