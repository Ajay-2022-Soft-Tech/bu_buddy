import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../home/find_a_ride.dart';
import '../home/widgets/feature_card.dart';
import '../home/widgets/recent_carpool_section.dart';

class CarHomeScreen extends StatefulWidget {
  const CarHomeScreen({super.key});
  @override
  State<CarHomeScreen> createState() => _CarHomeScreenState();
}

class _CarHomeScreenState extends State<CarHomeScreen> with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _mainController, _floatingButtonController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  final _scrollController = ScrollController();
  final _scrollOffset = ValueNotifier<double>(0);
  final _searchController = TextEditingController();

  // State
  bool _showShadowAppBar = false;
  bool _isSearchOpen = false;
  DateTime _lastScrollUpdate = DateTime.now();
  final RxList<Map<String, dynamic>> _searchResults = <Map<String, dynamic>>[].obs;

  // Search destinations
  final List<Map<String, dynamic>> _destinations = [
    {'name': 'City Center Mall', 'address': '123 Main St', 'distance': '2.5 km'},
    {'name': 'University Campus', 'address': '789 Education Blvd', 'distance': '1.2 km'},
    {'name': 'Tech Park', 'address': '456 Innovation Ave', 'distance': '5.3 km'},
    {'name': 'Central Park', 'address': '321 Nature Way', 'distance': '3.7 km'},
    {'name': 'Metro Station', 'address': '555 Transit Rd', 'distance': '0.8 km'},
    {'name': 'Business Center', 'address': '999 Corporate Plaza', 'distance': '6.2 km'},
  ];

  // Visual elements
  final _particles = [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)];
  final _darkParticles = [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.2)];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _floatingButtonController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _mainController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic));
    _searchResults.assignAll(_destinations);
    _mainController.forward();
    _scrollController.addListener(_optimizedScrollListener);
    _searchController.addListener(_handleSearchInput);
  }

  void _optimizedScrollListener() {
    final now = DateTime.now();
    if (now.difference(_lastScrollUpdate) > const Duration(milliseconds: 80)) {
      _scrollOffset.value = _scrollController.offset;
      final showShadow = _scrollController.offset > 10;
      if (showShadow != _showShadowAppBar) setState(() => _showShadowAppBar = showShadow);
      if (_scrollController.offset > 100) {
        _floatingButtonController.forward();
      } else {
        _floatingButtonController.reverse();
      }
      _lastScrollUpdate = now;
    }
  }

  void _handleSearchInput() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _searchResults.assignAll(_destinations);
    } else {
      _searchResults.assignAll(_destinations.where((item) =>
      item['name'].toString().toLowerCase().contains(query) ||
          item['address'].toString().toLowerCase().contains(query)).toList());
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (!_isSearchOpen) {
        _searchController.clear();
        _searchResults.assignAll(_destinations);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingButtonController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildAppBar(isDark),
      ),
      body: Stack(
        children: [
          // Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: isDark
                    ? [Color(0xFF1F2937).withOpacity(0.95), Color(0xFF111827).withOpacity(0.7), Theme.of(context).scaffoldBackgroundColor]
                    : [TColors.primary.withOpacity(0.95), TColors.primary.withOpacity(0.5), Colors.white],
                stops: const [0.0, 0.3, 0.5],
              ),
            ),
          ),

          // Particles
          CustomPaint(
            painter: ParticleEffect(
              count: 10,
              colors: isDark ? _darkParticles : _particles,
            ),
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          ),

          // Main content - Search or Default
          SafeArea(
            child: _isSearchOpen
                ? _buildSearchView(isDark)
                : RefreshIndicator(
              color: isDark ? Colors.blueAccent : TColors.primary,
              backgroundColor: isDark ? Color(0xFF1F2937) : Colors.white,
              strokeWidth: 2.5,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                return Future.delayed(const Duration(milliseconds: 1500));
              },
              child: _mainContent(controller, isDark),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _floatingButtonController,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        ),
        child: FloatingActionButton(
          backgroundColor: isDark ? Colors.blueAccent : TColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () {
            HapticFeedback.selectionClick();
            _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
          },
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    final bgColor = _isSearchOpen ? (isDark ? Color(0xFF1F2937) : Colors.white.withOpacity(0.95)) : Colors.transparent;
    final elevation = _showShadowAppBar || _isSearchOpen ? 1.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: elevation > 0 ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)] : null,
        borderRadius: _isSearchOpen ? BorderRadius.vertical(bottom: Radius.circular(20)) : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              // Logo or Back button
              if (_isSearchOpen)
                IconButton(
                  icon: Icon(Icons.arrow_back, color: isDark ? Colors.white70 : TColors.primary),
                  onPressed: _toggleSearch,
                )
              else
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.blueAccent.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: isDark ? Colors.blueAccent.withOpacity(0.2) : TColors.primary.withOpacity(0.3), blurRadius: 8)],
                          border: Border.all(color: isDark ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: Image.asset('assets/images/logo.png', width: 28, height: 28, color: isDark ? Colors.blueAccent : Colors.white,
                          errorBuilder: (_, __, ___) => Icon(Icons.directions_car, color: isDark ? Colors.blueAccent : Colors.white, size: 28),
                        ),
                      ),
                    );
                  },
                ),

              // Search field or Title
              _isSearchOpen
                  ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search destinations...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                          : null,
                    ),
                  ),
                ),
              )
                  : Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isDark ? [Colors.white, Colors.blueAccent] : [Colors.white, Colors.white.withOpacity(0.8)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text('BuBuddy',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)
                    ),
                  ),
                ),
              ),

              // Actions
              _isSearchOpen
                  ? IconButton(
                icon: Icon(Icons.search, color: isDark ? Colors.blueAccent : TColors.primary),
                onPressed: () {/* Search already active */},
              )
                  : Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.search, color: isDark ? Colors.blueAccent : Colors.white),
                    onPressed: _toggleSearch,
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.blueAccent : Colors.white),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12, top: 10,
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? Color(0xFF1F2937) : TColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchView(bool isDark) {
    return Obx(() {
      return _searchResults.isEmpty
          ? _buildEmptySearchResults(isDark)
          : ListView.builder(
        itemCount: _searchResults.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = _searchResults[index];
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutQuad,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: Opacity(opacity: value, child: child!),
              );
            },
            child: _buildSearchResultItem(item, isDark),
          );
        },
      );
    });
  }

  Widget _buildEmptySearchResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 80, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No results found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade800)
          ),
          const SizedBox(height: 8),
          Text('Try a different search term',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B).withOpacity(0.8) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.mediumImpact();
            _toggleSearch();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected: ${item['name']}'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blueAccent.withOpacity(0.15) : TColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: isDark ? Colors.blueAccent : TColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['address'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blueAccent.withOpacity(0.1) : TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['distance'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blueAccent : TColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainContent(UserController controller, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _welcomeSection(controller, isDark),
                SlidableFeatureCards(),
                _quickActions(controller, isDark),
                RecentCarpoolsSection(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcomeSection(UserController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 16),
      child: Obx(() {
        return controller.profileLoading.value
            ? Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            width: 250, height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.white,
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getTimeOfDay()},',
              style: TextStyle(
                fontSize: TSizes.fontSizeMd,
                color: isDark ? Colors.grey[300] : TColors.white,
                fontWeight: FontWeight.w500,
                shadows: const [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${controller.user.value.firstName}',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeLg * 1.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TColors.white,
                    letterSpacing: 0.5,
                    shadows: const [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 10),
                _topRiderBadge(isDark),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _topRiderBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blueAccent.withOpacity(0.2), Colors.purpleAccent.withOpacity(0.1)]
              : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 6),
          Text('Top Rider',
              style: TextStyle(fontSize: TSizes.fontSizeSm, color: isDark ? Colors.grey[300] : Colors.white, fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }

  Widget _quickActions(UserController controller, bool isDark) {
    final actions = [
      {'icon': Icons.search, 'label': 'Find Rides', 'color': isDark ? Colors.blue.shade400 : Colors.blue.shade700, 'onTap': () => Get.to(() => FindARideScreen())},
      {'icon': Icons.add_circle_outline, 'label': 'Offer Ride', 'color': isDark ? Colors.green.shade400 : Colors.green.shade700, 'onTap': () {}},
      {'icon': Icons.history, 'label': 'History', 'color': isDark ? Colors.purple.shade300 : Colors.purple.shade700, 'onTap': () {}},
      {'icon': Icons.favorite, 'label': 'Saved', 'color': isDark ? Colors.red.shade300 : Colors.red.shade700, 'onTap': () {}},
      {'icon': Icons.person_outline, 'label': 'Profile', 'color': isDark ? Colors.orange.shade300 : Colors.orange.shade700, 'onTap': () {}},
    ];

    return Container(
      margin: EdgeInsets.only(top: TSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blueAccent.withOpacity(0.1) : TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt, color: isDark ? Colors.blueAccent : TColors.primary, size: 24),
              ),
              const SizedBox(width: 8),
              Text('Quick Actions',
                  style: TextStyle(fontSize: TSizes.fontSizeLg, fontWeight: FontWeight.bold, color: isDark ? Colors.white : TColors.textPrimary)
              ),
            ],
          ),
          const SizedBox(height: 16),

          controller.profileLoading.value
              ? Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              width: double.infinity, height: 100,
              decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.white, borderRadius: BorderRadius.circular(TSizes.cardRadiusMd)),
            ),
          )
              : SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: actions.length,
              itemBuilder: (context, index) => _actionButton(
                icon: actions[index]['icon'] as IconData,
                label: actions[index]['label'] as String,
                color: actions[index]['color'] as Color,
                onTap: actions[index]['onTap'] as Function(),
                index: index,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Function onTap,
    required int index,
    required bool isDark,
  }) {
    return Container(
      width: 85,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withOpacity(isDark ? 0.5 : 0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: color.withOpacity(isDark ? 0.3 : 0.2), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () { HapticFeedback.lightImpact(); onTap(); },
                      borderRadius: BorderRadius.circular(18),
                      splashColor: color.withOpacity(0.2),
                      highlightColor: color.withOpacity(0.1),
                      child: Icon(icon, color: color, size: 28),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : TColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class ParticleEffect extends CustomPainter {
  final int count;
  final List<Color> colors;
  late final List<Offset> positions;
  late final List<double> sizes;
  late final List<Color> particleColors;

  ParticleEffect({required this.count, required this.colors}) {
    final random = Random();
    positions = List.generate(count, (_) => Offset(random.nextDouble() * 400, random.nextDouble() * 800));
    sizes = List.generate(count, (_) => 2 + random.nextDouble() * 6);
    particleColors = List.generate(count, (_) => colors[random.nextInt(colors.length)]);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(positions[i], sizes[i], Paint()..color = particleColors[i]..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}