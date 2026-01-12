import 'dart:io';

import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    this.borderRadius = 12,
    this.aspectRatio = 4 / 3,
  });

  final String? imagePath;
  final double borderRadius;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _ImageFrame(
        borderRadius: borderRadius,
        aspectRatio: aspectRatio,
        child: _Placeholder(),
      );
    }

    final isNetwork =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');
    final image = isNetwork
        ? Image.network(
            trimmed,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _Placeholder(),
          )
        : Image.file(
            File(trimmed),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _Placeholder(),
          );

    return _ImageFrame(
      borderRadius: borderRadius,
      aspectRatio: aspectRatio,
      child: image,
    );
  }
}

class _ImageFrame extends StatelessWidget {
  const _ImageFrame({
    required this.borderRadius,
    required this.aspectRatio,
    required this.child,
  });

  final double borderRadius;
  final double aspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: child,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}
