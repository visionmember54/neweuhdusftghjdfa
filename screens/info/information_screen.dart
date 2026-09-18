import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft slate background
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(
              title: "About Kalyan Official",
              icon: Icons.shield_rounded,
              iconColor: const Color(0xFF00796B),
              bgColor: const Color(0xFFE0F2F1),
              content:
                  "Welcome to Kalyan Official, the trusted platform for live market games and starline play. We provide 100% transparent results, ultra-fast automated payouts, and bank-grade security to ensure an exceptional gaming experience.",
            ),
            const SizedBox(height: 14),

            _buildInfoCard(
              title: "How to Play",
              icon: Icons.sports_esports_rounded,
              iconColor: const Color(0xFF1E88E5),
              bgColor: const Color(0xFFE3F2FD),
              content:
                  "1. Register your mobile account with a secure password.\n"
                  "2. Add funds to your wallet instantly using any UPI app.\n"
                  "3. Choose an active market from the home screen.\n"
                  "4. Select game type (Single Digit, Jodi, Pana, or Sangam).\n"
                  "5. Choose your numbers, enter points, and tap Place Bet.\n"
                  "6. Monitor declared results on the live charts and claim wins automatically.",
            ),
            const SizedBox(height: 14),

            _buildInfoCard(
              title: "Rules & Regulations",
              icon: Icons.gavel_rounded,
              iconColor: const Color(0xFFD97706),
              bgColor: const Color(0xFFFEF3C7),
              content:
                  "• Players must be 18+ to register and play.\n"
                  "• Ensure sufficient wallet balance before placing bids.\n"
                  "• Bids once submitted cannot be edited or canceled.\n"
                  "• Withdrawals are processed daily between 07:00 AM and 10:00 AM.\n"
                  "• In case of discrepancies, the official management decision is final.",
            ),
            const SizedBox(height: 14),

            _buildInfoCard(
              title: "24x7 Customer Support",
              icon: Icons.headset_mic_rounded,
              iconColor: const Color(0xFF059669),
              bgColor: const Color(0xFFECFDF5),
              content:
                  "Need assistance? Our customer care is available 24x7 via WhatsApp and telephone. Visit the Support section in the app menu for instant live support.",
            ),
            const SizedBox(height: 14),
          ],
        ),
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
        "Information & Rules",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
