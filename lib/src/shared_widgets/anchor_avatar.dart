import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AnchorAvatar extends StatelessWidget {
  final double size;
  final bool isLive;
  const AnchorAvatar({super.key, this.size = 60, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 1, color: Colors.grey.shade300),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: 'https://placehold.co/400x400/FFFFFF/898989.png?text=Image',
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: const ColoredBox(color: Colors.grey),
              ),
              errorWidget: (context, url, error) =>
                  ColoredBox(color: Colors.grey.shade200),
            ),
          ),
        ),
        Positioned(
          bottom: -4,
          child: Badge(
            padding: EdgeInsets.symmetric(horizontal: 6),
            label: Text('Live', style: TextStyle(fontSize: 12 * (size / 60))),
            backgroundColor: Colors.pink,
          ),
        ),
      ],
    );
  }
}
