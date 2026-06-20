import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../widgets/shimmer_loader.dart';

class BannerCarousel extends StatefulWidget {
  final List<Movie> movies;
  final void Function(Movie) onMovieTap;

  const BannerCarousel({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;

  List<Movie> get _bannerMovies =>
      widget.movies.where((m) => m.bannerUrl != null).take(5).toList();

  @override
  Widget build(BuildContext context) {
    if (_bannerMovies.isEmpty) return const BannerShimmer();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _bannerMovies.length,
          itemBuilder: (context, index, _) {
            final movie = _bannerMovies[index];
            return _BannerItem(
              movie: movie,
              onTap: () => widget.onMovieTap(movie),
            );
          },
          options: CarouselOptions(
            height: 210,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (i, _) => setState(() => _currentIndex = i),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: _bannerMovies.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: AppColors.primary,
            dotColor: AppColors.border,
            expansionFactor: 3,
            spacing: 4,
          ),
        ),
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _BannerItem({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.bannerUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceLight),
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.surfaceLight),
            ),
            // Gradient overlay for text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            // Movie info at the bottom
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: AppTextStyles.h2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (movie.rating > 0) ...[
                        const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${movie.rating}/10',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          movie.genres.take(3).join(' • '),
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 