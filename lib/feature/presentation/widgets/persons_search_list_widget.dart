import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_app/core/platform/network_info.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_event.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/search_bloc/search_state.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/search_result_widget.dart';

class PersonsSearchList extends StatefulWidget {
  final String query;
  final Function(String newSuggestionValue)? onAddSuggestions;
  final NetworkInfo networkInfo;
  const PersonsSearchList({
    super.key,
    required this.query,
    required this.networkInfo,
    this.onAddSuggestions,
  });

  @override
  State<PersonsSearchList> createState() => _PersonsSearchListState();
}

class _PersonsSearchListState extends State<PersonsSearchList> {
  late int page = 1;
  late bool isLoading = false;
  final scrollController = ScrollController();
  late bool isNetworkConnected = false;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<PersonSearchBloc>(context, listen: false)
        .add(SearchPersons(page, widget.query));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.hasClients && scrollController.position.atEdge) {
        _checkNetworkConnection();

        if (scrollController.position.pixels != 0 &&
            !isLoading &&
            isNetworkConnected) {
          page++;

          BlocProvider.of<PersonSearchBloc>(context, listen: false)
              .add(SearchPersons(page, widget.query));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setupScrollController(context);

    return BlocBuilder<PersonSearchBloc, PersonSearchState>(
      builder: (context, state) {
        final List<PersonEntity> persons =
            _getSearchedPersons(widget.query, state);
        isLoading = false;

        if (state is PersonSearchLoading && state.isFirstFetch) {
          return _loadingIndicator();
        }

        if (state is PersonSearchLoaded) {
          if (persons.isEmpty) {
            return _showErrorText('No Characters with that name found');
          }

          if (widget.onAddSuggestions != null && page == 1) {
            widget.onAddSuggestions!(widget.query);
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
            if (index < persons.length || isNetworkConnected) {
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

  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _showErrorText(String errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<PersonEntity> _getSearchedPersons(
    String query,
    PersonSearchState state,
  ) {
    List<PersonEntity> persons = [];

    if (isNetworkConnected) {
      isLoading = false;

      if (state is PersonSearchLoading) {
        isLoading = true;
        persons = _goFilterPersonsByQuery(state.oldPersons, query);
      }

      if (state is PersonSearchLoaded) {
        persons = _goFilterPersonsByQuery(state.persons, query);

        if (widget.onAddSuggestions != null && page == 1) {
          widget.onAddSuggestions!(widget.query);
        }
      }
    } else {
      if (state is PersonSearchLoaded) {
        persons = _goFilterPersonsByQuery(state.persons, query);

        if (persons.isNotEmpty &&
            widget.onAddSuggestions != null &&
            page == 1) {
          widget.onAddSuggestions!(widget.query);
        }
      }
    }

    return persons;
  }

  List<PersonEntity> _goFilterPersonsByQuery(
          List<PersonEntity> oldPersons, String query) =>
      oldPersons
          .where((element) => element.name
              .toLowerCase()
              .trim()
              .contains(query.toLowerCase().trim()))
          .toList();

  Future<bool> _checkNetworkConnection() async {
    final currentNetworkConnectionStatus = await widget.networkInfo.isConnected;
    setState(() {
      isNetworkConnected = currentNetworkConnectionStatus;
    });

    return currentNetworkConnectionStatus;
  }
}
