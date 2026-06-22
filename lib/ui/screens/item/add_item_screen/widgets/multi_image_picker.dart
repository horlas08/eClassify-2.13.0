import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/file_picker_utility.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MultiImagePicker extends StatefulWidget {
  final List<dynamic> initialImages;
  final Function(List<dynamic> images, List<int> deletedImageIds) onChanged;
  final int maxImages;

  const MultiImagePicker({
    super.key,
    this.initialImages = const [],
    required this.onChanged,
    this.maxImages = 6,
  });

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  late List<dynamic> _images;
  final List<int> _deletedImageIds = [];

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  void _onAddImages() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  "selectImageSource".translate(context),
                  fontSize: context.font.larger,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildSourceCard(
                      context,
                      title: "camera".translate(context),
                      icon: Icons.camera_alt_rounded,
                      onTap: () => _pickImages(PickSource.camera),
                    ),
                    const SizedBox(width: 15),
                    _buildSourceCard(
                      context,
                      title: "gallery".translate(context),
                      icon: Icons.photo_library_rounded,
                      onTap: () => _pickImages(PickSource.gallery),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: context.color.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Icon(icon, size: 24, color: context.colorScheme.primary),
                Text(title, style: context.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages(PickSource source) async {
    final remaining = widget.maxImages - _images.length;
    if (remaining <= 0) {
      HelperUtils.showSnackBarMessage(
        context,
        "maxLimitReached".translate(context),
      );
      return;
    }

    final pickedFiles = await FilePickerUtility.pick(
      source: source,
      allowMultiple: source == PickSource.gallery,
      limit: remaining,
      type: Platform.isIOS ? FileType.image : FileType.custom,
      allowedExtensions: Platform.isIOS ? null : ['jpg', 'jpeg', 'png'],
      onLimitExceeded: () {
        HelperUtils.showSnackBarMessage(
          context,
          "onlyXImagesAllowed".translate(context, {
            'max_count': widget.maxImages.toString(),
          }),
        );
      },
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles);
        widget.onChanged(_images, _deletedImageIds);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      final removed = _images.removeAt(index);
      if (removed is GalleryImages && removed.id != null) {
        _deletedImageIds.add(removed.id!);
      }
      widget.onChanged(_images, _deletedImageIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...List.generate(_images.length, (index) {
              return _buildImageItem(index);
            }),
            if (_images.length < widget.maxImages) _buildAddButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageItem(int index) {
    final image = _images[index];
    final isPrimary = index == 0;
    String? imageSrc;

    if (image is String) {
      imageSrc = image;
    } else if (image is File) {
      imageSrc = image.path;
    } else if (image is GalleryImages) {
      imageSrc = image.image;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            final imageProvider = switch (image) {
              String() => NetworkImage(image),
              File() => FileImage(image),
              GalleryImages() => NetworkImage(image.image!),
              _ => throw UnimplementedError(),
            };
            UiUtils.showFullScreenImage(
              context,
              provider: imageProvider as ImageProvider,
            );
          },
          child: SizedBox.square(
            dimension: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImage(src: imageSrc!, fit: BoxFit.cover),
            ),
          ),
        ),
        if (isPrimary)
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  "primary".translate(context),
                  style: context.labelSmall.withColor(
                    context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        PositionedDirectional(
          top: -5,
          end: -5,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.color.inverseThemeColor.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: context.color.secondaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _onAddImages,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: context.mutedColor,
          radius: const Radius.circular(10),
        ),
        child: SizedBox.square(
          dimension: 100,
          child: Center(
            child: Icon(Icons.add_a_photo_outlined, color: context.mutedColor),
          ),
        ),
      ),
    );
  }
}
