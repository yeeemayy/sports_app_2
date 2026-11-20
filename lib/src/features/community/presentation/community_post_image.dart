import 'dart:io';

import 'package:flutter/material.dart';

import '../../../shared_widgets/app_network_image.dart';

/// A post's [CommunityPost.imageUrl] is a real network URL for the mock feed
/// data, but a local file path for anything created via
/// [CommunityCreatePostScreen] — there's no real upload endpoint yet
/// ([CommunityRepository.createPost] just keeps the picked file). Render
/// whichever it is.
class CommunityPostImage extends StatelessWidget {
  const CommunityPostImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('http')) {
      return AppNetworkImage(url: url, size: double.infinity, borderRadius: BorderRadius.zero);
    }
    return Image.file(File(url), fit: BoxFit.cover, width: double.infinity);
  }
}
