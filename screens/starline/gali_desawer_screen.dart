import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../rates/game_rates_screen.dart';
import '../history/bid_history_screen.dart';
import '../history/win_history_screen.dart';
import '../wallet/add_points_screen.dart';
import '../wallet/wallet_statement_screen.dart';
import 'gali_desawer_game_screen.dart';
import 'gali_desawer_chart_screen.dart';

class GaliDesawerScreen extends StatefulWidget {
  const GaliDesawerScreen({super.key});

  @override
  State<GaliDesawerScreen> createState() => _GaliDesawerScreenState();
}

class _GaliDesawerScreenState extends State<GaliDesawerScreen> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = Open, 2 = Closed

  final List<Map<String, String>> _games = const [
    {
      "title": "DESAWAR-DS",
      "time": "04:30 AM",
      "result": "**",
      "isOpen": "false",
    },
    {
      "title": "JACKPOT KING",
      "time": "11:00 AM",
      "result": "**",
      "isOpen": "false",
    },
    {
      "title": "RAJDHANI SATTA",
      "time": "01:00 PM",
      "result": "**",
      "isOpen": "false",
    },
    {
      "title": "DISAWAR GOLD",
      "time": "02:00 PM",
      "result": "**",
      "isOpen": "false",
    },
    {
      "title": "DELHI - BAZAR",
      "time": "02:50 PM",
      "result": "48",
      "isOpen": "true",
    },
    {
      "title": "MIRZAPUR",
      "time": "03:00 PM",
      "result": "72",
      "isOpen": "true",
    },
    {
      "title": "KASHIPUR",
      "time": "04:00 PM",
      "result": "**",
      "isOpen": "true",
    },
    {
      "title": "SHRI GANESH",
      "time": "04:25 PM",
      "result": "**",
      "isOpen": "true",
    },
    {
      "title": "PUNJAB DAY",
      "time": "05:00 PM",
      "result": "**",
      "isOpen": "true",
    },
    {
      "title": "FARIDABAD",
      "time": "06:15 PM",
      "result": "**",
      "isOpen": "false",
    },
    {
      "title": "GHAZIABAD",
      "time": "08:40 PM",
      "result": "**",
      "isOpen": "false",
    },
    {
      "title": "GALI",
      "time": "11:10 PM",
      "result": "**",
      "isOpen": "false",
    },
  ];

  List<Map<String, String>> get _filteredGames {
    if (_selectedFilterIndex == 1) {
      return _games.where((g) => g["isOpen"] == "true").toList();
    } else if (_selectedFilterIndex == 2) {
      return _games.where((g) => g["isOpen"] == "false").toList();
    }
    return _games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // --- 1. Harmonious Quick Navigation Bar ---
          _buildQuickActionsBar(context),

          // --- 2. Tonal Filter Chips (All / Open / Closed) ---
          _buildFilterChips(),

          const SizedBox(height: 8),

          // --- 3. Clean Starline Game Cards List ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
              itemCount: _filteredGames.length,
              itemBuilder: (context, index) {
                return _buildGameCard(context, _filteredGames[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- AppBar with Unified Deep Forest Emerald Theme & Live Wallet Chip ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        tooltip: "Back",
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gali Desawer",
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            "LIVE RESULTS & BETTING",
            style: GoogleFonts.dmSans(
              color: AppColors.goldLight,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
      actions: [
        // Wallet Balance Chip with Harmonious Gold/Teal Styling
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
                    color: AppColors.gold,
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
                      color: AppColors.emeraldAccent,
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

  // --- 1. Harmonious Horizontal Quick Actions Bar in Brand Palette ---
  Widget _buildQuickActionsBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldDarkest.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            context: context,
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.emerald,
            bgColor: AppColors.emeraldSurface,
            borderColor: AppColors.borderTeal,
            label: "Chart",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GaliDesawerChartScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildQuickActionItem(
            context: context,
            icon: Icons.percent_rounded,
            iconColor: AppColors.emeraldMedium,
            bgColor: AppColors.emeraldTint,
            borderColor: AppColors.borderTeal,
            label: "Game Rates",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameRatesScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildQuickActionItem(
            context: context,
            icon: Icons.history_rounded,
            iconColor: AppColors.emeraldDeep,
            bgColor: AppColors.emeraldSurface,
            borderColor: AppColors.borderTeal,
            label: "Bid History",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BidHistoryScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildQuickActionItem(
            context: context,
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.goldDark,
            bgColor: AppColors.goldSurface,
            borderColor: AppColors.goldBorder,
            label: "Win History",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WinHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.borderSubtle,
    );
  }

  // --- 2. Filter Chips (All, Open Now, Closed) in Tonal Theme Shades ---
  Widget _buildFilterChips() {
    final filters = ["ALL", "OPEN NOW", "CLOSED"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilterIndex = index);
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: index < filters.length - 1 ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 9),
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
            ),
          );
        }),
      ),
    );
  }

  // --- 3. Clean Game Market Card in Harmonious Palette ---
  Widget _buildGameCard(BuildContext context, Map<String, String> game) {
    final bool isOpen = game["isOpen"] == "true";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? AppColors.borderTeal : AppColors.borderSubtle,
          width: isOpen ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isOpen
                ? AppColors.emeraldDark.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GaliDesawerGameScreen(
                  gameName: game["title"]!,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Left Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge (Tonal Mint for Open, Neutral Slate for Closed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? AppColors.emeraldSurface
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isOpen
                                ? AppColors.borderTeal
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOpen
                                    ? AppColors.emeraldLight
                                    : AppColors.textSlateMuted,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isOpen ? "OPEN NOW" : "CLOSED",
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isOpen
                                    ? AppColors.emeraldDark
                                    : AppColors.textSlateMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Market Title
                      Text(
                        game["title"]!,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Close Time with clock icon
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: isOpen
                                ? AppColors.emerald
                                : AppColors.textSlateMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Close Time: ${game['time']}",
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOpen
                                  ? AppColors.textSecondary
                                  : AppColors.textSlateMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Center: Result Digit Box in DM Sans
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    game["result"]!,
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isOpen
                          ? AppColors.emeraldDark
                          : AppColors.textSlate,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                // Right Action: Action Button with Theme Gradient
                SizedBox(
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isOpen
                          ? const LinearGradient(
                              colors: [
                                AppColors.emeraldDeep,
                                AppColors.emeraldMedium,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isOpen ? null : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOpen
                            ? Colors.transparent
                            : AppColors.borderSubtle,
                      ),
                      boxShadow: isOpen
                          ? [
                              BoxShadow(
                                color: AppColors.emeraldDark
                                    .withValues(alpha: 0.22),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
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
                            builder: (context) => GaliDesawerGameScreen(
                              gameName: game["title"]!,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: isOpen
                            ? Colors.white
                            : AppColors.textSlateMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOpen
                                ? Icons.play_arrow_rounded
                                : Icons.lock_outline_rounded,
                            size: 16,
                            color: isOpen
                                ? Colors.white
                                : AppColors.textSlateMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOpen ? "PLAY" : "CLOSED",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                              color: isOpen
                                  ? Colors.white
                                  : AppColors.textSlateMuted,
                            ),
                          ),
                        ],
                      ),
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
}
