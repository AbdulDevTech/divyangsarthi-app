import 'package:flutter/material.dart';

/// Small reusable header that shows the app logo with a visible fallback and an
/// optional title text. Use this to keep headers consistent across screens.
class HeaderLogo extends StatelessWidget {
  final double size;
  final String? title;
  final TextStyle? titleStyle;
  const HeaderLogo({Key? key, this.size = 42, this.title, this.titleStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget logo = Image.asset(
      'assets/images/logo.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) {
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'DS',
              style: TextStyle(
                color: theme.colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );

    if (title == null || title!.isEmpty) return logo;

    return Row(
      children: [
        logo,
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title!,
            style: titleStyle ?? theme.textTheme.headline6,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
