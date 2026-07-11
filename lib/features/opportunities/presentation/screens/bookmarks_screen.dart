import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/opportunity_cubit.dart';
import '../../../../core/services/bookmark_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_overlay.dart';
import 'opportunity_feed_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    final state = context.read<OpportunityCubit>().state;
    if (state is! OpportunityLoaded) {
      context.read<OpportunityCubit>().loadOpportunities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        title: const Text('Saved opportunities'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: BookmarkStore.instance,
        builder: (context, _) {
          return BlocBuilder<OpportunityCubit, OpportunityState>(
            builder: (context, state) {
              if (state is OpportunityLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is OpportunityLoaded) {
                final saved = state.opportunities
                    .where((o) => BookmarkStore.instance.contains(o.id))
                    .toList();
                if (saved.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Nothing saved yet',
                    subtitle:
                        'Tap the bookmark icon on any opportunity to save it here',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: saved
                      .asMap()
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: OpportunityCard(
                              opportunity: e.value,
                              color: AppColors.cardColors[
                                  e.key % AppColors.cardColors.length],
                            ).animate().fadeIn(delay: (e.key * 40).ms),
                          ))
                      .toList(),
                );
              }
              return const EmptyStateWidget(
                icon: Icons.bookmark_border_rounded,
                title: 'Nothing saved yet',
                subtitle:
                    'Tap the bookmark icon on any opportunity to save it here',
              );
            },
          );
        },
      ),
    );
  }
}
