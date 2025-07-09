import 'package:flutter/material.dart';
import 'package:my_app/features/profile/profile_viewmodel.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/button.dart';
import 'package:my_app/shared/card.dart';
import 'package:my_app/shared/text_style.dart';
import 'package:my_app/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfileViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: kcPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildProfileHeader(context, viewModel),
                    kSpaceMedium,
                    _buildProfileForm(context, viewModel),
                    kSpaceMedium,
                    _buildAccountActions(context, viewModel),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileViewModel viewModel) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              buildAvatar(
                imageUrl: viewModel.avatarUrl,
                name: viewModel.userProfile?.name,
                radius: 60,
                backgroundColor: kcPrimaryColor.withOpacity(0.1),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: InkWell(
                    onTap: viewModel.selectProfileImage,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          kSpaceMedium,
          Text(
            viewModel.userProfile?.name ?? 'User',
            style: heading2Style(context),
          ),
          kSpaceSmall,
          Text(
            viewModel.userProfile?.email ?? '',
            style: bodyStyle(context).copyWith(color: kcSecondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, ProfileViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: heading3Style(context),
          ),
          kSpaceMedium,
          TextField(
            controller: viewModel.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
          kSpaceMedium,
          TextField(
            controller: viewModel.emailController,
            enabled: false, // Email is not editable
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
          kSpaceMedium,
          CustomButton(
            text: 'Save Changes',
            isFullWidth: true,
            onPressed: viewModel.saveProfile,
            isLoading: viewModel.isBusy,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(
      BuildContext context, ProfileViewModel viewModel) {
    return CustomCard(
      variant: CardVariant.outlined,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: heading3Style(context),
          ),
          kSpaceMedium,
          ListTile(
            leading: const Icon(Icons.logout, color: kcPrimaryColor),
            title: Text('Sign Out', style: bodyStyle(context)),
            onTap: viewModel.signOut,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outlined, color: kcPrimaryColor),
            title: Text('Change Password', style: bodyStyle(context)),
            onTap: () {}, // TODO: Navigate to change password
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: kcErrorColor),
            title: Text(
              'Delete Account',
              style: bodyStyle(context).copyWith(color: kcErrorColor),
            ),
            onTap: () {}, // TODO: Show delete account dialog
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel();

  @override
  void onViewModelReady(ProfileViewModel viewModel) => viewModel.initialize();
}
