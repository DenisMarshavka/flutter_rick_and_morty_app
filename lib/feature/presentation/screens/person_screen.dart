import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/custom_search_delegate.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/persons_list_widget.dart';

class HomeScreen extends StatelessWidget {
  late List<String> searchSuggestions = [
    'Rick',
    'Morty',
    'Summer',
    'Beth',
    'Jerry',
    'Zombo-Kurka',
    'Zubozavr',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(
                    suggestions: searchSuggestions,
                    onAddSuggestions: _handleAddSuggestions,
                  ));
            },
            icon: const Icon(Icons.search),
            color: Colors.white,
          ),
        ],
      ),
      body: PersonsList(),
    );
  }

  void _handleAddSuggestions(String newSuggestionValue) {
    if (searchSuggestions.indexWhere((element) =>
            element.toLowerCase().trim() ==
            newSuggestionValue.toLowerCase().trim()) ==
        -1) {
      searchSuggestions.add(newSuggestionValue.trim());
    }
  }
}
