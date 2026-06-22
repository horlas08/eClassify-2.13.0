import 'dart:async';

import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/gallery_screen.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/video_player_widget.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/build_context.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MediaGallery extends StatefulWidget {
  const MediaGallery({
    required this.gallery,
    this.videoUrl,
    this.allowAutoSlider = true,
    this.isFullScreen = false,
    this.initialIndex = 0,
    super.key,
  });

  final List<GalleryImages> gallery;
  final String? videoUrl;
  final bool allowAutoSlider;
  final bool isFullScreen;
  final int initialIndex;

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  Timer? _timer;
  late final PageController _controller;
  late final List<String> _images;
  late final int _totalPages;

  bool get _hasVideo => widget.videoUrl.isNotNullAndNotEmpty;

  bool get _isYoutubeLink {
    if (!_hasVideo) return false;
    final uri = Uri.tryParse(widget.videoUrl!);
    if (uri == null) return false;
    return uri.host.contains('youtu.be') || uri.host.contains('youtube.com');
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _extractImages();
    _setTotalPages();
    if (widget.allowAutoSlider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _clearTimer();
    super.dispose();
  }

  void _extractImages() {
    final galleryImages = widget.gallery.map((e) => e.image!).toList();
    _images = galleryImages;
  }

  void _setTotalPages() {
    var count = _images.length;
    if (_hasVideo) {
      count++;
    }
    _totalPages = count;
  }

  void _clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _clearTimer();
    if (_totalPages > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
    }
  }

  void _nextPage() {
    if (!mounted || _totalPages <= 1) return;
    final currentPage = _controller.page?.round() ?? 0;
    final nextPage = (currentPage + 1) % _totalPages;

    _controller.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isFullScreen) return;
        final index = _controller.page?.toInt() ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryScreen(
              gallery: widget.gallery,
              videoUrl: widget.videoUrl,
              initialIndex: index,
            ),
          ),
        );
      },
      child: PageView.builder(
        controller: _controller,
        itemCount: _totalPages,
        itemBuilder: (context, index) {
          final isVideo = _hasVideo && index == _totalPages - 1;

          if (isVideo && widget.isFullScreen) {
            return VideoPlayerWidget(
              videoUrl: widget.videoUrl!,
              isYoutubeVideo: _isYoutubeLink,
            );
          }

          var image = switch ((isVideo, _isYoutubeLink)) {
            (true, true) => YoutubePlayer.getThumbnail(
              videoId: YoutubePlayer.convertUrlToId(widget.videoUrl!)!,
            ),
            (true, false) => _images.first,
            (false, _) => _images[index],
          };
          return _MediaItem(
            image: image,
            isVideo: isVideo,
            isFullScreen: widget.isFullScreen,
          );
        },
      ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  const _MediaItem({
    required this.image,
    this.isVideo = false,
    this.isFullScreen = false,
  });

  final String image;
  final bool isVideo;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    final imageSize = context.sizeFromAspectRatio(16 / 9);
    return Padding(
      padding: Constant.appContentPadding.copyWith(top: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isFullScreen ? 0 : 16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomImage(
              src: image,
              size: imageSize,
              fit: isFullScreen ? BoxFit.contain : BoxFit.cover,
            ),
            if (isVideo && !isFullScreen)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
