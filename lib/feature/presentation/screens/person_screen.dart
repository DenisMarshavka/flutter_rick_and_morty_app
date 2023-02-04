import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/custom_search_delegate.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/persons_list_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
            icon: const Icon(Icons.search),
            color: Colors.white,
          ),
        ],
      ),
      body: PersonsList(),
    );
  }
}
