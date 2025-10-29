import 'package:flutter/material.dart';

/// Một Widget Scaffold có thể tái sử dụng để đảm bảo giao diện nhất quán.
///
/// Bao gồm các thuộc tính phổ biến như AppBar, body, floatingActionButton,
/// và cung cấp sẵn padding mặc định cho body.
class BaseScaffold extends StatelessWidget {
  /// Widget chính sẽ được hiển thị trong body của Scaffold.
  final Widget body;

  final String? appBarTitle;

  final bool showAppBar;

  final List<Widget>? actions;

  final Widget? leading;

  final Widget? floatingActionButton;

  final Widget? bottomNavigationBar;

  final EdgeInsetsGeometry? bodyPadding;

  final Color? backgroundColor;

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
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: bodyPadding ?? const EdgeInsets.all(16.0),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  AppBar? _buildAppBar() {
    if (!showAppBar) {
      return null;
    }

    if (appBarTitle == null && actions == null && leading == null) {
      return null;
    }

    return AppBar(
      title: appBarTitle != null ? Text(appBarTitle!) : null,
      actions: actions,
      leading: leading,
    );
  }
}
