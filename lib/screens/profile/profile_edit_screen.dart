import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';

/// Profile Edit Screen - Allows users to update their profile information
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Load current user data
  Future<void> _loadUserData() async {
    final user = ref.read(currentFirebaseUserProvider);
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });
    }

    // Add listeners to track changes
    _nameController.addListener(_markAsChanged);
  }

  /// Mark that changes have been made
  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.primaryTeal),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primaryTeal),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_selectedImage != null ||
                    ref.read(currentFirebaseUserProvider)?.photoURL != null)
                  ListTile(
                    leading: Icon(Icons.delete, color: AppColors.error),
                    title: const Text('Remove photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _hasChanges = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Save profile changes
  Future<void> _saveProfile() async {
    print('=== SAVE PROFILE STARTED ===');

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    if (!_hasChanges) {
      print('No changes detected');
      Navigator.pop(context);
      return;
    }

    print('Setting loading state...');
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentFirebaseUserProvider);
      print('Current user: ${user?.uid}, displayName: ${user?.displayName}');

      if (user == null) {
        throw 'User not found';
      }

      final newName = _nameController.text.trim();
      print('New name to save: $newName');

      final firestoreService = FirestoreService();
      String? photoUrl = user.photoURL;
      bool photoChanged = false;

      // Upload avatar if a new image was selected
      if (_selectedImage != null) {
        print('Uploading new avatar...');
        photoUrl = await firestoreService.uploadUserAvatar(
          user.uid,
          _selectedImage!,
        );
        photoChanged = true;
        print('Avatar uploaded: $photoUrl');
      }

      // Update profile in Firestore
      print('Updating Firestore profile...');
      await firestoreService.updateUserProfile(
        userId: user.uid,
        displayName: newName,
        photoUrl: photoChanged ? photoUrl : null,
      );
      print('Firestore profile updated');

      // Update Firebase Auth profile
      print('Updating Firebase Auth profile...');
      await user.updateDisplayName(newName);
      print('Display name updated in Firebase Auth');

      // Only update photo URL if it changed
      if (photoChanged && photoUrl != null) {
        print('Updating photo URL in Firebase Auth...');
        await user.updatePhotoURL(photoUrl);
      }

      print('Reloading user...');
      await user.reload();
      print('User reloaded successfully');

      // Force refresh the auth state to update UI
      print('Invalidating providers to refresh UI...');
      ref.invalidate(authStateChangesProvider);
      ref.invalidate(currentFirebaseUserProvider);
      ref.invalidate(currentUserDataProvider);

      if (mounted) {
        print('Showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      // Log the full error for debugging
      print('Profile update error: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Show unsaved changes dialog
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentFirebaseUserProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          shadowColor: AppColors.shadowLight,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: _isLoading ? AppColors.textLight : AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar Section
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null) as ImageProvider?,
                              child: _selectedImage == null && user?.photoURL == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.primaryTeal,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name Field
                      _buildSectionLabel('Display Name'),
                      const SizedBox(height: 8),
                      _buildCard(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: AppColors.textLight),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email Field (Read-only)
                      _buildSectionLabel('Email Address'),
                      const SizedBox(height: 8),
                      _buildCard(
                        child: TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            hintStyle: TextStyle(color: AppColors.textLight),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.textGrey,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Text(
                          'Email cannot be changed from this screen',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton(
                        onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: AppColors.textLight,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Build section label
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build card container
  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
