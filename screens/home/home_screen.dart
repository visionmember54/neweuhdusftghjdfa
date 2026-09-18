import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../widgets/app_drawer.dart';
import '../game/market_game_screen.dart';
import '../starline/gali_desawer_screen.dart';
import '../starline/gali_desawer_chart_screen.dart';
import '../wallet/add_points_screen.dart';
import '../wallet/wallet_statement_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filter tab index: 0 = All, 1 = Live Now (Open/Close), 2 = Upcoming, 3 = Done Today
  int _selectedFilterIndex = 0;

  // Market Games with Opening and Closing session dynamics
  final List<Map<String, String>> _games = [
    {
      "title": "MILAN DAY",
      "number": "220 - 40 - 668",
      "openTime": "03:00 PM",
      "closeTime": "05:00 PM",
      "sessionStatus": "OPENING", // Active for Opening Bids
    },
    {
      "title": "RAJDHANI DAY",
      "number": "245 - 12 - 679",
      "openTime": "03:15 PM",
      "closeTime": "05:15 PM",
      "sessionStatus": "CLOSING", // Active for Closing Bids
    },
    {
      "title": "KALYAN NIGHT",
      "number": "112 - 45 - 678",
      "openTime": "09:20 PM",
      "closeTime": "11:30 PM",
      "sessionStatus": "UPCOMING", // Opens Tonight
    },
    {
      "title": "MILAN NIGHT",
      "number": "149 - 41 - 236",
      "openTime": "09:00 PM",
      "closeTime": "11:00 PM",
      "sessionStatus": "UPCOMING", // Opens Tonight
    },
    {
      "title": "RAJDHANI NIGHT",
      "number": "567 - 89 - 123",
      "openTime": "09:35 PM",
      "closeTime": "11:35 PM",
      "sessionStatus": "UPCOMING", // Opens Tonight
    },
    {
      "title": "MUMBAI MORNING",
      "number": "118 - 09 - 234",
      "openTime": "09:30 AM",
      "closeTime": "11:00 AM",
      "sessionStatus": "CLOSED_TODAY", // Completed for today
    },
    {
      "title": "SRIDEVI MORNING",
      "number": "139 - 35 - 140",
      "openTime": "09:50 AM",
      "closeTime": "10:50 AM",
      "sessionStatus": "CLOSED_TODAY",
    },
    {
      "title": "KARNATAKA DAY",
      "number": "678 - 17 - 890",
      "openTime": "10:00 AM",
      "closeTime": "11:00 AM",
      "sessionStatus": "CLOSED_TODAY",
    },
  ];

  // Pull-to-refresh handler
  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Market sessions refreshed",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.emeraldDeep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // WhatsApp Dispatch Helper
  Future<void> _openWhatsApp() async {
    final Uri uri =
        Uri.parse("https://wa.me/917000000000?text=Hello%20Kalyan%20Support");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "WhatsApp not installed",
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.emeraldDeep,
          ),
        );
      }
    } catch (_) {}
  }

  // Filtered games based on selected tab
  List<Map<String, String>> get _filteredGames {
    if (_selectedFilterIndex == 1) {
      // Live Now: either in Opening or Closing session
      return _games
          .where((g) =>
              g["sessionStatus"] == "OPENING" ||
              g["sessionStatus"] == "CLOSING")
          .toList();
    } else if (_selectedFilterIndex == 2) {
      // Upcoming later today
      return _games
          .where((g) => g["sessionStatus"] == "UPCOMING")
          .toList();
    } else if (_selectedFilterIndex == 3) {
      // Completed for today
      return _games
          .where((g) => g["sessionStatus"] == "CLOSED_TODAY")
          .toList();
    }
    return _games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      drawer: const AppDrawer(),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.emerald,
        backgroundColor: Colors.white,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- 1. Top Banner Image ---
              _buildTopBannerImage(),

              // --- 2. Cohesive Announcement Marquee Ticker ---
              _buildNoticeMarquee(),

              // --- 3. Harmonious Quick Action Tiles (Unified Palette) ---
              _buildQuickActions(),

              const SizedBox(height: 12),

              // --- 4. Market Session Filter Tabs ---
              _buildFilterChips(),

              const SizedBox(height: 12),

              // --- 5. Game Market Cards with Clean Tonal Dynamics ---
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _filteredGames.length,
                itemBuilder: (context, index) {
                  return _buildMarketCard(_filteredGames[index]);
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header App Bar with Deep Forest Emerald Gradient & Champagne Wallet Chip ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 2,
      shadowColor: AppColors.emeraldDarkest.withValues(alpha: 0.35),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.emeraldDark,   // Deep Forest Emerald (#00382E)
              AppColors.emeraldDeep,   // Heritage Dark Teal (#004D40)
              AppColors.emerald,       // Signature Emerald (#005A4C)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          tooltip: "Open Menu",
          onPressed: () {
            HapticFeedback.lightImpact();
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.appName,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            "LIVE SESSIONS • OPEN & CLOSE",
            style: GoogleFonts.dmSans(
              color: AppColors.goldLight, // Champagne gold accent
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
      actions: [
        // Live Points Wallet Chip with Harmonious Gold/Teal Accents
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WalletStatementScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldLight.withValues(alpha: 0.55),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.gold, // Champagne Gold badge
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.emeraldDark,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "₹ 5",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPointsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.emeraldAccent, // Harmonious Mint Accent
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.emeraldDarkest,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 1. Top Banner Image ---
  Widget _buildTopBannerImage() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.emeraldDeep,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldDarkest.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          AppConstants.appBannerImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (ctx, err, stack) => Container(
            color: AppColors.emeraldDeep,
            child: const Center(
              child: Icon(Icons.star, size: 70, color: AppColors.goldLight),
            ),
          ),
        ),
      ),
    );
  }

  // --- 2. Live Notification Marquee Bar with Tonal Theme Shades ---
  Widget _buildNoticeMarquee() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.emeraldTint, // Soft emerald wash
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderTeal, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.emerald,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: SizedBox(
              height: 22,
              child: ScrollingText(
                text:
                    "Markets have two daily sessions: Opening & Closing. Check session status below and place your bids on time!",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Unified Quick Action Tiles using Harmonious Shades of the Brand Palette ---
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        children: [
          // WhatsApp 24x7 Support Tile (Deep Forest Teal shade)
          Expanded(
            child: _buildActionTile(
              title: "Support 24x7",
              subTitle: "WhatsApp Help",
              icon: Icons.chat_bubble_outline_rounded,
              gradientColors: const [
                Color(0xFF003D33), // Deep Forest Emerald
                Color(0xFF005547), // Muted Forest Teal
              ],
              onTap: _openWhatsApp,
            ),
          ),
          const SizedBox(width: 10),

          // Starline Market Tile (Royal Emerald Teal shade)
          Expanded(
            child: _buildActionTile(
              title: "Starline",
              subTitle: "Jackpot Games",
              icon: Icons.stars_rounded,
              gradientColors: const [
                Color(0xFF004D40), // Heritage Dark Teal
                Color(0xFF006B5A), // Mid Emerald
              ],
              badgeText: "JACKPOT",
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GaliDesawerScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          // Add Cash Tile (Signature Emerald Teal shade)
          Expanded(
            child: _buildActionTile(
              title: "Add Cash",
              subTitle: "Instant Wallet",
              icon: Icons.account_balance_wallet_rounded,
              gradientColors: const [
                Color(0xFF005E50), // Rich Brand Emerald
                Color(0xFF007E6C), // Vibrant Emerald Teal
              ],
              badgeText: "INSTANT",
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPointsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subTitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emeraldDarkest.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              bottom: -6,
              child: Icon(
                icon,
                size: 50,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeText != null)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight, // Champagne Gold badge
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.dmSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emeraldDarkest,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- 4. Market Session Filter Pills ---
  Widget _buildFilterChips() {
    final filters = [
      "ALL MARKETS",
      "LIVE SESSIONS",
      "UPCOMING",
      "DONE TODAY",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilterIndex = index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? null : Colors.white,
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          AppColors.emeraldDeep,
                          AppColors.emeraldMedium,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.emeraldDeep
                      : AppColors.borderSubtle,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.emeraldDark.withValues(alpha: 0.22),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSlate,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- 5. Clean, Intuitive Game Market Card with Unified Palette & Opening/Closing Dynamics ---
  Widget _buildMarketCard(Map<String, String> game) {
    final String status = game["sessionStatus"] ?? "CLOSED_TODAY";
    final bool isOpeningLive = status == "OPENING";
    final bool isClosingLive = status == "CLOSING";
    final bool isUpcoming = status == "UPCOMING";
    final bool isClosedToday = status == "CLOSED_TODAY";
    final bool isLive = isOpeningLive || isClosingLive;

    // Harmonious Status Design Tokens (Theme shades & Champagne Gold)
    Color badgeBgColor;
    Color badgeTextColor;
    Color badgeBorderColor;
    Color dotColor;
    String statusLabel;
    String actionButtonLabel;
    Color actionButtonTextColor;
    List<Color>? actionButtonGradient;
    Color? actionButtonSolidBg;
    Color actionBorderColor;
    Color numberColor;
    Color cardBorderColor;

    if (isOpeningLive) {
      // Opening Session: Theme Mint Tint & Deep Forest Emerald
      badgeBgColor = AppColors.emeraldSurface;
      badgeTextColor = AppColors.emeraldDark;
      badgeBorderColor = AppColors.borderTeal;
      dotColor = AppColors.emeraldLight;
      statusLabel = "OPENING SESSION LIVE";
      actionButtonLabel = "PLAY OPEN";
      actionButtonGradient = const [
        AppColors.emeraldDeep,
        AppColors.emeraldMedium,
      ];
      actionButtonTextColor = Colors.white;
      actionBorderColor = Colors.transparent;
      numberColor = AppColors.emeraldDark;
      cardBorderColor = AppColors.borderTeal;
    } else if (isClosingLive) {
      // Closing Session: Champagne Amber Gold
      badgeBgColor = AppColors.goldSurface;
      badgeTextColor = AppColors.goldDark;
      badgeBorderColor = AppColors.goldBorder;
      dotColor = AppColors.goldDark;
      statusLabel = "CLOSING SESSION LIVE";
      actionButtonLabel = "PLAY CLOSE";
      actionButtonGradient = const [
        Color(0xFFB45309), // Rich Amber Gold
        Color(0xFFD97706),
      ];
      actionButtonTextColor = Colors.white;
      actionBorderColor = Colors.transparent;
      numberColor = AppColors.goldDark;
      cardBorderColor = AppColors.goldBorder;
    } else if (isUpcoming) {
      // Upcoming: Soft Theme Tint / Slate
      badgeBgColor = AppColors.surfaceMuted;
      badgeTextColor = AppColors.textSlate;
      badgeBorderColor = AppColors.borderSubtle;
      dotColor = AppColors.textMuted;
      statusLabel = "OPENS AT ${game['openTime']}";
      actionButtonLabel = "VIEW MARKET";
      actionButtonGradient = null;
      actionButtonSolidBg = AppColors.emeraldTint;
      actionButtonTextColor = AppColors.emeraldDeep;
      actionBorderColor = AppColors.borderTeal;
      numberColor = AppColors.textPrimary;
      cardBorderColor = AppColors.borderSubtle;
    } else {
      // Completed for today: Neutral Slate
      badgeBgColor = AppColors.surfaceMuted;
      badgeTextColor = AppColors.textSlateMuted;
      badgeBorderColor = AppColors.borderSubtle;
      dotColor = AppColors.textSlateMuted;
      statusLabel = "CLOSED FOR TODAY";
      actionButtonLabel = "RESULT OUT";
      actionButtonGradient = null;
      actionButtonSolidBg = AppColors.surfaceMuted;
      actionButtonTextColor = AppColors.textSlateMuted;
      actionBorderColor = AppColors.borderSubtle;
      numberColor = AppColors.textSlateMuted;
      cardBorderColor = AppColors.borderSubtle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorderColor,
          width: isLive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isLive
                ? (isOpeningLive
                    ? AppColors.emeraldDark.withValues(alpha: 0.10)
                    : AppColors.goldDark.withValues(alpha: 0.10))
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketGameScreen(
                  gameName: game["title"]!,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Top Row: Status badge & Chart Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dynamic Session Badge in Brand Palette
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: badgeBorderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: GoogleFonts.dmSans(
                              color: badgeTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tonal Chart Button (Soft Theme Tint)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const GaliDesawerChartScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldTint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderTeal),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bar_chart_rounded,
                              color: AppColors.emerald,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "CHART",
                              style: GoogleFonts.dmSans(
                                color: AppColors.emerald,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Middle Section: Market Title + Result Number + Action Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game["title"]!,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // High-Contrast Result Number Box (DM Sans for Consistency)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              game["number"]!,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: numberColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Big Action Button with Session Label
                    SizedBox(
                      height: 46,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: actionButtonGradient != null
                              ? LinearGradient(
                                  colors: actionButtonGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: actionButtonSolidBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: actionBorderColor),
                          boxShadow: isLive
                              ? [
                                  BoxShadow(
                                    color: isOpeningLive
                                        ? AppColors.emeraldDark
                                            .withValues(alpha: 0.25)
                                        : AppColors.goldDark
                                            .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MarketGameScreen(
                                  gameName: game["title"]!,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: actionButtonTextColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isClosedToday
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.play_arrow_rounded,
                                size: 16,
                                color: actionButtonTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                actionButtonLabel,
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                  color: actionButtonTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 8),

                // Bottom Session Schedule Row (Opening Session & Closing Session in Harmonious Tones)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      // Opening Session
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOpeningLive
                                    ? AppColors.emeraldLight
                                    : AppColors.textSlateMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Open Session: ${game['openTime']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: isOpeningLive
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isOpeningLive
                                      ? AppColors.emeraldDark
                                      : AppColors.textSlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 14,
                        width: 1,
                        color: AppColors.borderMedium,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                      ),

                      // Closing Session
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isClosingLive
                                    ? AppColors.goldDark
                                    : AppColors.textSlateMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Close Session: ${game['closeTime']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: isClosingLive
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isClosingLive
                                      ? AppColors.goldDark
                                      : AppColors.textSlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Scrolling Marquee Widget (Safely Handled for Hot Reload) ---
class ScrollingText extends StatefulWidget {
  final String text;
  const ScrollingText({super.key, required this.text});

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _animationController.addListener(_onTick);
    _animationController.repeat();
  }

  void _onTick() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      _scrollController.jumpTo(_animationController.value * maxScroll);
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_onTick);
    _animationController.stop();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        "${widget.text}               ${widget.text}",
        style: GoogleFonts.dmSans(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
