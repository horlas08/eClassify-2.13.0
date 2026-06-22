import 'package:eClassify/data/cubits/blog_details_cubit.dart';
import 'package:eClassify/data/model/blog_model.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetails extends StatelessWidget {
  final BlogModel blog;

  const BlogDetails({super.key, required this.blog});

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map;
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (_) => BlogDetailsCubit(),
          child: BlogDetails(blog: arguments['blog'] as BlogModel),
        );
      },
    );
  }

  String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String strippedString = htmlString.replaceAll(exp, '');
    return strippedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: "blogs".translate(context),
      ),
      body: SafeArea(
        child: BlocBuilder<BlogDetailsCubit, BlogDetailsState>(
          builder: (context, state) {
            if (state is BlogDetailsInitial) {
              context.read<BlogDetailsCubit>().getBlogDetails(blog: blog);
            }
            if (state is BlogDetailsFailure) {
              return Center(child: SomethingWentWrong());
            }
            if (state is BlogDetailsSuccess) {
              final blog = state.blog;
              if (blog == null) {
                return Center(child: SomethingWentWrong());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 15,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: CustomImage(src: blog.image, radius: 10),
                    ),
                    CustomText(
                      blog.createdAt!.formatDate(),
                      color: context.color.textColorDark.withValues(alpha: 0.5),
                      fontSize: context.font.smaller,
                    ),
                    CustomText(
                      blog.title.localized,
                      color: context.color.textColorDark,
                      fontSize: context.font.large,
                    ),
                    if (blog.description != null)
                      HtmlWidget(blog.description!.localized),
                  ],
                ),
              );
            }
            return Center(child: UiUtils.progress());
          },
        ),
      ),
    );
  }
}
