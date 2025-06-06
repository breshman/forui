import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';
import 'package:forui/forui.dart';

import 'package:forui_samples/sample.dart';

@RoutePage()
class DialogPage extends Sample {
  final Axis direction;

  DialogPage({@queryParam super.theme, @queryParam bool vertical = false})
    : direction = vertical ? Axis.vertical : Axis.horizontal;

  @override
  Widget sample(BuildContext context) {
    final actions = [
      FButton(style: FButtonStyle.outline, child: const Text('Cancel'), onPress: () => Navigator.of(context).pop()),
      FButton(child: const Text('Continue'), onPress: () => Navigator.of(context).pop()),
    ];

    final style = context.theme.dialogStyle;
    return FButton(
      intrinsicWidth: true,
      onPress: () => showAdaptiveDialog(
        context: context,
        builder: (context) => FTheme(
          data: theme,
          child: FDialog(
            style: style,
            direction: direction,
            title: const Text('Are you absolutely sure?'),
            body: const Text(
              'This action cannot be undone. This will permanently delete your account and remove your data from our servers.',
            ),
            actions: direction == Axis.vertical ? actions.reversed.toList() : actions,
          ),
        ),
      ),
      child: const Text('Show Dialog'),
    );
  }
}
