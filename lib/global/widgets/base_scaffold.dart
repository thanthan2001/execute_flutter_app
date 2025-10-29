import 'package:flutter/material.dart';

/// Scaffold cơ sở có thể tái sử dụng để đảm bảo giao diện nhất quán trong toàn app.
/// Bao gồm các cấu hình thường dùng: AppBar, FAB, BottomNav, padding, màu nền,...
class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String? appBarTitle;
  final bool showAppBar;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? bodyPadding;
  final Color? backgroundColor;
  final PreferredSizeWidget? customAppBar;
  final bool resizeToAvoidBottomInset;

  const BaseScaffold({
    super.key,
    required this.body,
    this.appBarTitle,
    this.showAppBar = true,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bodyPadding,
    this.backgroundColor,
    this.customAppBar,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: customAppBar ?? _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: bodyPadding ?? const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  AppBar? _buildAppBar() {
    if (!showAppBar) return null;
    if (appBarTitle == null && actions == null && leading == null) return null;

    return AppBar(
      title: appBarTitle != null ? Text(appBarTitle!) : null,
      actions: actions,
      leading: leading,
    );
  }
}
