import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
// Not re-exported by cached_network_image; used to fix web image rendering
// (HttpGet decodes through Skia — the HTML renderer no longer exists).
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart'
    show ImageRenderMethodForWeb;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../domain/entities/movie.dart';
import '../../bloc/search/search_bloc.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_loader.dart';

/// Full-screen search opened from the Home search bar. The query is debounced
/// in the UI; all business logic lives in [SearchBloc].
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _debounceDuration = Duration(milliseconds: 400);

  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    // Empty / whitespace-only input clears immediately — no debounce needed.
    if (value.trim().isEmpty) {
      context.read<SearchBloc>().add(const SearchCleared());
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      context.read<SearchBloc>().add(SearchQueryChanged(value));
    });
  }

  /// Keyboard action (search/done) flushes the debounce for an instant search.
  void _onSubmitted(String value) {
    _debounce?.cancel();
    context.read<SearchBloc>().add(SearchQueryChanged(value));
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  void _openMovieDetails(Movie movie) {
    FocusManager.instance.primaryFocus?.unfocus();
    // Same route as every other movie entry point (home cards / banner).
    context.push('/movie/${movie.id}', extra: movie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildSearchField(),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) return _buildLoading();
          if (state is SearchSuccess) return _buildResults(state.results);
          if (state is SearchEmpty) return _buildEmpty(state.query);
          if (state is SearchFailure) return _buildError(state);
          return _buildPrompt();
        },
      ),
    );
  }

  // ─── Search field ──────────────────────────────────────────────────────────

  Widget _buildSearchField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              style: AppTextStyles.bodyMedium,
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontFamily: 'Gilroy',
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: _onQueryChanged,
              onSubmitted: _onSubmitted,
            ),
          ),
          // Rebuilds only the clear button when the text changes.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: _clearSearch,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.textHint, size: 18),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── States ────────────────────────────────────────────────────────────────

  Widget _buildPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.manage_search_rounded,
              color: AppColors.textHint, size: 56),
          const SizedBox(height: 16),
          Text(AppStrings.searchPromptTitle, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            AppStrings.searchPromptSubtitle,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, _) => const _ResultTileShimmer(),
    );
  }

  Widget _buildResults(List<Movie> movies) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: movies.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _SearchResultTile(
        movie: movies[i],
        onTap: () => _openMovieDetails(movies[i]),
      ),
    );
  }

  Widget _buildEmpty(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.textHint, size: 56),
            const SizedBox(height: 16),
            Text(AppStrings.noResultsFound, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('"$query"', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Text(
              AppStrings.searchNoResultsHint,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(SearchFailure state) {
    // Reuses the shared error widget (message + Try Again action).
    return AppErrorWidget(
      message: state.message,
      onRetry: () => context.read<SearchBloc>().add(const SearchRetried()),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets (kept in this file — no separate trivial widget files)
// ---------------------------------------------------------------------------

class _SearchResultTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                width: 56,
                height: 84,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ShimmerWidget(
                  width: 56,
                  height: 84,
                  borderRadius: AppDimensions.radiusS,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 56,
                  height: 84,
                  color: AppColors.surfaceLight,
                  child: const Icon(Icons.movie_outlined,
                      color: AppColors.textHint, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (movie.rating > 0)
                    ..._buildRating()
                  else
                    _buildComingSoon(),
                  const SizedBox(height: 4),
                  Text(
                    _buildMeta(),
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right_rounded,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRating() {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 4),
          Text(
            movie.rating.toStringAsFixed(1),
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 6),
          Text(movie.formattedVotes, style: AppTextStyles.caption),
        ],
      ),
    ];
  }

  Widget _buildComingSoon() {
    return Text(
      AppStrings.comingSoon,
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.orange),
    );
  }

  String _buildMeta() {
    final genres = movie.genres.take(2).join(' • ');
    final languages = movie.languages.take(2).join(', ');
    if (genres.isEmpty) return languages;
    if (languages.isEmpty) return genres;
    return '$genres • $languages';
  }
}

class _ResultTileShimmer extends StatelessWidget {
  const _ResultTileShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerWidget(
          width: 56,
          height: 84,
          borderRadius: AppDimensions.radiusS,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerWidget(width: 160, height: 14, borderRadius: 4),
              SizedBox(height: 8),
              ShimmerWidget(width: 100, height: 11, borderRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}