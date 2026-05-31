import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_spacing.dart';
import 'package:realtime_chat_engine/core/theme/app_theme_extension.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/core/theme/app_text_styles.dart';
import 'package:realtime_chat_engine/features/auth/presentation/controller/auth_controller.dart';
import 'package:realtime_chat_engine/features/profile/presentation/controller/profile_controller.dart';
import 'package:realtime_chat_engine/features/profile/presentation/widgets/settings_tile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    if (state is ErrorState) {
      return Scaffold(
        body: Column(
          children: [
            Center(child: Icon(Icons.warning, size: 60)),
            Text("Nothing to see here"),
          ],
        ),
      );
    }

    if (state is DefaultState) {
      return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 25.0),
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    state.userDetails.firstName.split('')[0].toUpperCase(),
                    style: AppTextStyle.headlineLarge.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: Colors.black,
                    ),
                  ),
                ),

                AppSpacing.height8(),

                Text(
                  "${state.userDetails.firstName} ${state.userDetails.lastName}",
                  style: AppTextStyle.titleLarge.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                    color: Colors.black,
                  ),
                ),

                Text(
                  state.userDetails.email,
                  style: AppTextStyle.bodyMedium.copyWith(color: context.appTheme.neutral500),
                ),

                AppSpacing.height24(),

                Align(
                  alignment: .centerLeft,
                  child: Text(
                    "Settings",
                    style: AppTextStyle.labelLarge.copyWith(
                      color: context.appTheme.neutral500,
                      letterSpacing: 0,
                    ),
                  ),
                ),

                // Account settings
                SettingsTile(
                  title: "Account",
                  subTitle: "Change your account settings here",
                  icon: Icons.account_box,
                ),

                Divider(height: 0, color: Colors.grey.shade400),

                // Notification settings
                SettingsTile(
                  title: "Notification",
                  subTitle: "Tune your notification settings here",
                  icon: Icons.notifications,
                ),

                Divider(height: 0, color: Colors.grey.shade400),

                // Theme settings
                SettingsTile(
                  title: "Theme",
                  subTitle: "Customize the app to your liking",
                  icon: Icons.palette,
                ),

                Divider(height: 0, color: Colors.grey.shade400),

                const Spacer(),

                TextButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).logOut(),
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        "Log out",
                        style: AppTextStyle.titleMedium.copyWith(
                          color: context.colorScheme.error,
                          letterSpacing: -1,
                        ),
                      ),

                      Icon(Icons.logout, color: context.colorScheme.error),
                    ],
                  ),
                ),

                AppSpacing.height16(),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }
}
