// lib/widgets/cached_avatar.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedAvatar extends StatelessWidget {
  final String url;
  final double radius;

  const CachedAvatar({super.key, required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[800],
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Colors.grey[800]),
          errorWidget: (_, __, ___) => Icon(
            Icons.person,
            color: Colors.grey[600],
            size: radius,
          ),
        ),
      ),
    );
  }
}
