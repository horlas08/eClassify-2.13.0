import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/model/user/verification_request.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserVerificationCard extends StatefulWidget {
  const UserVerificationCard({super.key});

  @override
  State<UserVerificationCard> createState() => _UserVerificationCardState();
}

class _UserVerificationCardState extends State<UserVerificationCard> {
  @override
  void initState() {
    super.initState();
    context.read<VerificationRequestCubit>().fetchVerificationRequest();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerificationRequestCubit, VerificationRequestState>(
      builder: (context, state) {
        if (state is VerificationRequestLoading) {
          return const SizedBox.shrink();
        }

        final request = state is VerificationRequestSuccess
            ? state.request
            : null;

        if (request?.status == VerificationRequestStatus.approved) {
          return const SizedBox.shrink();
        }

        final config = _VerificationCardUIResolver.resolve(context, request);

        return Card.outlined(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: config.color),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                CustomImage(src: config.icon),
                Expanded(
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title.translate(context),
                        style: context.titleMedium,
                      ),
                      Text(
                        config.subtitle.translate(context),
                        style: context.labelMedium,
                      ),
                      10.vGap,
                      if (config.buttonTitle.isNotNullAndNotEmpty)
                        FilledButton(
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 16,
                            ),
                          ),
                          onPressed: () async {
                            final didSubmit =
                                await Navigator.of(context).pushNamed(
                                      Routes.sellerIntroVerificationScreen,
                                      arguments: {
                                        "isResubmitted":
                                            request?.status ==
                                            VerificationRequestStatus.rejected,
                                      },
                                    )
                                    as bool? ??
                                false;

                            if (didSubmit) {
                              context
                                  .read<VerificationRequestCubit>()
                                  .fetchVerificationRequest();
                            }
                          },
                          child: Text(config.buttonTitle!.translate(context)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VerificationCardUIResolver {
  static _VerificationCardUIConfig resolve(
    BuildContext context,
    VerificationRequest? request,
  ) {
    final status = request?.status;
    return switch (status) {
      VerificationRequestStatus.pending => _VerificationCardUIConfig(
        icon: AppIcons.profile.verification,
        title: 'verificationInReviewTitle',
        subtitle: 'verificationInReviewSubtitle',
      ),
      VerificationRequestStatus.rejected => _VerificationCardUIConfig(
        icon: AppIcons.profile.verificationRejected,
        title: 'verificationRejectedTitle',
        subtitle:
            '${'rejection_reason'.translate(context)}: '
            '${request!.rejectionReason ?? 'N/A'}',
        buttonTitle: 'resubmitVerification',
        color: Colors.red,
      ),
      _ => _VerificationCardUIConfig(
        icon: AppIcons.profile.verification,
        title: 'verificationInitialTitle',
        subtitle: 'verificationInitialSubtitle',
        buttonTitle: 'getVerificationBadge',
      ),
    };
  }
}

class _VerificationCardUIConfig {
  _VerificationCardUIConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = ThemeColors.primaryColor,
    this.buttonTitle,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? buttonTitle;
}
