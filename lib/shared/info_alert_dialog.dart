import 'package:flutter/material.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/button.dart';
import 'package:stacked_services/stacked_services.dart';

class InfoAlertDialog extends StatelessWidget {
  const InfoAlertDialog({
    required this.request,
    required this.completer,
    super.key,
  });
  final DialogRequest request;
  final Function(DialogResponse) completer;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: kcSurfaceColor,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Section
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: kcPrimaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.info,
                size: 32,
                color: Colors.white,
              ),
            ),
            kSpaceLarge,

            // Title
            Text(
              request.title ?? 'Information',
              style: heading2Style(context).copyWith(
                color: kcPrimaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            kSpaceMedium,

            // Description
            Text(
              request.description ?? 'No description provided',
              style: bodyStyle(context).copyWith(
                color: kcSecondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            kSpaceLarge,

            // Action Buttons
            Row(
              children: [
                if (request.secondaryButtonTitle != null) ...[
                  Expanded(
                    child: CustomButton(
                      text: request.secondaryButtonTitle!,
                      variant: ButtonVariant.outline,
                      onPressed: () => completer(
                        DialogResponse(confirmed: false),
                      ),
                      isFullWidth: true,
                    ),
                  ),
                  kSpaceMedium,
                ],
                Expanded(
                  child: CustomButton(
                    text: request.mainButtonTitle ?? 'Got it',
                    variant: ButtonVariant.primary,
                    onPressed: () => completer(
                      DialogResponse(confirmed: true),
                    ),
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
