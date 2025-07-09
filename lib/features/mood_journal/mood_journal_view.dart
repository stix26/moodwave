import 'package:flutter/material.dart';
import 'package:my_app/features/mood_journal/mood_journal_viewmodel.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/button.dart';
import 'package:my_app/shared/card.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class MoodJournalView extends StackedView<MoodJournalViewModel> {
  const MoodJournalView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MoodJournalViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, MoodJournalViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: kcErrorColor),
            kSpaceMedium,
            Text(
              'Could not load journal',
              style: heading3Style(context),
            ),
            kSpaceSmall,
            Text(
              viewModel.modelError.toString(),
              style: errorStyle(context),
              textAlign: TextAlign.center,
            ),
            kSpaceMedium,
            ElevatedButton(
              onPressed: viewModel.loadJournal,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (viewModel.journalEntries.isEmpty) {
      return _buildEmptyState(context, viewModel);
    }

    return Column(
      children: [
        _buildJournalHeader(context, viewModel),
        Expanded(
          child: _buildJournalList(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      BuildContext context, MoodJournalViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: kcPrimaryColor.withOpacity(0.5),
            ),
            kSpaceMedium,
            Text(
              'Your Journal is Empty',
              style: heading2Style(context),
              textAlign: TextAlign.center,
            ),
            kSpaceSmall,
            Text(
              'Start recording your moods to build your emotion journal',
              style: bodyStyle(context),
              textAlign: TextAlign.center,
            ),
            kSpaceLarge,
            CustomButton(
              text: 'Record a Mood',
              onPressed: viewModel.navigateToMoodEntry,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalHeader(
      BuildContext context, MoodJournalViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Mood Journal',
            style: heading2Style(context),
          ),
          kSpaceSmall,
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: viewModel.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search entries...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: kcSecondaryTextColor.withOpacity(0.3),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: viewModel.searchEntries,
                ),
              ),
              kSpaceSmall,
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: viewModel.filterEntries,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('All Entries'),
                  ),
                  const PopupMenuItem(
                    value: 'this_week',
                    child: Text('This Week'),
                  ),
                  const PopupMenuItem(
                    value: 'this_month',
                    child: Text('This Month'),
                  ),
                  const PopupMenuItem(
                    value: 'happy',
                    child: Text('Happy Moods'),
                  ),
                  const PopupMenuItem(
                    value: 'sad',
                    child: Text('Sad Moods'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList(
      BuildContext context, MoodJournalViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.journalEntries.length,
      itemBuilder: (context, index) {
        final entry = viewModel.journalEntries[index];
        final isFirstOfDay = index == 0 ||
            !viewModel.isSameDay(
                entry.timestamp, viewModel.journalEntries[index - 1].timestamp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirstOfDay) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  viewModel.formatDateHeader(entry.timestamp),
                  style: heading3Style(context),
                ),
              ),
            ],
            CustomCard(
              variant: CardVariant.elevated,
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: entry.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          entry.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      kSpaceSmall,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.mood,
                              style:
                                  heading3Style(context).copyWith(fontSize: 18),
                            ),
                            Text(
                              viewModel.formatEntryTime(entry.timestamp),
                              style: bodySmallStyle(context),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => viewModel.showEntryOptions(entry),
                      ),
                    ],
                  ),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    kSpaceMedium,
                    Text(
                      entry.note!,
                      style: bodyStyle(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  MoodJournalViewModel viewModelBuilder(BuildContext context) =>
      MoodJournalViewModel();

  @override
  void onViewModelReady(MoodJournalViewModel viewModel) =>
      viewModel.loadJournal();
}
