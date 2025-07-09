import 'package:flutter/material.dart';
import 'package:my_app/features/mood_insights/mood_insights_viewmodel.dart';
import 'package:my_app/models/mood_insight.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/card.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class MoodInsightsView extends StackedView<MoodInsightsViewModel> {
  const MoodInsightsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MoodInsightsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Insights'),
        backgroundColor: kcPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, MoodInsightsViewModel viewModel) {
    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: kcErrorColor),
            kSpaceMedium,
            Text(
              'Could not load insights',
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
              onPressed: viewModel.loadInsights,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (viewModel.insights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology,
                size: 64, color: kcPrimaryColor.withOpacity(0.5)),
            kSpaceMedium,
            Text(
              'No insights yet',
              style: heading2Style(context),
            ),
            kSpaceSmall,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Continue logging your moods and we\'ll provide personalized insights soon',
                style: bodyStyle(context),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Weekly Insights',
          style: heading2Style(context),
        ),
        kSpaceSmall,
        Text(
          'Based on your mood patterns from the last 7 days',
          style: bodySmallStyle(context),
        ),
        kSpaceMedium,
        ...viewModel.insights
            .map((insight) => _buildInsightCard(context, insight)),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, MoodInsight insight) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      variant: CardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kcSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: kcSecondaryColor,
                ),
              ),
              kSpaceSmall,
              Expanded(
                child: Text(
                  insight.title,
                  style: heading3Style(context),
                ),
              ),
            ],
          ),
          kSpaceSmall,
          Text(
            insight.description,
            style: bodyStyle(context),
          ),
          if (insight.suggestion != null && insight.suggestion!.isNotEmpty) ...[
            kSpaceMedium,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kcPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: kcPrimaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try This',
                    style: heading3Style(context).copyWith(
                      color: kcPrimaryColor,
                      fontSize: 16,
                    ),
                  ),
                  kSpaceSmall,
                  Text(
                    insight.suggestion!,
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

  @override
  MoodInsightsViewModel viewModelBuilder(BuildContext context) =>
      MoodInsightsViewModel();

  @override
  void onViewModelReady(MoodInsightsViewModel viewModel) =>
      viewModel.loadInsights();
}