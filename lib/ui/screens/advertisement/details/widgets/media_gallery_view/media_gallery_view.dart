import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/media_gallery.dart';
import 'package:eClassify/ui/screens/home/widgets/favorite_button.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';

class MediaGalleryView extends StatelessWidget {
  const MediaGalleryView({required this.item, super.key});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          MediaGallery(gallery: item.galleryImages!, videoUrl: item.videoLink),
          PositionedDirectional(
            end: Constant.horizontalPadding + 8,
            top: 8,
            child: FavoriteButton(item: item),
          ),
        ],
      ),
    );
  }
}
