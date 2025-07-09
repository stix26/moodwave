import 'package:flutter/material.dart';
import 'package:my_app/features/mood_entry/mood_entry_viewmodel.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/button.dart';
import 'package:my_app/shared/card.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class MoodEntryView extends StackedView<MoodEntryViewModel> {
  const MoodEntryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MoodEntryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
        backgroundColor: viewModel.selectedColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              viewModel.selectedColor,
              viewModel.selectedColor.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.2, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmojiSelector(context, viewModel),
                kSpaceLarge,
                _buildMoodInput(context, viewModel),
                kSpaceLarge,
                _buildColorSelector(context, viewModel),
                kSpaceLarge,
                _buildNoteInput(context, viewModel),
                kSpaceLarge,
                _buildSubmitButton(context, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiSelector(
      BuildContext context, MoodEntryViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Emoji',
            style: heading3Style(context),
          ),
          kSpaceMedium,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: viewModel.moodOptions.map((option) {
              final emoji = option['emoji'] as String;
              final text = option['text'] as String;
              final hue = option['hue'] as double;
              final isSelected = emoji == viewModel.selectedEmoji;

              return GestureDetector(
                onTap: () => viewModel.selectMood(emoji, text, hue),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor()
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : kcSecondaryTextColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: HSLColor.fromAHSL(1.0, hue, 0.7, 0.5)
                                  .toColor()
                                  .withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodInput(BuildContext context, MoodEntryViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: heading3Style(context),
          ),
          kSpaceMedium,
          TextField(
            controller: TextEditingController(text: viewModel.moodText),
            decoration: InputDecoration(
              hintText: 'Describe your mood...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: bodyStyle(context),
            onChanged: viewModel.updateMoodText,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(
      BuildContext context, MoodEntryViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Color',
            style: heading3Style(context),
          ),
          kSpaceMedium,
          SliderTheme(
            data: SliderThemeData(
              thumbColor:
                  HSLColor.fromAHSL(1.0, viewModel.hue, 0.7, 0.5).toColor(),
              activeTrackColor: Colors.grey[300],
              inactiveTrackColor: Colors.grey[300],
              overlayColor: HSLColor.fromAHSL(1.0, viewModel.hue, 0.7, 0.5)
                  .toColor()
                  .withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 8,
            ),
            child: Column(
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: List.generate(
                        360,
                        (index) =>
                            HSLColor.fromAHSL(1.0, index.toDouble(), 0.7, 0.5)
                                .toColor(),
                      ),
                    ),
                  ),
                ),
                Slider(
                  min: 0,
                  max: 360,
                  value: viewModel.hue,
                  onChanged: viewModel.updateHue,
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: viewModel.selectedColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: viewModel.selectedColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput(BuildContext context, MoodEntryViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a Note (Optional)',
            style: heading3Style(context),
          ),
          kSpaceMedium,
          TextField(
            decoration: InputDecoration(
              hintText: 'What made you feel this way?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: bodyStyle(context),
            maxLines: 3,
            onChanged: viewModel.updateNote,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, MoodEntryViewModel viewModel) {
    return Center(
      child: CustomButton(
        text: 'Save Mood Entry',
        onPressed: viewModel.saveMoodEntry,
        isLoading: viewModel.isBusy,
        isFullWidth: true,
        variant: ButtonVariant.primary,
        icon: Icons.check,
      ),
    );
  }

  @override
  MoodEntryViewModel viewModelBuilder(BuildContext context) =>
      MoodEntryViewModel();
}