import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/movie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/shimmer_loader.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppDimensions.movieCardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(),
            const SizedBox(height: 8),
            _buildTitle(),
            const SizedBox(height: 4),
            _buildMeta(),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: CachedNetworkImage(
            imageUrl: movie.posterUrl,
            width: AppDimensions.movieCardWidth,
            height: AppDimensions.movieCardHeight,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ShimmerWidget(
              width: AppDimensions.movieCardWidth,
              height: AppDimensions.movieCardHeight,
              borderRadius: AppDimensions.radiusM,
            ),
            errorWidget: (_, __, ___) => _posterFallback(),
          ),
        ),
        // Certification badge
        Positioned(
          top: 8,
          left: 8,
          child: _CertBadge(cert: movie.certification),
        ),
        // Rating badge (only for released movies)
        if (movie.isNowShowing && movie.rating > 0)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _RatingBar(rating: movie.rating),
          ),
      ],
    );
  }

  Widget _posterFallback() {
    return Container(
      width: AppDimensions.movieCardWidth,
      height: AppDimensions.movieCardHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: const Icon(Icons.movie_outlined,
          color: AppColors.textHint, size: 40),
    );
  }

  Widget _buildTitle() {
    return Text(
      movie.title,
      style: AppTextStyles.labelLarge,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMeta() {
    final genres = movie.genres.take(2).join(' • ');
    return Text(
      genres,
      style: AppTextStyles.caption,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _CertBadge extends StatelessWidget {
  final String cert;
  const _CertBadge({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        cert,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'Gilroy',
        ),
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final double rating;
  const _RatingBar({required this.rating});

  Color get _ratingColor {
    if (rating >= 8) return AppColors.green;
    if (rating >= 6) return AppColors.orange;
    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radiusM),
        ),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: _ratingColor, size: 13),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: _ratingColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Gilroy',
            ),
          ),
          const SizedBox(width: 4),
          Text(
            movie.formattedVotes,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontFamily: 'Gilroy',
            ),
          ),
        ],
      ),
    );
  }
} 