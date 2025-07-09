import 'package:flutter/material.dart';
import 'package:my_app/features/home/home_viewmodel.dart';
import 'package:my_app/models/mood_entry.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/button.dart';
import 'package:my_app/shared/card.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, viewModel),
            Expanded(
              child: _buildContent(context, viewModel),
            ),
            _buildBottomNav(context, viewModel),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.navigateToMoodEntry,
        backgroundColor: kcPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: kcPrimaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MoodPalette',
                style: heading2Style(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.insights, color: Colors.white),
                onPressed: viewModel.navigateToInsights,
              ),
            ],
          ),
          kSpaceSmall,
          Text(
            viewModel.greetingMessage,
            style: bodyStyle(context).copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: kcErrorColor),
              kSpaceMedium,
              Text(
                'Something went wrong',
                style: heading3Style(context),
                textAlign: TextAlign.center,
              ),
              kSpaceSmall,
              Text(
                viewModel.modelError.toString(),
                style: errorStyle(context),
                textAlign: TextAlign.center,
              ),
              kSpaceMedium,
              CustomButton(
                text: 'Try Again',
                onPressed: viewModel.initialize,
              ),
            ],
          ),
        ),
      );
    }

    // Show different content based on selected tab
    switch (viewModel.selectedTabIndex) {
      case 0:
        return _buildDashboard(context, viewModel);
      case 1:
        return viewModel.moodTimelineView;
      case 2:
        return viewModel.moodJournalView;
      default:
        return _buildDashboard(context, viewModel);
    }
  }

  Widget _buildDashboard(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.moodEntries.isEmpty) {
      return _buildEmptyState(context, viewModel);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: heading3Style(context),
          ),
          kSpaceMedium,
          _buildMoodSelector(context, viewModel),
          kSpaceMedium,
          Text(
            'Your Mood Journey',
            style: heading3Style(context),
          ),
          kSpaceSmall,
          _buildMoodChart(context, viewModel),
          kSpaceMedium,
          Text(
            'Recent Entries',
            style: heading3Style(context),
          ),
          kSpaceSmall,
          ...viewModel.recentEntries
              .map((entry) => _buildMoodEntryCard(context, viewModel, entry)),
          if (viewModel.hasCoachInsight) ...[
            kSpaceMedium,
            _buildCoachInsightCard(context, viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kcPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_emotions_outlined,
                size: 60,
                color: kcPrimaryColor,
              ),
            ),
            kSpaceMedium,
            Text(
              'Welcome to MoodPalette!',
              style: heading2Style(context),
              textAlign: TextAlign.center,
            ),
            kSpaceSmall,
            Text(
              'Start tracking your mood with beautiful colors to visualize your emotional journey',
              style: bodyStyle(context),
              textAlign: TextAlign.center,
            ),
            kSpaceLarge,
            CustomButton(
              text: 'Record Your First Mood',
              onPressed: viewModel.navigateToMoodEntry,
              variant: ButtonVariant.primary,
              isFullWidth: true,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, HomeViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.filled,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.quickMoodOptions.map((option) {
                return GestureDetector(
                  onTap: () => viewModel.quickSelectMood(
                    option['emoji'] as String,
                    option['text'] as String,
                    option['hue'] as double,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HSLColor.fromAHSL(
                        1.0,
                        option['hue'] as double,
                        0.7,
                        0.5,
                      ).toColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          option['emoji'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                        kSpaceSmall,
                        Text(
                          option['text'] as String,
                          style: bodySmallStyle(context),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          kSpaceMedium,
          CustomButton(
            text: 'Add Detailed Entry',
            variant: ButtonVariant.primary,
            icon: Icons.edit,
            isFullWidth: true,
            onPressed: viewModel.navigateToMoodEntry,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context, HomeViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last 7 Days',
                style: bodyStyle(context).copyWith(fontWeight: FontWeight.w500),
              ),
              TextButton(
                onPressed: viewModel.navigateToTimeline,
                child: const Text('See All'),
              ),
            ],
          ),
          kSpaceSmall,
          SizedBox(
            height: 150,
            child: viewModel.buildMoodChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEntryCard(
      BuildContext context, HomeViewModel viewModel, MoodEntry entry) {
    return CustomCard(
      variant: CardVariant.outlined,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => viewModel.viewMoodEntryDetails(entry),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: entry.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          kSpaceSmall,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.mood,
                  style: heading3Style(context).copyWith(fontSize: 18),
                ),
                if (entry.note != null && entry.note!.isNotEmpty)
                  Text(
                    entry.note!,
                    style: bodySmallStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                viewModel.formatEntryTime(entry),
                style: bodySmallStyle(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoachInsightCard(BuildContext context, HomeViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kcSecondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: kcSecondaryColor,
                ),
              ),
              kSpaceSmall,
              Expanded(
                child: Text(
                  'AI Coach Insight',
                  style: heading3Style(context),
                ),
              ),
            ],
          ),
          kSpaceMedium,
          Text(
            viewModel.coachInsight,
            style: bodyStyle(context),
          ),
          if (viewModel.coachSuggestion != null) ...[
            kSpaceMedium,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kcPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: kcPrimaryColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try This',
                    style: bodyStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: kcPrimaryColor,
                    ),
                  ),
                  kSpaceSmall,
                  Text(
                    viewModel.coachSuggestion!,
                    style: bodyStyle(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, HomeViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home,
              label: 'Home',
              isSelected: viewModel.selectedTabIndex == 0,
              onTap: () => viewModel.setSelectedTabIndex(0),
            ),
            _buildNavItem(
              context,
              icon: Icons.timeline,
              label: 'Timeline',
              isSelected: viewModel.selectedTabIndex == 1,
              onTap: () => viewModel.setSelectedTabIndex(1),
            ),
            _buildNavItem(
              context,
              icon: Icons.book,
              label: 'Journal',
              isSelected: viewModel.selectedTabIndex == 2,
              onTap: () => viewModel.setSelectedTabIndex(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? kcPrimaryColor : kcSecondaryTextColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: bodySmallStyle(context).copyWith(
                color: isSelected ? kcPrimaryColor : kcSecondaryTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) => viewModel.initialize();
}