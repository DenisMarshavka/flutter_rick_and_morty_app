import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_event.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_state.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/search_result_widget.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<String> suggestions;
  final Function(String newSuggestionValue)? onAddSuggestions;
  CustomSearchDelegate({
    required this.suggestions,
    this.onAddSuggestions,
  }) : super(searchFieldLabel: 'Search for characters...');

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_outlined),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print('Inside custom search delegate and search query is $query');
    BlocProvider.of<PersonSearchBloc>(context, listen: false)
      ..add(SearchPersons(query));

    return BlocBuilder<PersonSearchBloc, PersonSearchState>(
      builder: (context, state) {
        if (state is PersonSearchLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is PersonSearchLoaded) {
          final person = state.persons;
          if (person.isEmpty) {
            return _showErrorText('No Characters with that name found');
          }

          if (onAddSuggestions != null) onAddSuggestions!(query);
          return Container(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 15),
              itemCount: person.isNotEmpty ? person.length : 0,
              itemBuilder: (context, index) {
                PersonEntity result = person[index];

                return SearchResult(personResult: result);
              },
            ),
          );
        }

        if (state is PersonSearchError) {
          return _showErrorText(state.message);
        }

        return const Center(
          child: Icon(
            Icons.now_wallpaper,
          ),
        );
      },
    );
  }

  Widget _showErrorText(String errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> _filteredSuggestions = query.trim().isEmpty
        ? suggestions
        : suggestions
            .where((element) => element
                .toLowerCase()
                .trim()
                .contains(query.toLowerCase().trim()))
            .toList();

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            query = _filteredSuggestions[index];
            showResults(context);
          },
          child: Text(
            _filteredSuggestions[index],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) =>
          _filteredSuggestions.isNotEmpty ? const Divider() : Container(),
      itemCount: _filteredSuggestions.length,
    );
  }
}
