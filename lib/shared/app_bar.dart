import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/shared/app_colors.dart';

enum AppBarVariant { transparent, glass, solid, gradient }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final AppBarVariant variant;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.variant = AppBarVariant.glass,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getDecoration(),
      child: AppBar(
        title: title != null
            ? Text(
                title!,
                style: TextStyle(color: Colors.white),
              )
            : null,
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: actions,
        iconTheme: IconThemeData(
          color: variant == AppBarVariant.gradient
              ? Colors.white
              : kcPrimaryTextColor,
        ),
        systemOverlayStyle: variant == AppBarVariant.gradient
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case AppBarVariant.transparent:
        return const BoxDecoration(color: Colors.transparent);
      case AppBarVariant.glass:
        return BoxDecoration(
          color: kcSurfaceColor.withOpacity(0.9),
          border: Border(
              bottom: BorderSide(color: kcSecondaryTextColor.withOpacity(0.2))),
        );
      case AppBarVariant.solid:
        return BoxDecoration(
          color: kcSurfaceColor,
          boxShadow: [
            BoxShadow(
                color: kcSecondaryTextColor.withOpacity(0.1), blurRadius: 2)
          ],
        );
      case AppBarVariant.gradient:
        return const BoxDecoration(gradient: kcPrimaryGradient);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: color ?? kcPrimaryTextColor,
    );
  }
}
