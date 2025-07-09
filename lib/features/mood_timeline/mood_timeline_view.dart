import 'package:flutter/material.dart';
import 'package:my_app/features/mood_timeline/mood_timeline_viewmodel.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class MoodTimelineView extends StackedView<MoodTimelineViewModel> {
  const MoodTimelineView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MoodTimelineViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, MoodTimelineViewModel viewModel) {
    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: kcErrorColor),
            kSpaceMedium,
            Text(
              'Could not load your mood timeline',
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
              onPressed: viewModel.loadMoodEntries,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (viewModel.moodEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline,
                size: 64, color: kcPrimaryColor.withOpacity(0.5)),
            kSpaceMedium,
            Text(
              'No mood entries yet',
              style: heading2Style(context),
            ),
            kSpaceSmall,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Start tracking your mood to see your emotional journey',
                style: bodyStyle(context),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildTimelineHeader(context, viewModel),
        Expanded(
          child: _buildMoodTimeline(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildTimelineHeader(
      BuildContext context, MoodTimelineViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Mood Timeline',
            style: heading2Style(context),
          ),
          kSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: viewModel.previousWeek,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              Text(
                viewModel.timeRangeText,
                style: bodyStyle(context).copyWith(fontWeight: FontWeight.w500),
              ),
              TextButton.icon(
                onPressed: viewModel.nextWeek,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTimeline(
      BuildContext context, MoodTimelineViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: viewModel.moodEntries.length,
      itemBuilder: (context, index) {
        final entry = viewModel.moodEntries[index];
        final isLastItem = index == viewModel.moodEntries.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and circle
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: entry.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if (!isLastItem)
                    Container(
                      width: 2,
                      height: 80,
                      color: kcSecondaryTextColor.withOpacity(0.2),
                    ),
                ],
              ),
            ),
            kSpaceSmall,
            // Entry content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        viewModel.formatEntryTime(entry),
                        style: bodySmallStyle(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        entry.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          entry.color.withOpacity(0.8),
                          entry.color.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: entry.color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.mood,
                          style: heading3Style(context).copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        if (entry.note != null && entry.note!.isNotEmpty) ...[
                          kSpaceSmall,
                          Text(
                            entry.note!,
                            style: bodyStyle(context).copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  MoodTimelineViewModel viewModelBuilder(BuildContext context) =>
      MoodTimelineViewModel();

  @override
  void onViewModelReady(MoodTimelineViewModel viewModel) =>
      viewModel.loadMoodEntries();
}
