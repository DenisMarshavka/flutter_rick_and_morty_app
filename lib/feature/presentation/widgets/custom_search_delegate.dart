import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/persons_search_list_widget.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<String> suggestions;
  late bool isGlobalLoading = false;
  final Function(String newSuggestionValue)? onAddSuggestions;
  final scrollController = ScrollController();

  CustomSearchDelegate({
    required this.suggestions,
    this.onAddSuggestions,
  }) : super(searchFieldLabel: 'Search for characters...');

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
        close(context, null);
      },
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_outlined),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return PersonsSearchList(
      query: query,
      onAddSuggestions: onAddSuggestions,
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
