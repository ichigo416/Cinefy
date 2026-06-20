import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/home/home_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../domain/entities/movie.dart';
import '../../widgets/shimmer_loader.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_tabs.dart';
import 'widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeFetchDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(state),
                _buildSearchBar(),
                _buildCategoryTabs(),
                if (state is HomeLoading) ...[
                  _buildBannerShimmer(),
                  _buildSectionShimmer(),
                  _buildSectionShimmer(),
                ] else if (state is HomeLoaded) ...[
                  _buildBanner(state),
                  _buildMovieSection(
                    title: AppStrings.nowShowing,
                    movies: state.nowShowing,
                    showBookButton: true,
                  ),
                  _buildMovieSection(
                    title: AppStrings.comingSoon,
                    movies: state.comingSoon,
                    showBookButton: false,
                  ),
                ] else if (state is HomeError) ...[
                  _buildError(state.message),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(HomeState state) {
    final city = state is HomeLoaded ? state.selectedCity : 'Bengaluru';
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      title: Row(
        children: [
          // App logo / name
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'book',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Gilroy',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'my',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Gilroy',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'show',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Gilroy',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // City selector
        GestureDetector(
          onTap: _showCityPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  city,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.textSecondary,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: GestureDetector(
          onTap: () => context.push('/search'),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                SizedBox(width: 14),
                Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                SizedBox(width: 10),
                Text(
                  AppStrings.searchHint,
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontFamily: 'Gilroy',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: CategoryTabs(
        onCategoryChanged: (index) {
          // Handle category switch — future iteration
        },
      ),
    );
  }

  Widget _buildBanner(HomeLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: BannerCarousel(
          movies: state.nowShowing,
          onMovieTap: (movie) => _navigateToMovie(movie),
        ),
      ),
    );
  }

  Widget _buildBannerShimmer() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 16, bottom: 8),
        child: BannerShimmer(),
      ),
    );
  }

  Widget _buildMovieSection({
    required String title,
    required List<Movie> movies,
    required bool showBookButton,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: title,
            onSeeAll: () {},
          ),
          SizedBox(
            height: AppDimensions.movieCardHeight + 50,
            child: movies.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.noMoviesFound,
                      style: AppTextStyles.bodySmall,
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => MovieCard(
                      movie: movies[i],
                      onTap: () => _navigateToMovie(movies[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: ShimmerWidget(width: 150, height: 20),
          ),
          SizedBox(
            height: AppDimensions.movieCardHeight + 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const MovieCardShimmer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textHint, size: 48),
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(const HomeFetchDataEvent()),
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMovie(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  void _showCityPicker() {
    final cities = [
      'Bengaluru', 'Mumbai', 'Delhi', 'Chennai',
      'Hyderabad', 'Pune', 'Kolkata', 'Ahmedabad',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select City', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cities
                  .map((city) => GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<HomeBloc>()
                              .add(HomeChangeCityEvent(city));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(city, style: AppTextStyles.labelLarge),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h2),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import needed here to avoid calling it before defining
class AppDimensions {
  static const double movieCardHeight = 195.0;
} 