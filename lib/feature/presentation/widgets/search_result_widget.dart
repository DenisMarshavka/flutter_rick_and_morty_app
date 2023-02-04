import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/presentation/screens/person_detail_screen.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/person_cache_image_widget.dart';

class SearchResult extends StatelessWidget {
  final PersonEntity personResult;

  const SearchResult({super.key, required this.personResult});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonDetailScreen(person: personResult),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Container(
                child: PersonCacheImage(imageUrl: personResult.image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                personResult.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                personResult.location.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
