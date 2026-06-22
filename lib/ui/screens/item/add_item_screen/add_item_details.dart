import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ai/generate_description_cubit.dart';
import 'package:eClassify/data/cubits/ai/generate_meta_cubit.dart';
import 'package:eClassify/data/cubits/currency/fetch_currencies_cubit.dart';
import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/currency.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/ai_repository.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/ai_generate_button.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/multi_image_picker.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/seo_details_widget.dart';
import 'package:eClassify/ui/screens/widgets/blurred_dialog_box.dart';
import 'package:eClassify/ui/screens/widgets/category/category_breadcrumbs_widget.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field.dart';
import 'package:eClassify/ui/screens/widgets/phone_input.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/lib/build_context.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/slug_formatter.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddItemDetails extends StatefulWidget {
  final List<Category>? categoryTree;
  final bool isEdit;

  const AddItemDetails({
    required this.categoryTree,
    required this.isEdit,
    super.key,
  });

  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => FetchCustomFieldsCubit()),
            BlocProvider(
              create: (context) => GenerateMetaCubit(AIRepository()),
            ),
            BlocProvider(
              create: (context) => GenerateDescriptionCubit(AIRepository()),
            ),
          ],
          child: AddItemDetails(
            categoryTree: args?['category_tree'] as List<Category>?,
            isEdit: args?['isEdit'] as bool? ?? false,
          ),
        );
      },
    );
  }

  @override
  CloudState<AddItemDetails> createState() => _AddItemDetailsState();
}

class _AddItemDetailsState extends CloudState<AddItemDetails>
    with TickerProviderStateMixin {
  List<dynamic> mixedItemImageList = [];
  List<int> deleteItemImageList = [];
  late final GlobalKey<FormState> _formKey;

  // Shared fields
  final TextEditingController adSlugController = TextEditingController();
  final TextEditingController adPriceController = TextEditingController();
  final TextEditingController adAdditionalDetailsController =
      TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();
  final TextEditingController maxSalaryController = TextEditingController();
  final PhoneInputController phoneInputController = PhoneInputController();

  // Language-specific fields
  Map<String, TextEditingController> adTitleControllers = {};
  Map<String, TextEditingController> adDescriptionControllers = {};

  late final SEODetailsController seoDetailsController;

  int selectedLangIndex = 0;
  List languages = [];
  String defaultLangCode = '';
  TabController? _tabController;

  ItemModel? item;

  // Flag to ensure translations are only populated once
  bool _translationsPopulated = false;

  final ValueNotifier<bool> _isValid = ValueNotifier(false);

  // Currency selection
  Currency? selectedCurrency;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();
    if (widget.isEdit) {
      item = getCloudData('edit_request') as ItemModel;
      clearCloudData("item_details");
      clearCloudData("with_more_details");
      context.read<FetchCustomFieldsCubit>().fetchCustomFields(
        categoryId: item!.categoryId!,
      );

      // Set default language values
      adTitleControllers[defaultLangCode] = TextEditingController(
        text: item?.translatedName ?? "",
      );

      adSlugController.text = item?.slug ?? "";
      adDescriptionControllers[defaultLangCode] = TextEditingController(
        text: item?.translatedDescription ?? "",
      );

      // Store translations for later population when languages are available
      print("item?.translations***${item?.translations}");
      if (item?.translations != null) {
        // Store the translations data to populate later
        addCloudData("item_translations", item!.translations);
      }

      adPriceController.text = item?.price?.toString() ?? "";
      minSalaryController.text = item?.minSalary != null
          ? item?.minSalary.toString() ?? ""
          : "";
      maxSalaryController.text = item?.maxSalary != null
          ? item?.maxSalary.toString() ?? ""
          : "";

      phoneInputController.phoneNumber = item?.contact;
      phoneInputController.regionCode = item?.regionCode;
      adAdditionalDetailsController.text = item?.videoLink ?? "";
      if (item?.galleryImages != null) {
        mixedItemImageList.addAll(item!.galleryImages!);
      }

      Log.debug('${item?.currency}');
      selectedCurrency = item?.currency;

      final seoDetails = item?.seoDetails;
      final defaultLanguageId =
          Constant.systemSettings.defaultLanguageMap['id'];
      final seoData = <String, LanguageSEOData>{};
      if (seoDetails != null) {
        seoData[defaultLanguageId.toString()] = LanguageSEOData(
          title: seoDetails.metaTitle,
          description: seoDetails.metaDescription,
          keywords: seoDetails.metaKeywords,
          schema: seoDetails.schema,
        );

        if (seoDetails.translations.isNotNullAndNotEmpty) {
          final groupedByLanguage = groupBy(
            seoDetails.translations!,
            (json) => json['language_id'],
          );

          for (final seo in groupedByLanguage.entries) {
            seoData[seo.key.toString()] = LanguageSEOData.fromJson(
              seo.value.first,
            );
          }
        }
      }
      seoDetailsController = SEODetailsController(seoData);

      setState(() {});
    } else {
      seoDetailsController = SEODetailsController();
      context.read<FetchCustomFieldsCubit>().fetchCustomFields(
        categoryId: widget.categoryTree!.last.id,
      );
      final user = HiveUtils.getUserDetails();
      phoneInputController.phoneNumber = user.mobile;
      phoneInputController.phoneCode = user.countryCode;
      phoneInputController.regionCode = user.regionCode;

      adTitleControllers[HiveUtils.getLanguage()['code']] =
          TextEditingController();
    }
  }

  @override
  void dispose() {
    adSlugController.dispose();
    adPriceController.dispose();
    adAdditionalDetailsController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    _tabController?.dispose();
    _isValid.dispose();

    for (final controller in [
      ...adDescriptionControllers.values,
      ...adTitleControllers.values,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  String generateSlug(String title) {
    // force lowercase
    String slug = title.toLowerCase();

    // replace anything that is NOT english letters a-z or digits 0-9 with "-"
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    // trim leading/trailing "-"
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');

    return slug;
  }

  bool get isJobCategory {
    if (widget.isEdit) {
      return item!.category!.isJobCategory;
    } else {
      return widget.categoryTree!.last.isJobCategory;
    }
  }

  bool get isPriceOptional {
    if (widget.isEdit) {
      return item!.category!.isPriceOptional;
    } else {
      return widget.categoryTree!.last.isPriceOptional;
    }
  }

  @override
  Widget build(BuildContext context) {
    languages = Constant.systemSettings.languages as List? ?? [];
    // Set defaultLangCode from system settings
    defaultLangCode = Constant.systemSettings.defaultLanguageCode;

    // Ensure default language is first in the list (case-insensitive)
    if (languages.isNotEmpty &&
        (languages[0]['code']?.toString().toLowerCase() ?? '') !=
            (defaultLangCode.toLowerCase())) {
      final defIndex = languages.indexWhere(
        (l) =>
            (l['code']?.toString().toLowerCase() ?? '') ==
            defaultLangCode.toLowerCase(),
      );
      if (defIndex > 0) {
        final defLang = languages.removeAt(defIndex);
        languages.insert(0, defLang);
      }
    }
    if (languages.isEmpty) {
      return Center(child: Text('No languages available'));
    }
    _tabController ??= TabController(
      length: languages.length,
      vsync: this,
      initialIndex: 0,
    );
    // Initialize controllers for each language
    for (var lang in languages) {
      adTitleControllers[lang['code']] ??= TextEditingController();
      adDescriptionControllers[lang['code']] ??= TextEditingController();
    }

    // Populate translations if in edit mode and not yet populated
    if ((widget.isEdit) && !_translationsPopulated) {
      if (item?.translations != null &&
          (item!.translations as List).isNotEmpty) {
        for (var lang in languages) {
          final langCode = lang['code'];
          final langId = lang['id'];
          var translation = (item!.translations as List).firstWhere(
            (t) => t is Map<String, dynamic> && t['language_id'] == langId,
            orElse: () => null,
          );
          if (translation != null && translation is Map<String, dynamic>) {
            adTitleControllers[langCode]?.text =
                translation['name'] ?? (item?.translatedName ?? "");
            adDescriptionControllers[langCode]?.text =
                translation['description'] ??
                (item?.translatedDescription ?? "");
          } else {
            // Fallback to default
            adTitleControllers[langCode]?.text = item?.name ?? "";
            adDescriptionControllers[langCode]?.text = item?.description ?? "";
          }
        }
        _translationsPopulated = true;
      } else {
        // If translations is blank, fill all with default, but ensure default language is always set
        for (var lang in languages) {
          final langCode = lang['code'];
          if (langCode == defaultLangCode) {
            adTitleControllers[langCode]?.text = item?.translatedName ?? "";
            adDescriptionControllers[langCode]?.text =
                item?.translatedDescription ?? "";
          } else {
            adTitleControllers[langCode]?.text = "";
            adDescriptionControllers[langCode]?.text = "";
          }
        }
        _translationsPopulated = true;
      }
    }

    String selectedLangCode = languages[selectedLangIndex]['code'];
    bool isDefault = selectedLangCode == defaultLangCode;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'AdDetails'.translate(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.color.textDefaultColor,
            ),
          ),
          bottom: languages.length > 1
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: context.color.territoryColor,
                    unselectedLabelColor: context.color.textColorDark
                        .withValues(alpha: 0.5),
                    indicatorColor: context.color.territoryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabAlignment: TabAlignment.start,
                    dividerHeight: 0.0,
                    onTap: (index) {
                      if (selectedLangIndex == index) {
                        _isValid.value =
                            _formKey.currentState?.validate() ?? true;
                        return;
                      }
                      // Only validate when leaving the default language tab (index 0)
                      if (selectedLangIndex == 0 && index != 0) {
                        _isValid.value =
                            _formKey.currentState?.validate() ?? false;
                        // Prevent tab change if not valid
                        if (!_isValid.value) {
                          _tabController?.animateTo(selectedLangIndex);
                          return;
                        }
                      }
                      setState(() {
                        selectedLangIndex = index;
                      });
                    },
                    tabs: languages.map((lang) {
                      final isDef = lang['code'] == defaultLangCode;
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            Text(lang['name']),
                            ValueListenableBuilder(
                              valueListenable: _isValid,
                              builder: (context, value, child) {
                                return value && isDef
                                    ? child!
                                    : const SizedBox.shrink();
                              },
                              child: Icon(
                                Icons.check_box_rounded,
                                color: context.color.territoryColor,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              : null,
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (languages.length > 1)
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: _isValid,
                      builder: (context, value, child) {
                        return Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: value ? Colors.amber : Colors.red,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: CustomText(
                                (value
                                        ? "allRequiredDefaultLangFilled"
                                        : "pleaseFillDefaultLangRequiredMsg")
                                    .translate(context),
                                color: value ? Colors.amber : Colors.red,
                                fontSize: context.font.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              Container(
                color: Colors.transparent,
                child: UiUtils.buildButton(
                  context,
                  outerPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  onPressed: () {
                    adSlugController.text = adSlugController.text.replaceAll(
                      RegExp(r'^-+|-+$'),
                      '',
                    );
                    _isValid.value = _formKey.currentState?.validate() ?? false;
                    if (_isValid.value) {
                      mixedItemImageList
                          .where(
                            (element) => element != null && element is File,
                          )
                          .map((element) => element as File)
                          .toList();

                      // Build translations map for name and description (as strings, all language IDs present)
                      Map<String, Map<String, String>> translations = {};

                      for (var lang in languages) {
                        final langId = lang['id'].toString(); // e.g., "1", "2"
                        final langCode = lang['code']; // e.g., "en", "fr"

                        if (langCode == defaultLangCode)
                          continue; // Skip default language

                        final name =
                            adTitleControllers[langCode]?.text.trim() ?? '';
                        final description =
                            adDescriptionControllers[langCode]?.text.trim() ??
                            '';

                        final langTranslations = <String, String>{};

                        if (name.isNotEmpty) {
                          langTranslations['name'] = name;
                        }
                        if (description.isNotEmpty) {
                          langTranslations['description'] = description;
                        }

                        if (langTranslations.isNotEmpty) {
                          translations[langId] = langTranslations;
                        }
                      }

                      // Build SEO details map indexed by language ID
                      Map<String, Map<String, String>> seoDetails =
                          seoDetailsController.values;

                      print("translations***$translations");

                      if (mixedItemImageList.isEmpty) {
                        UiUtils.showBlurredDialoge(
                          context,
                          dialoge: BlurredDialogBox(
                            title: "imageRequired".translate(context),
                            content: CustomText(
                              "selectImageYourItem".translate(context),
                            ),
                          ),
                        );
                        return;
                      }

                      addCloudData("item_details", {
                        "name": adTitleControllers[defaultLangCode]!.text,
                        "slug": adSlugController.text,
                        "description":
                            adDescriptionControllers[defaultLangCode]!.text,
                        if (!widget.isEdit)
                          "category_id": widget.categoryTree!.last.id,
                        if (widget.isEdit) "id": item?.id,
                        "price": adPriceController.text,
                        "currency_id": selectedCurrency?.id,
                        "contact": phoneInputController.phoneNumber,
                        "region_code": phoneInputController.regionCode,
                        "video_link": adAdditionalDetailsController.text,
                        "gallery_images": mixedItemImageList,
                        "delete_item_image_id": deleteItemImageList,
                        if (isJobCategory)
                          "min_salary": minSalaryController.text,
                        if (isJobCategory)
                          "max_salary": maxSalaryController.text,
                        "translations": json.encode(translations),
                        "seo_details": seoDetails.isNotEmpty
                            ? seoDetails
                            : null,
                      });

                      log('${getCloudData('item_details')}');

                      if (context.read<FetchCustomFieldsCubit>().isEmpty()) {
                        Navigator.pushNamed(
                          context,
                          Routes.confirmLocationScreen,
                          arguments: {"isEdit": widget.isEdit},
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          Routes.addMoreDetailsScreen,
                          arguments: {
                            'context': context,
                            "isEdit": widget.isEdit == true,
                          },
                        );
                      }
                    }
                  },
                  height: 48,
                  fontSize: context.font.large,
                  buttonTitle: "next".translate(context),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  "youAreAlmostThere".translate(context),
                  fontSize: context.font.large,
                  fontWeight: FontWeight.w600,
                  color: context.color.textColorDark,
                ),
                SizedBox(height: 16),
                if (widget.categoryTree.isNotNullAndNotEmpty)
                  CategoryBreadcrumbs.static(
                    path: widget.categoryTree!,
                    onTap: (category) {
                      final effectiveIndex = category == null ? -1 : category;
                      Navigator.of(context).pop(effectiveIndex);
                    },
                  ),
                SizedBox(height: 18),
                CustomText(
                  isDefault
                      ? "adTitle".translate(context)
                      : "${'adTitle'.translate(context)} (${languages[selectedLangIndex]['name']})",
                ),
                SizedBox(height: 10),
                CustomTextFormField(
                  controller: adTitleControllers[selectedLangCode],
                  validator: isDefault
                      ? CustomTextFieldValidator.nullCheck
                      : null,
                  onChange: (value) {
                    adSlugController.text = generateSlug(value);
                  },
                  action: TextInputAction.next,
                  capitalization: TextCapitalization.sentences,
                  hintText: isDefault
                      ? "adTitleHere".translate(context)
                      : "${'adTitleHere'.translate(context)} (${languages[selectedLangIndex]['name']})",
                  hintTextStyle: TextStyle(
                    color: context.color.textDefaultColor.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: context.font.normal,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      isDefault
                          ? "descriptionLbl".translate(context)
                          : "${'descriptionLbl'.translate(context)} (${languages[selectedLangIndex]['name']})",
                    ),
                    BlocConsumer<
                      GenerateDescriptionCubit,
                      GenerateDescriptionState
                    >(
                      listener: (context, state) {
                        if (state is GenerateDescriptionSuccess) {
                          adDescriptionControllers[selectedLangCode]?.text =
                              state.description;
                        }
                        if (state is GenerateDescriptionFailure) {
                          HelperUtils.showSnackBarMessage(
                            context,
                            state.errorMessage,
                          );
                        }
                      },
                      builder: (context, state) {
                        return AIGenerateButton(
                          isLoading: state is GenerateDescriptionInProgress,
                          onPressed: () {
                            final canGenerate = _canGenerateWithAI(
                              selectedLangCode,
                            );
                            if (!canGenerate) {
                              HelperUtils.showSnackBarMessage(
                                context,
                                'titleIsRequiredForAIGeneration'.translate(
                                  context,
                                ),
                              );
                              return;
                            }

                            final title =
                                adTitleControllers[selectedLangCode]!.text;
                            var price = isJobCategory
                                ? HelperUtils.formattedSalaryRange(
                                    minSalaryController.text,
                                    maxSalaryController.text,
                                  )
                                : adPriceController.text;

                            context.read<GenerateDescriptionCubit>().generate(
                              title: title,
                              price: price,
                              languageId: languages[selectedLangIndex]['id']
                                  .toString(),
                              category:
                                  widget.categoryTree?.last.name.localized ??
                                  item!.category!.name.localized,
                              currencyISOCode:
                                  selectedCurrency?.code ??
                                  Constant.systemSettings.currencyIsoCode,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15),
                CustomTextFormField(
                  controller: adDescriptionControllers[selectedLangCode],
                  validator: isDefault
                      ? CustomTextFieldValidator.nullCheck
                      : null,
                  action: TextInputAction.newline,
                  capitalization: TextCapitalization.sentences,
                  hintText: isDefault
                      ? "writeSomething".translate(context)
                      : "${'writeSomething'.translate(context)} (${languages[selectedLangIndex]['name']})",
                  maxLine: 10,
                  minLine: 6,
                  hintTextStyle: TextStyle(
                    color: context.color.textDefaultColor.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: context.font.normal,
                  ),
                ),
                SizedBox(height: 10),
                CustomText("images".translate(context)),
                SizedBox(height: 2),
                CustomText(
                  "imagesNote".translate(context),
                  fontSize: context.font.smaller,
                  color: context.color.textDefaultColor.withValues(alpha: 0.5),
                ),
                SizedBox(height: 10),
                MultiImagePicker(
                  initialImages: mixedItemImageList,
                  onChanged: (images, deletedIds) {
                    mixedItemImageList = images;
                    deleteItemImageList = deletedIds;
                  },
                ),
                SizedBox(height: 10),
                CustomText(
                  isJobCategory
                      ? "salary".translate(context)
                      : "price".translate(context),
                ),
                SizedBox(height: 10),
                isJobCategory
                    ? buildSalaryRange()
                    : CustomTextFormField(
                        controller: adPriceController,
                        action: TextInputAction.next,
                        fixedPrefix: _buildCurrencyDropdown(context),
                        formaters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                        ],
                        keyboard: TextInputType.number,
                        validator: isPriceOptional
                            ? null
                            : CustomTextFieldValidator.nullCheck,
                        hintText: "0",
                      ),
                SizedBox(height: 10),
                CustomText("phoneNumber".translate(context)),
                SizedBox(height: 10),
                PhoneInput(controller: phoneInputController, required: false),
                SizedBox(height: 10),
                CustomText("videoLink".translate(context)),
                SizedBox(height: 10),
                CustomTextFormField(
                  controller: adAdditionalDetailsController,
                  validator: CustomTextFieldValidator.url,
                  hintText: "videoUrlAddHint".translate(context),
                  hintTextStyle: TextStyle(
                    color: context.color.textDefaultColor.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: context.font.normal,
                  ),
                ),
                SizedBox(height: 15),
                CustomText(
                  "${"adSlug".translate(context)}\t(${"englishOnlyLbl".translate(context)})",
                ),
                SizedBox(height: 10),
                CustomTextFormField(
                  controller: adSlugController,
                  formaters: [SlugFormatter()],
                  validator: CustomTextFieldValidator.slug,
                  action: TextInputAction.next,
                  hintText: "adSlugHere".translate(context),
                  hintTextStyle: TextStyle(
                    color: context.color.textDefaultColor.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: context.font.normal,
                  ),
                ),
                const SizedBox(height: 30),
                if (Constant.showSEOFields)
                  SEODetails(
                    languageId: languages[selectedLangIndex]['id'].toString(),
                    controller: seoDetailsController,
                    title: adTitleControllers[selectedLangCode]!.text,
                    price: adPriceController.text,
                    onAIGenerate: () {
                      final canGenerate = _canGenerateWithAI(selectedLangCode);
                      if (!canGenerate) {
                        HelperUtils.showSnackBarMessage(
                          context,
                          'titleIsRequiredForAIGeneration'.translate(context),
                        );
                        return;
                      }

                      final title = adTitleControllers[selectedLangCode]!.text;
                      var price = isJobCategory
                          ? HelperUtils.formattedSalaryRange(
                              minSalaryController.text,
                              maxSalaryController.text,
                            )
                          : adPriceController.text;

                      context.read<GenerateMetaCubit>().generate(
                        title: title,
                        price: price,
                        languageId: languages[selectedLangIndex]['id']
                            .toString(),
                        currencyISOCode:
                            selectedCurrency?.code ??
                            Constant.systemSettings.currencyIsoCode,
                        category:
                            widget.categoryTree?.last.name.localized ??
                            item!.category!.name.localized,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    return BlocBuilder<FetchCurrenciesCubit, FetchCurrenciesState>(
      builder: (context, state) {
        if (state is FetchCurrenciesSuccess) {
          final currencies = state.currencies;
          if (currencies.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Text(
                    Constant.systemSettings.currencySymbol,
                    style: context.titleMedium.bold,
                  ),
                  Text(
                    Constant.systemSettings.currencyIsoCode,
                    style: context.titleMedium.bold,
                  ),
                  SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      color: context.color.textDefaultColor,
                      width: 1,
                    ),
                  ),
                ],
              ),
            );
          }
          log('${selectedCurrency}');
          // Ensure selectedCurrency is set
          if (selectedCurrency == null) {
            log('${currencies}');
            selectedCurrency = context
                .read<FetchCurrenciesCubit>()
                .getSelectedCurrency();
          }

          Log.debug('${selectedCurrency?.code}');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: GestureDetector(
              onTap: () {
                _showCurrencyPicker(context, currencies);
              },
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Flexible(
                      child: Text(
                        selectedCurrency?.symbol ??
                            Constant.systemSettings.currencySymbol,
                        maxLines: 1,
                        style: context.titleSmall.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        selectedCurrency?.code ??
                            Constant.systemSettings.currencyIsoCode,
                        maxLines: 1,
                        style: context.titleSmall.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: context.color.textDefaultColor,
                    ),
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        color: context.color.textDefaultColor,
                        width: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is FetchCurrenciesInProgress) {
          return ConstrainedBox(
            constraints: BoxConstraints.tight(Size.square(24)),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.color.textDefaultColor,
                ),
              ),
            ),
          );
        } else {
          // Fallback to default currency symbol
          return ConstrainedBox(
            constraints: BoxConstraints.tight(Size.square(24)),
            child: Center(
              child: CustomText(
                Constant.systemSettings.currencySymbol,
                fontSize: context.font.large,
                color: context.color.textDefaultColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, List<Currency> currencies) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Currency", style: context.titleMedium.bold),
            SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = selectedCurrency?.id == currency.id;
                  return ListTile(
                    title: Text('${currency.code} (${currency.symbol})'),
                    trailing: isSelected
                        ? Icon(Icons.check, color: context.color.territoryColor)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedCurrency = currency;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSalaryRange() {
    String? rangeChecker() {
      final min = int.tryParse(minSalaryController.text);
      final max = int.tryParse(maxSalaryController.text);

      if (min == null || max == null) return null;

      if (min < max) {
        return null;
      } else {
        return "invalidRange".translate(context);
      }
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomTextFormField(
            controller: minSalaryController,
            action: TextInputAction.next,
            fixedPrefix: _buildCurrencyDropdown(context),
            formaters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+'))],
            validatorFunction: (value) => rangeChecker(),
            keyboard: TextInputType.number,
            hintText: "min".translate(context),
            hintTextStyle: TextStyle(
              color: context.color.textDefaultColor.withValues(alpha: 0.5),
              fontSize: context.font.normal,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CustomTextFormField(
            controller: maxSalaryController,
            action: TextInputAction.next,
            fixedPrefix: _buildCurrencyDropdown(context),
            validatorFunction: (value) => rangeChecker(),
            formaters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+'))],
            keyboard: TextInputType.number,
            hintText: "max".translate(context),
            hintTextStyle: TextStyle(
              color: context.color.textDefaultColor.withValues(alpha: 0.5),
              fontSize: context.font.normal,
            ),
          ),
        ),
      ],
    );
  }

  void addDataToCloud(String key) {
    addCloudData(key, {
      "name": adTitleControllers[defaultLangCode]!.text,
      "slug": adSlugController.text,
      "description": adDescriptionControllers[defaultLangCode]!.text,
      if (!widget.isEdit) "category_id": widget.categoryTree!.last.id,
      if (widget.isEdit) "id": item?.id,
      "price": adPriceController.text,
      "currency_id": selectedCurrency?.id,
      "contact": phoneInputController.phoneNumber,
      "region_code": phoneInputController.regionCode,
      "video_link": adAdditionalDetailsController.text,
      "gallery_images": mixedItemImageList,
      "delete_item_image_id": deleteItemImageList,
      if (isJobCategory)
        "min_salary": ?(minSalaryController.text.isNotEmpty
            ? minSalaryController.text
            : null),
      if (isJobCategory)
        "max_salary": ?(maxSalaryController.text.isNotEmpty
            ? maxSalaryController.text
            : null),
    });
  }

  bool _canGenerateWithAI(String languageCode) {
    final title = adTitleControllers[languageCode]!.text;

    return title.isNotEmpty;
  }
}
