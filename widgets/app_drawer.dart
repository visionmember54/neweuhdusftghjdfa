import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/wallet/add_points_screen.dart';
import '../screens/wallet/withdraw_funds_screen.dart';
import '../screens/wallet/wallet_statement_screen.dart';
import '../screens/history/win_history_screen.dart';
import '../screens/history/bid_history_screen.dart';
import '../screens/rates/game_rates_screen.dart';
import '../screens/support/contact_support_screen.dart';
import '../screens/info/information_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/login/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // --- Custom User Profile Header ---
          _buildDrawerHeader(context),

          // --- Menu Items List ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                _buildSectionHeader("MAIN MENU"),
                _buildDrawerTile(
                  icon: Icons.home_rounded,
                  iconColor: const Color(0xFF00796B),
                  title: "Home",
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  title: "My Profile",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),

                const SizedBox(height: 8),
                _buildSectionHeader("WALLET & FUNDS"),
                _buildDrawerTile(
                  icon: Icons.add_card_rounded,
                  iconColor: const Color(0xFF059669),
                  title: "Add Funds",
                  trailingBadge: "FAST",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPointsScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.account_balance_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: "Withdraw Funds",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WithdrawFundsScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF00796B),
                  title: "Wallet Statement",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WalletStatementScreen()),
                    );
                  },
                ),

                const SizedBox(height: 8),
                _buildSectionHeader("GAME HISTORY & RATES"),
                _buildDrawerTile(
                  icon: Icons.history_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: "Bid History",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BidHistoryScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: "Win History",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WinHistoryScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.percent_rounded,
                  iconColor: const Color(0xFFE11D48),
                  title: "Game Rates",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameRatesScreen()),
                    );
                  },
                ),

                const SizedBox(height: 8),
                _buildSectionHeader("SUPPORT & SECURITY"),
                _buildDrawerTile(
                  icon: Icons.headset_mic_rounded,
                  iconColor: const Color(0xFF00897B),
                  title: "Contact Support",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF475569),
                  title: "Information & Rules",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InformationScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.lock_reset_rounded,
                  iconColor: const Color(0xFF64748B),
                  title: "Change Password",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    );
                  },
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE2E8F0)),

                // Logout Tile
                _buildDrawerTile(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFDC2626),
                  title: "Logout",
                  titleColor: const Color(0xFFDC2626),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Kalyan Official v1.0.0 • 100% Secure",
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Profile Container ---
  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00382E), // Deep Forest Teal
            Color(0xFF005A4C),
            Color(0xFF00796B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // User Avatar with Gold Ring
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF004D40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Aman Jha",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFFFFD54F),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "+91 8076580694",
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Wallet Balance Pill inside Drawer Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFFFD54F),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Wallet Balance",
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  "₹ 5.00",
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFFFD54F),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color titleColor = const Color(0xFF1E293B),
    String? trailingBadge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            color: titleColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailingBadge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trailingBadge,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              )
            : const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFFCBD5E1),
              ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }
}
