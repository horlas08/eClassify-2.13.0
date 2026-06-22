import 'package:eClassify/data/cubits/ai/generate_meta_cubit.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/ai_generate_button.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO(I): Refactor this flow when updating the re-structuring add_item_details.dart file
// Since this is model for only UI use-case, we are keeping it inside UI for now
class LanguageSEOData {
  LanguageSEOData.fromJson(Json json)
    : title = json['meta_title'] ?? '',
      description = json['meta_description'] ?? '',
      keywords = json['meta_keywords'] ?? '',
      schema = json['schema'] ?? '';

  LanguageSEOData({
    String? title,
    String? description,
    String? keywords,
    String? schema,
  }) : title = title ?? '',
       description = description ?? '',
       keywords = keywords ?? '',
       schema = schema ?? '';

  String title;
  String description;
  String keywords;
  String schema;

  bool get isEmpty =>
      title.isEmpty &&
      description.isEmpty &&
      keywords.isEmpty &&
      schema.isEmpty;

  Map<String, String> get toJson => {
    'meta_title': title,
    'meta_description': description,
    'meta_keywords': keywords,
    'schema': schema,
  };
}

class SEODetailsController {
  SEODetailsController([Map<String, LanguageSEOData>? data])
    : _data = data ?? {};

  final Map<String, LanguageSEOData> _data;

  void updateField(String languageId, String field, String value) {
    final data = _data[languageId] ??= LanguageSEOData();
    switch (field) {
      case 'title':
        data.title = value;
        break;
      case 'description':
        data.description = value;
        break;
      case 'keywords':
        data.keywords = value;
        break;
      case 'schema':
        data.schema = value;
        break;
    }
  }

  LanguageSEOData getData(String languageId) {
    return _data[languageId] ?? LanguageSEOData();
  }

  Map<String, Map<String, String>> get values {
    final Map<String, Map<String, String>> result = {};
    _data.forEach((key, value) {
      if (!value.isEmpty) {
        result[key] = value.toJson;
      }
    });
    return result;
  }
}

class SEODetails extends StatefulWidget {
  const SEODetails({
    super.key,
    required this.languageId,
    required this.controller,
    required this.title,
    required this.price,
    required this.onAIGenerate,
  });

  final String languageId;
  final SEODetailsController controller;
  final String title;
  final String price;
  final VoidCallback? onAIGenerate;

  @override
  State<SEODetails> createState() => _SEODetailsState();
}

class _SEODetailsState extends State<SEODetails> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _schemaController = TextEditingController();

  final ExpansibleController _tileController = ExpansibleController();

  final GlobalKey _lastFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData(widget.languageId);
  }

  @override
  void didUpdateWidget(covariant SEODetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageId != widget.languageId) {
      _loadData(widget.languageId);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    _schemaController.dispose();
    super.dispose();
  }

  void _loadData(String langCode) {
    final data = widget.controller.getData(langCode);
    _titleController.text = data.title;
    _descriptionController.text = data.description;
    _keywordsController.text = data.keywords;
    _schemaController.text = data.schema;
  }

  void _onChanged(String? value, String fieldKey) {
    widget.controller.updateField(widget.languageId, fieldKey, value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      controller: _tileController,
      backgroundColor: context.colorScheme.secondary,
      title: Text("seoDetails".translate(context), style: context.titleMedium),
      onExpansionChanged: (isExpanded) async {
        if (!isExpanded) return;
        // Wait until the expansion animation is complete
        await Future.delayed(const Duration(milliseconds: 300));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Log.debug('${_lastFieldKey.currentContext}');
          Scrollable.ensureVisible(
            context,
            alignment: 1.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.decelerate,
          );
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: ThemeColors.borderColor),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: ThemeColors.borderColor),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        15.vGap,
        if (Constant.systemSettings.geminiAiEnabled)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: BlocConsumer<GenerateMetaCubit, GenerateMetaState>(
              listener: (context, state) {
                if (state is GenerateMetaSuccess) {
                  final data = state.data;
                  _titleController.text = data['meta_title'] ?? '';
                  _descriptionController.text = data['meta_description'] ?? '';
                  _keywordsController.text = data['meta_keywords'] ?? '';
                  _schemaController.text = data['schema'] ?? '';

                  // Update the controller fields as well
                  widget.controller.updateField(
                    widget.languageId,
                    'title',
                    _titleController.text,
                  );
                  widget.controller.updateField(
                    widget.languageId,
                    'description',
                    _descriptionController.text,
                  );
                  widget.controller.updateField(
                    widget.languageId,
                    'keywords',
                    _keywordsController.text,
                  );
                  widget.controller.updateField(
                    widget.languageId,
                    'schema',
                    _schemaController.text,
                  );
                }
                if (state is GenerateMetaFailure) {
                  HelperUtils.showSnackBarMessage(context, state.errorMessage);
                }
              },
              builder: (context, state) {
                return AIGenerateButton(
                  onPressed: widget.onAIGenerate,
                  isLoading: state is GenerateMetaInProgress,
                );
              },
            ),
          ),
        _SEOField(
          label: 'metaTitle',
          hintText: 'metaTitleHint',
          controller: _titleController,
          onChanged: (value) => _onChanged(value, 'title'),
        ),
        10.vGap,
        _SEOField(
          label: 'metaDescription',
          hintText: 'metaDescriptionHint',
          controller: _descriptionController,
          minLines: 2,
          maxLines: 5,
          onChanged: (value) => _onChanged(value, 'description'),
        ),
        10.vGap,
        _SEOField(
          label: 'metaKeywords',
          hintText: 'metaKeywordsHint',
          controller: _keywordsController,
          note: 'commaSeparatedValuesNote',
          onChanged: (value) => _onChanged(value, 'keywords'),
        ),
        10.vGap,
        _SEOField(
          key: _lastFieldKey,
          label: 'metaSchema',
          hintText: 'metaSchemaHint',
          note: 'metaSchemaNote',
          controller: _schemaController,
          minLines: 2,
          maxLines: 10,
          onChanged: (value) => _onChanged(value, 'schema'),
        ),
        10.vGap,
      ],
    );
  }
}

class _SEOField extends StatelessWidget {
  const _SEOField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.note,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final ValueChanged<String?> onChanged;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label.translate(context), style: context.titleSmall.semiBold),
        if (note != null)
          Text(
            note!.translate(context),
            style: context.labelSmall.withColor(context.mutedColor),
          ),
        10.vGap,
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          style: context.bodyMedium,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hintText.translate(context)),
        ),
      ],
    );
  }
}
