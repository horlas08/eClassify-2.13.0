import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.videoUrl,
    required this.isYoutubeVideo,
    super.key,
  });
  final String videoUrl;
  final bool isYoutubeVideo;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  YoutubePlayerController? _youtubePlayerController;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.isYoutubeVideo) {
      _setupYoutubeController();
    } else {
      _setupVideoController();
    }
  }

  @override
  void dispose() {
    _youtubePlayerController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _setupYoutubeController() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, disableDragSeek: true),
      );
    }
  }

  void _setupVideoController() {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..addListener(() {
            if (mounted) setState(() {});
          })
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized
            if (mounted) setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.isYoutubeVideo) {
      if (_youtubePlayerController == null) {
        return const Center(child: Text('Invalid Youtube URL'));
      }
      return YoutubePlayer(
        controller: _youtubePlayerController!,
        showVideoProgressIndicator: true,
      );
    } else {
      if (_videoPlayerController == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: _videoPlayerController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_videoPlayerController!),
                    VideoProgressIndicator(
                      _videoPlayerController!,
                      allowScrubbing: _videoPlayerController!.value.isPlaying,
                    ),
                    _PlayPauseOverlay(controller: _videoPlayerController!),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      );
    }
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
