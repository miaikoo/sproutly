import 'package:flutter/material.dart';

import '../../core/services/image_upload_service.dart';

/// Renders an activity picture whether it is a bundled asset or a photo the
/// parent uploaded.
///
/// Every place that shows an activity card goes through this, so adding photo
/// upload did not mean auditing fifteen `Image.asset` call sites for the one
/// that would throw on an `https://` path.
class ActivityImage extends StatelessWidget {
  const ActivityImage(this.image, {super.key, this.fit = BoxFit.contain});

  final String image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (!isUploadedImage(image)) {
      return Image.asset(image, fit: fit);
    }

    return Image.network(
      image,
      fit: fit,
      // A parent on a slow home connection should see something happening
      // rather than a blank card.
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      // A broken photo must not take the whole board down with it.
      errorBuilder: (context, error, stack) => const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.black38),
      ),
    );
  }
}
