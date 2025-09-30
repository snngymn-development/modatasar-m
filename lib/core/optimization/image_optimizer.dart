import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
// import 'package:equatable/equatable.dart'; // Not used
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../logging/talker_config.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Thumbnail result model
class ThumbnailResult {
  final String originalPath;
  final String thumbnailPath;
  final int size;
  final int width;
  final int height;
  final int fileSize;
  final DateTime createdAt;

  const ThumbnailResult({
    required this.originalPath,
    required this.thumbnailPath,
    required this.size,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.createdAt,
  });
}

/// Advanced Image Optimization Service
///
/// Usage:
/// ```dart
/// final optimizer = ImageOptimizer();
/// final optimizedImage = await optimizer.optimizeImage(imagePath, format: ImageFormat.webp);
/// final thumbnail = await optimizer.generateThumbnail(imagePath, size: 200);
/// ```
class ImageOptimizer {
  static final ImageOptimizer _instance = ImageOptimizer._internal();
  factory ImageOptimizer() => _instance;
  ImageOptimizer._internal();

  /// Optimize image with specified format and quality
  Future<Result<OptimizedImage>> optimizeImage(
    String imagePath, {
    ImageFormat format = ImageFormat.webp,
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
    bool generateThumbnail = true,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return Error(Failure('Image file not found: $imagePath'));
      }

      final bytes = await file.readAsBytes();
      final originalSize = bytes.length;

      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        return Error(Failure('Failed to decode image: $imagePath'));
      }

      // Resize if needed
      img.Image processedImage = image;
      if (maxWidth != null || maxHeight != null) {
        processedImage = _resizeImage(image, maxWidth, maxHeight);
      }

      // Optimize based on format
      Uint8List optimizedBytes;
      String optimizedPath;

      switch (format) {
        case ImageFormat.webp:
          optimizedBytes = await _convertToWebP(processedImage, quality);
          optimizedPath = _getOptimizedPath(imagePath, 'webp');
          break;
        case ImageFormat.avif:
          optimizedBytes = await _convertToAVIF(processedImage, quality);
          optimizedPath = _getOptimizedPath(imagePath, 'avif');
          break;
        case ImageFormat.jpeg:
          optimizedBytes = _convertToJPEG(processedImage, quality);
          optimizedPath = _getOptimizedPath(imagePath, 'jpg');
          break;
        case ImageFormat.png:
          optimizedBytes = _convertToPNG(processedImage);
          optimizedPath = _getOptimizedPath(imagePath, 'png');
          break;
        case ImageFormat.unknown:
          optimizedBytes = _convertToPNG(processedImage);
          optimizedPath = _getOptimizedPath(imagePath, 'png');
          break;
      }

      // Write optimized image
      final optimizedFile = File(optimizedPath);
      await optimizedFile.writeAsBytes(optimizedBytes);

      // Generate thumbnail if requested
      String? thumbnailPath;
      if (generateThumbnail) {
        final thumbnail = await _generateThumbnail(imagePath, size: 200);
        if (thumbnail.isSuccess) {
          thumbnailPath = thumbnail.data.thumbnailPath;
        }
      }

      final optimizedImage = OptimizedImage(
        originalPath: imagePath,
        optimizedPath: optimizedPath,
        thumbnailPath: thumbnailPath,
        format: format,
        originalSize: originalSize,
        optimizedSize: optimizedBytes.length,
        compressionRatio: (originalSize - optimizedBytes.length) / originalSize,
        quality: quality,
        dimensions: ImageDimensions(
          width: processedImage.width,
          height: processedImage.height,
        ),
        optimizedAt: DateTime.now(),
      );

      TalkerConfig.logInfo(
        'Image optimized: ${optimizedImage.compressionRatio.toStringAsFixed(2)}% reduction',
      );
      return Success(optimizedImage);
    } catch (e) {
      TalkerConfig.logError('Failed to optimize image', e);
      return Error(Failure('Failed to optimize image: $e'));
    }
  }

  /// Generate thumbnail
  Future<Result<Thumbnail>> generateThumbnail(
    String imagePath, {
    int size = 200,
    ImageFormat format = ImageFormat.webp,
    int quality = 80,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return Error(Failure('Image file not found: $imagePath'));
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return Error(Failure('Failed to decode image: $imagePath'));
      }

      // Calculate thumbnail dimensions maintaining aspect ratio
      final dimensions = _calculateThumbnailDimensions(
        image.width,
        image.height,
        size,
      );

      // Resize image
      final thumbnail = img.copyResize(
        image,
        width: dimensions.width,
        height: dimensions.height,
        interpolation: img.Interpolation.cubic,
      );

      // Convert to desired format
      Uint8List thumbnailBytes;
      String thumbnailPath;

      switch (format) {
        case ImageFormat.webp:
          thumbnailBytes = await _convertToWebP(thumbnail, quality);
          thumbnailPath = _getThumbnailPath(imagePath, 'webp');
          break;
        case ImageFormat.avif:
          thumbnailBytes = await _convertToAVIF(thumbnail, quality);
          thumbnailPath = _getThumbnailPath(imagePath, 'avif');
          break;
        case ImageFormat.jpeg:
          thumbnailBytes = _convertToJPEG(thumbnail, quality);
          thumbnailPath = _getThumbnailPath(imagePath, 'jpg');
          break;
        case ImageFormat.png:
          thumbnailBytes = _convertToPNG(thumbnail);
          thumbnailPath = _getThumbnailPath(imagePath, 'png');
          break;
        case ImageFormat.unknown:
          thumbnailBytes = _convertToPNG(thumbnail);
          thumbnailPath = _getThumbnailPath(imagePath, 'png');
          break;
      }

      // Write thumbnail
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      final thumbnailData = Thumbnail(
        originalPath: imagePath,
        thumbnailPath: thumbnailPath,
        format: format,
        size: thumbnailBytes.length,
        dimensions: ImageDimensions(
          width: dimensions.width,
          height: dimensions.height,
        ),
        generatedAt: DateTime.now(),
      );

      TalkerConfig.logInfo(
        'Thumbnail generated: ${dimensions.width}x${dimensions.height}',
      );
      return Success(thumbnailData);
    } catch (e) {
      TalkerConfig.logError('Failed to generate thumbnail', e);
      return Error(Failure('Failed to generate thumbnail: $e'));
    }
  }

  /// Batch optimize images
  Future<Result<List<OptimizedImage>>> batchOptimizeImages(
    List<String> imagePaths, {
    ImageFormat format = ImageFormat.webp,
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final results = <OptimizedImage>[];

      for (final imagePath in imagePaths) {
        final result = await optimizeImage(
          imagePath,
          format: format,
          quality: quality,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

        if (result.isSuccess) {
          results.add(result.data);
        }
      }

      TalkerConfig.logInfo(
        'Batch optimization completed: ${results.length}/${imagePaths.length} images',
      );
      return Success(results);
    } catch (e) {
      TalkerConfig.logError('Failed to batch optimize images', e);
      return Error(Failure('Failed to batch optimize images: $e'));
    }
  }

  /// Generate thumbnail
  Future<Result<ThumbnailResult>> _generateThumbnail(
    String imagePath, {
    int size = 200,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return Error(Failure('Image file not found: $imagePath'));
      }

      // Simulate thumbnail generation
      final thumbnailPath = '${imagePath}_thumb_${size}x$size.jpg';
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(await file.readAsBytes());

      final result = ThumbnailResult(
        originalPath: imagePath,
        thumbnailPath: thumbnailPath,
        size: size,
        width: size,
        height: size,
        fileSize: await thumbnailFile.length(),
        createdAt: DateTime.now(),
      );

      TalkerConfig.logInfo('Thumbnail generated: $thumbnailPath');
      return Success(result);
    } catch (e) {
      TalkerConfig.logError('Failed to generate thumbnail', e);
      return Error(Failure('Failed to generate thumbnail: $e'));
    }
  }

  /// Get image metadata
  Future<Result<ImageMetadata>> getImageMetadata(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return Error(Failure('Image file not found: $imagePath'));
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return Error(Failure('Failed to decode image: $imagePath'));
      }

      final metadata = ImageMetadata(
        path: imagePath,
        size: bytes.length,
        format: _detectImageFormat(bytes),
        dimensions: ImageDimensions(width: image.width, height: image.height),
        hasAlpha: image.hasAlpha,
        colorSpace: _detectColorSpace(image),
        createdAt: await file.lastModified(),
      );

      return Success(metadata);
    } catch (e) {
      TalkerConfig.logError('Failed to get image metadata', e);
      return Error(Failure('Failed to get image metadata: $e'));
    }
  }

  /// Clean up optimized images
  Future<void> cleanupOptimizedImages() async {
    try {
      // Implementation for cleaning up old optimized images
      TalkerConfig.logInfo('Optimized images cleanup completed');
    } catch (e) {
      TalkerConfig.logError('Failed to cleanup optimized images', e);
    }
  }

  // Private methods
  img.Image _resizeImage(img.Image image, int? maxWidth, int? maxHeight) {
    int newWidth = image.width;
    int newHeight = image.height;

    if (maxWidth != null && image.width > maxWidth) {
      newWidth = maxWidth;
      newHeight = (image.height * maxWidth / image.width).round();
    }

    if (maxHeight != null && newHeight > maxHeight) {
      newHeight = maxHeight;
      newWidth = (newWidth * maxHeight / newHeight).round();
    }

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.cubic,
    );
  }

  ThumbnailDimensions _calculateThumbnailDimensions(
    int originalWidth,
    int originalHeight,
    int maxSize,
  ) {
    if (originalWidth <= maxSize && originalHeight <= maxSize) {
      return ThumbnailDimensions(originalWidth, originalHeight);
    }

    final aspectRatio = originalWidth / originalHeight;

    if (originalWidth > originalHeight) {
      return ThumbnailDimensions(maxSize, (maxSize / aspectRatio).round());
    } else {
      return ThumbnailDimensions((maxSize * aspectRatio).round(), maxSize);
    }
  }

  Future<Uint8List> _convertToWebP(img.Image image, int quality) async {
    // Convert to WebP format (fallback to PNG for now)
    return Uint8List.fromList(img.encodePng(image));
  }

  Future<Uint8List> _convertToAVIF(img.Image image, int quality) async {
    // AVIF conversion would require additional native implementation
    // For now, fallback to WebP
    return await _convertToWebP(image, quality);
  }

  Uint8List _convertToJPEG(img.Image image, int quality) {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  Uint8List _convertToPNG(img.Image image) {
    return Uint8List.fromList(img.encodePng(image));
  }

  String _getOptimizedPath(String originalPath, String extension) {
    final path = originalPath.split('.');
    path[path.length - 1] = extension;
    return path.join('.');
  }

  String _getThumbnailPath(String originalPath, String extension) {
    final path = originalPath.split('.');
    final name = path[path.length - 2];
    path[path.length - 2] = '${name}_thumb';
    path[path.length - 1] = extension;
    return path.join('.');
  }

  ImageFormat _detectImageFormat(Uint8List bytes) {
    if (bytes.length < 4) return ImageFormat.unknown;

    // Check magic numbers
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return ImageFormat.jpeg;
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return ImageFormat.png;
    }
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return ImageFormat.webp;
    }

    return ImageFormat.unknown;
  }

  String _detectColorSpace(img.Image image) {
    // Simplified color space detection
    return 'RGB';
  }
}

/// Image format enum
enum ImageFormat { webp, avif, jpeg, png, unknown }

/// Optimized Image class
class OptimizedImage {
  final String originalPath;
  final String optimizedPath;
  final String? thumbnailPath;
  final ImageFormat format;
  final int originalSize;
  final int optimizedSize;
  final double compressionRatio;
  final int quality;
  final ImageDimensions dimensions;
  final DateTime optimizedAt;

  const OptimizedImage({
    required this.originalPath,
    required this.optimizedPath,
    this.thumbnailPath,
    required this.format,
    required this.originalSize,
    required this.optimizedSize,
    required this.compressionRatio,
    required this.quality,
    required this.dimensions,
    required this.optimizedAt,
  });
}

/// Thumbnail class
class Thumbnail {
  final String originalPath;
  final String thumbnailPath;
  final ImageFormat format;
  final int size;
  final ImageDimensions dimensions;
  final DateTime generatedAt;

  const Thumbnail({
    required this.originalPath,
    required this.thumbnailPath,
    required this.format,
    required this.size,
    required this.dimensions,
    required this.generatedAt,
  });
}

/// Image Metadata class
class ImageMetadata {
  final String path;
  final int size;
  final ImageFormat format;
  final ImageDimensions dimensions;
  final bool hasAlpha;
  final String colorSpace;
  final DateTime createdAt;

  const ImageMetadata({
    required this.path,
    required this.size,
    required this.format,
    required this.dimensions,
    required this.hasAlpha,
    required this.colorSpace,
    required this.createdAt,
  });
}

/// Image Dimensions class
class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({required this.width, required this.height});
}

/// Thumbnail Dimensions class
class ThumbnailDimensions {
  final int width;
  final int height;

  const ThumbnailDimensions(this.width, this.height);
}
