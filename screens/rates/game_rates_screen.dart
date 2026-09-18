import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameRatesScreen extends StatelessWidget {
  const GameRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rates = [
      {
        "label": "Single Digit",
        "rate": "10 : 95",
        "multiplier": "9.5x Win",
        "icon": Icons.looks_one_rounded,
        "color": const Color(0xFF00796B),
      },
      {
        "label": "Jodi Digit",
        "rate": "10 : 950",
        "multiplier": "95x Win",
        "icon": Icons.filter_2_rounded,
        "color": const Color(0xFF1E88E5),
      },
      {
        "label": "Single Pana",
        "rate": "10 : 1500",
        "multiplier": "150x Win",
        "icon": Icons.view_in_ar_rounded,
        "color": const Color(0xFF7C3AED),
      },
      {
        "label": "Double Digit / Pana",
        "rate": "10 : 3000",
        "multiplier": "300x Win",
        "icon": Icons.copy_rounded,
        "color": const Color(0xFF059669),
      },
      {
        "label": "Triple Digit / Pana",
        "rate": "10 : 9000",
        "multiplier": "900x Win",
        "icon": Icons.auto_awesome_rounded,
        "color": const Color(0xFFD97706),
      },
      {
        "label": "Half Sangam",
        "rate": "10 : 12000",
        "multiplier": "1,200x Win",
        "icon": Icons.layers_rounded,
        "color": const Color(0xFFE11D48),
      },
      {
        "label": "Full Sangam",
        "rate": "10 : 100000",
        "multiplier": "10,000x Win",
        "icon": Icons.workspace_premium_rounded,
        "color": const Color(0xFFB45309),
        "isJackpot": true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft slate background
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Summary Card
          _buildSummaryHeader(),

          const SizedBox(height: 16),

          // Rates Cards
          ...rates.map((rate) => _buildRateCard(rate)),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 2,
      shadowColor: const Color(0xFF004D40).withValues(alpha: 0.3),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF004D40),
              Color(0xFF00796B),
              Color(0xFF00897B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        tooltip: "Back",
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Game Rates & Payouts",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.percent_rounded,
              color: Color(0xFF00796B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GUARANTEED BEST PAYOUTS",
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Automatic calculation with instant wallet crediting.",
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(Map<String, dynamic> item) {
    final String label = item["label"];
    final String rate = item["rate"];
    final String multiplier = item["multiplier"];
    final IconData icon = item["icon"];
    final Color color = item["color"];
    final bool isJackpot = item["isJackpot"] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isJackpot ? const Color(0xFF004D40) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJackpot
              ? const Color(0xFFFFD54F)
              : const Color(0xFFE2E8F0),
          width: isJackpot ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isJackpot
                ? const Color(0xFF004D40).withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isJackpot
                  ? const Color(0xFFFFD54F)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isJackpot ? const Color(0xFF00382E) : color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Label & Multiplier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isJackpot ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  multiplier,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isJackpot
                        ? const Color(0xFFFFE082)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Rate Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isJackpot
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isJackpot
                    ? const Color(0xFFFFD54F).withValues(alpha: 0.5)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Text(
              rate,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isJackpot ? Colors.white : const Color(0xFF00796B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
