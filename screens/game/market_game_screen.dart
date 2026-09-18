import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../wallet/add_points_screen.dart';
import '../wallet/wallet_statement_screen.dart';
import 'market_bet_screen.dart';

class MarketGameScreen extends StatelessWidget {
  final String gameName;

  const MarketGameScreen({super.key, required this.gameName});

  // Cohesive Game Options structured with Brand Theme Shades & Champagne Gold
  static const List<Map<String, dynamic>> _gameTypes = [
    {
      "label": "SINGLE DIGIT",
      "sessionTag": "OPEN OR CLOSE",
      "payout": "10 - 95",
      "desc": "Play on Opening or Closing Digit (0-9)",
      "icon": Icons.looks_one_rounded,
      "color": AppColors.emerald,
      "bgColor": AppColors.emeraldSurface,
      "isJackpot": false,
    },
    {
      "label": "JODI DIGIT",
      "sessionTag": "OPEN + CLOSE",
      "payout": "10 - 950",
      "desc": "Pairs Opening & Closing Digits (00-99)",
      "icon": Icons.filter_2_rounded,
      "color": AppColors.emeraldMedium,
      "bgColor": AppColors.emeraldSurface,
      "isJackpot": false,
    },
    {
      "label": "SINGLE PANA",
      "sessionTag": "OPEN OR CLOSE",
      "payout": "10 - 1500",
      "desc": "Play on Opening or Closing 3 Unique Digits",
      "icon": Icons.view_in_ar_rounded,
      "color": AppColors.emeraldLight,
      "bgColor": AppColors.emeraldSurface,
      "isJackpot": false,
    },
    {
      "label": "DOUBLE PANA",
      "sessionTag": "OPEN OR CLOSE",
      "payout": "10 - 3000",
      "desc": "Play on 2 Matching Digits in Pana",
      "icon": Icons.copy_rounded,
      "color": AppColors.emeraldDeep,
      "bgColor": AppColors.emeraldSurface,
      "isJackpot": false,
    },
    {
      "label": "TRIPLE PANA",
      "sessionTag": "OPEN OR CLOSE",
      "payout": "10 - 9000",
      "desc": "Play on 3 Identical Digits in Pana",
      "icon": Icons.auto_awesome_rounded,
      "color": AppColors.goldDark,
      "bgColor": AppColors.goldSurface,
      "isJackpot": true,
    },
    {
      "label": "HALF SANGAM",
      "sessionTag": "DUAL SESSION",
      "payout": "10 - 12000",
      "desc": "Open Digit + Close Pana (or reverse)",
      "icon": Icons.layers_rounded,
      "color": AppColors.goldDark,
      "bgColor": AppColors.goldSurface,
      "isJackpot": true,
    },
  ];

  static const Map<String, dynamic> _featuredSangam = {
    "label": "FULL SANGAM",
    "sessionTag": "JACKPOT COMBO",
    "payout": "10 - 100,000",
    "desc": "Grand Jackpot • Open Pana + Close Pana Combo",
    "icon": Icons.workspace_premium_rounded,
  };

  void _navigateToBet(BuildContext context, String betType) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketBetScreen(
          gameName: gameName,
          betType: betType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Opening & Closing Session Banner ---
            _buildSessionBanner(),

            const SizedBox(height: 14),

            // --- 2. Section Title ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SELECT GAME TYPE",
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    "AVAILABLE FOR OPEN & CLOSE",
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- 3. 2-Column Grid for Primary Game Types (Harmonious Theme) ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.14,
              ),
              itemCount: _gameTypes.length,
              itemBuilder: (context, index) {
                return _buildGameTile(context, _gameTypes[index]);
              },
            ),

            const SizedBox(height: 14),

            // --- 4. Featured Grand Jackpot Full Sangam Card ---
            _buildFeaturedJackpotCard(context),
          ],
        ),
      ),
    );
  }

  // --- AppBar with Unified Deep Forest Emerald Theme & Champagne Wallet Chip ---
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
            gameName.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            "OPENING & CLOSING SESSIONS",
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

  // --- 1. Opening & Closing Session Banner ---
  Widget _buildSessionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
      child: Column(
        children: [
          // Header Row: Market name + Live badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.emeraldSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.casino_rounded,
                      color: AppColors.emerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    gameName,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderTeal),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emeraldLight,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "SESSIONS ACTIVE",
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emeraldDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 10),

          // Dual Session Indicator Row: Opening Session & Closing Session
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                // Opening Session Active indicator
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emeraldLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "Opening Session: Live",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emeraldDark,
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

                // Closing Session Active indicator
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "Closing Session: Live",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldDark,
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
    );
  }

  // --- 2. Clean 2-Column Game Option Tile in Unified Theme Shades ---
  Widget _buildGameTile(BuildContext context, Map<String, dynamic> game) {
    final String label = game["label"];
    final String sessionTag = game["sessionTag"];
    final String payout = game["payout"];
    final String desc = game["desc"];
    final IconData icon = game["icon"];
    final Color color = game["color"];
    final Color bgColor = game["bgColor"];
    final bool isJackpot = game["isJackpot"] == true;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJackpot
              ? AppColors.goldBorder
              : AppColors.borderSubtle,
          width: isJackpot ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isJackpot
                ? AppColors.goldDark.withValues(alpha: 0.08)
                : AppColors.emeraldDarkest.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToBet(context, label),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon Capsule & Payout Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isJackpot
                              ? AppColors.goldBorder
                              : AppColors.borderTeal,
                          width: 0.8,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        payout,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Session Tag Pill in Tonal Theme Shades
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isJackpot
                          ? AppColors.goldBorder
                          : AppColors.borderTeal,
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    sessionTag,
                    style: GoogleFonts.dmSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Bottom Titles
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSlate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. Featured Full Sangam Grand Jackpot Card ---
  Widget _buildFeaturedJackpotCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.emeraldDark,   // Deep Forest Emerald (#00382E)
            AppColors.emeraldDeep,   // Heritage Dark Teal (#004D40)
            AppColors.emerald,       // Signature Emerald (#005A4C)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.goldLight.withValues(alpha: 0.65),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldDarkest.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToBet(context, _featuredSangam["label"]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Gold Icon Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.goldLight, AppColors.gold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.emeraldDarkest,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _featuredSangam["label"],
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "JACKPOT",
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: AppColors.emeraldDarkest,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _featuredSangam["desc"],
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Payout: ${_featuredSangam['payout']}",
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Play Action Circle
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.emerald,
                    size: 18,
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
