import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';

class ReferralCodeField extends StatefulWidget {
  const ReferralCodeField({required this.referralController, super.key});

  final TextEditingController referralController;

  @override
  State<ReferralCodeField> createState() => _ReferralCodeFieldState();
}

class _ReferralCodeFieldState extends State<ReferralCodeField> {
  final _controller = ExpansibleController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      controller: _controller,
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeColors.borderColor),
      ),
      shape: LinearBorder.none,
      title: Text('haveReferralCode'.translate(context)),
      trailing: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          Log.debug('${_controller.isExpanded}');
          return Checkbox(
            value: _controller.isExpanded,
            onChanged: (_) {
              if (_controller.isExpanded) {
                _controller.collapse();
              } else {
                _controller.expand();
              }
            },
          );
        },
      ),
      children: [
        10.vGap,
        TextField(
          controller: widget.referralController,
          decoration: InputDecoration(
            hintText: 'referralCode'.translate(context),
          ),
        ),
      ],
    );
  }
}
