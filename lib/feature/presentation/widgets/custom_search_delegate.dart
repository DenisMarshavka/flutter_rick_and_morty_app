import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_event.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_state.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/search_result_widget.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<String> suggestions;
  late int page = 0;
  final Function(String newSuggestionValue)? onAddSuggestions;
  final scrollController = ScrollController();

  CustomSearchDelegate({
    required this.suggestions,
    this.page = 0,
    this.onAddSuggestions,
  }) : super(searchFieldLabel: 'Search for characters...');

  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        page++;

        if (scrollController.position.pixels != 0) {
          BlocProvider.of<PersonSearchBloc>(context, listen: false)
            ..add(SearchPersons(page, query));
        }
      }
    });
  }

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
      onPressed: () {
        page = 1;
        close(context, null);
      },
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_outlined),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(
        'Inside custom search delegate and search query is $query, and page $page');
    BlocProvider.of<PersonSearchBloc>(context, listen: false)
      ..add(SearchPersons(page, query));
    setupScrollController(context);

    return BlocBuilder<PersonSearchBloc, PersonSearchState>(
      builder: (context, state) {
        List<PersonEntity> persons = [];
        bool isLoading = false;

        if (state is PersonSearchLoading && state.isFirstFetch) {
          return _loadingIndicator();
        }
        if (state is PersonSearchLoading) {
          isLoading = true;
          persons = state.oldPersons;
        }

        if (state is PersonSearchLoaded) {
          persons = state.persons;

          if (persons.isEmpty) {
            return _showErrorText('No Characters with that name found');
          }

          if (onAddSuggestions != null && page == 1) {
            onAddSuggestions!(query);
          }
        }

        if (state is PersonSearchError) {
          return _showErrorText(state.message);
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 15),
          itemCount: persons.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < persons.length) {
              return SearchResult(personResult: persons[index]);
            } else {
              Timer(const Duration(milliseconds: 30), () {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });

              return _loadingIndicator();
            }
          },
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
            page = 1;

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

  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
