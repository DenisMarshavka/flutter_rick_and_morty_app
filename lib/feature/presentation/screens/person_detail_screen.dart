import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/common/app_colors.dart';
import 'package:rick_and_morty_app/feature/domain/entities/person_entity.dart';
import 'package:rick_and_morty_app/feature/presentation/widgets/person_cache_image_widget.dart';

const String ONLINE_STATUS = 'Alive';

class PersonDetailScreen extends StatelessWidget {
  final PersonEntity person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Text(
              person.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              child: PersonCacheImage(
                imageUrl: person.image,
                width: 260,
                height: 260,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: person.status == ONLINE_STATUS
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  person.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            if (person.type.isNotEmpty) ..._buildOption('Type:', person.type),
            ..._buildOption('Gender:', person.gender),
            ..._buildOption(
                'Num of episoces:', person.episode.length.toString()),
            ..._buildOption('Species:', person.species),
            ..._buildOption('Last know location:', person.location.name),
            ..._buildOption('Origin:', person.origin.name),
            ..._buildOption('Was created:', person.created.toString()),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOption(String option, String value) => [
        Text(
          option,
          style: const TextStyle(
            color: AppColors.greyColor,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 12,
        ),
      ];
}
