import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_app/app/app.dialogs.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _dialogService = locator<DialogService>();

  UserProfile? get userProfile => _authService.currentUser;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Profile image
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl ?? userProfile?.avatarUrl;
  File? _avatarFile;
  bool _hasSelectedNewAvatar = false;
  bool get hasSelectedNewAvatar => _hasSelectedNewAvatar;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void initialize() {
    if (userProfile != null) {
      nameController.text = userProfile!.name ?? '';
      emailController.text = userProfile!.email;
      _avatarUrl = userProfile!.avatarUrl;
    }
  }

  Future<void> selectProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        _avatarFile = File(result.files.single.path!);
        _hasSelectedNewAvatar = true;
        notifyListeners();
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Image Selection Error',
        description: 'Failed to select image: ${e.toString()}',
      );
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty) {
      await _dialogService.showDialog(
        title: 'Invalid Input',
        description: 'Please enter your name.',
      );
      return;
    }

    setBusy(true);
    try {
      // Upload avatar if a new one was selected
      String? newAvatarUrl;
      if (_hasSelectedNewAvatar && _avatarFile != null) {
        // Note: We would normally upload the file to storage here
        // For now, we'll just update the profile with existing avatar URL
        newAvatarUrl = _avatarUrl;
      }

      final success = await _authService.updateUserProfile(
        name: nameController.text,
        avatarUrl: newAvatarUrl,
      );

      if (success) {
        await _dialogService.showDialog(
          title: 'Success',
          description: 'Your profile has been updated.',
        );
      } else {
        await _dialogService.showDialog(
          title: 'Update Failed',
          description: 'Failed to update your profile. Please try again.',
        );
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Update Error',
        description: 'An error occurred: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> signOut() async {
    final dialogResponse = await _dialogService.showDialog(
      title: 'Sign Out',
      description: 'Are you sure you want to sign out?',
      buttonTitle: 'Sign Out',
      cancelTitle: 'Cancel',
    );

    if (dialogResponse?.confirmed ?? false) {
      setBusy(true);
      try {
        await _authService.signOut();
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Sign Out Error',
          description: 'Failed to sign out: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }
}