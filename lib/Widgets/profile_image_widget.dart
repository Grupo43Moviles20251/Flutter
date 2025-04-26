import 'package:flutter/material.dart';

import '../Services/profile_image_lru.dart';

class ProfileImageWithLRUCache extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final bool isOnline;

  const ProfileImageWithLRUCache({
    super.key,
    required this.imageUrl,
    this.radius = 60,
    required this.isOnline,
  });

  @override
  _ProfileImageWithLRUCacheState createState() => _ProfileImageWithLRUCacheState();
}

class _ProfileImageWithLRUCacheState extends State<ProfileImageWithLRUCache> {
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ProfileImageWithLRUCache oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  void _loadImage() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (mounted) {
      setState(() {
      _loading = true;
      _error = false;
    });
    }

    try {
      // 1. Verificar si está en caché
      final cachedImage = ProfileImageCache().get(widget.imageUrl!);
      if (cachedImage != null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // 2. Si no está en caché y hay conexión, cargar de red
      if (widget.isOnline) {
        final networkImage = NetworkImage(widget.imageUrl!);
        final stream = networkImage.resolve(ImageConfiguration.empty);

        stream.addListener(ImageStreamListener((info, _) async {
          final image = info.image;
          ProfileImageCache().put(widget.imageUrl!, image);
          if (mounted) setState(() => _loading = false);
        }, onError: (_, __) {
          if (mounted) {
            setState(() {
            _loading = false;
            _error = true;
          });
          }
        }));
      } else {
        // 3. Sin conexión y no en caché
        if (mounted) {
          setState(() {
          _loading = false;
          _error = true;
        });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
        _loading = false;
        _error = true;
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.grey[200],
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return Icon(
        Icons.person,
        size: widget.radius,
        color: Colors.grey[600],
      );
    }

    if (_loading) {
      return CircularProgressIndicator();
    }

    if (_error) {
      return Icon(
        Icons.error,
        size: widget.radius,
        color: Colors.grey[600],
      );
    }

    final cachedImage = ProfileImageCache().get(widget.imageUrl!);
    if (cachedImage != null) {
      return ClipOval(
        child: RawImage(
          image: cachedImage,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
        ),
      );
    }

    return Icon(
      Icons.person,
      size: widget.radius,
      color: Colors.grey[600],
    );
  }
}