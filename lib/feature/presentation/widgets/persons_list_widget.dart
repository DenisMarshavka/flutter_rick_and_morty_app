import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_app/core/platform/network_info.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/person_list_cubit/person_list_cubit.dart';
import 'package:rick_and_morty_app/feature/presentation/bloc/person_list_cubit/person_list_state.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/person_card_widget.dart';

class PersonsList extends StatelessWidget {
  final scrollController = ScrollController();
  late NetworkInfo networkInfo;
  PersonsList({super.key, required this.networkInfo});

  void setupScrollController(BuildContext context) {
    scrollController.addListener(() async {
      if (scrollController.hasClients && scrollController.position.atEdge) {
        final bool isNetworkConnected = await networkInfo.isConnected;

        if (scrollController.position.pixels != 0 && isNetworkConnected) {
          BlocProvider.of<PersonListCubit>(context, listen: false)
              .loadPersons();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setupScrollController(context);

    return BlocBuilder<PersonListCubit, PersonState>(
      builder: ((context, state) {
        List<PersonEntity> persons = [];
        bool isLoading = false;

        if (state is PersonLoading && state.isFirstFetch) {
          return _loadingIndicator();
        }

        if (state is PersonLoading) {
          persons = state.oldPersonsList;
          isLoading = true;
        }

        if (state is PersonLoaded) {
          persons = state.personsList;
        }

        if (state is PersonError) {
          return Center(
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 15),
          controller: scrollController,
          itemBuilder: (context, index) {
            if (index < persons.length) {
              return PersonCard(person: persons[index]);
            } else {
              Timer(const Duration(milliseconds: 30), () {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });
              return _loadingIndicator();
            }
          },
          separatorBuilder: (context, index) {
            return Divider(
              color: Colors.grey[400],
            );
          },
          itemCount: persons.length + (isLoading ? 1 : 0),
        );
      }),
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
