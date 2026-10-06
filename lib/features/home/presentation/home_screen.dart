import 'package:aniweb/features/shortcuts/presentation/shortcuts_section.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      'Recently watched',
      'Continue watching',
      'Recently downloaded',
      'Download activity',
      'Storage usage',
    ];
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('AniWeb'),
        ),
        const SliverToBoxAdapter(
          child: ShortcutsSection(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(cards[index], style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
