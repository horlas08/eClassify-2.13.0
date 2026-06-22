import 'package:eClassify/data/model/referral/referral_transaction.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReferralTransactionWidget extends StatelessWidget {
  const ReferralTransactionWidget({required this.transaction, super.key});

  final ReferralTransaction transaction;

  Widget _titleAndContent(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.bodySmall.withColor(context.mutedColor)),
        Text(content, style: context.labelMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              titleTextStyle: context.bodySmall.withColor(context.mutedColor),
              subtitleTextStyle: context.titleSmall.bold,
              title: Text('transactionId'.translate(context)),
              subtitle: Text('#${transaction.id}'),
              trailing: DecoratedBox(
                decoration: BoxDecoration(
                  color: transaction.transactionType.color.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    transaction.transactionType.name.translate(context),
                    style: context.bodySmall.withColor(
                      transaction.transactionType.color,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _titleAndContent(
                  context,
                  title: 'points'.translate(context),
                  content: '${transaction.points}',
                ),
                _titleAndContent(
                  context,
                  title: 'date'.translate(context),
                  content: DateFormat.yMMMd(
                    AppSession.currentLocale,
                  ).format(transaction.transactionDate),
                ),
              ],
            ),
            _titleAndContent(
              context,
              title: 'remark'.translate(context),
              content: transaction.remark,
            ),
          ],
        ),
      ),
    );
  }
}
