import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_points_screen.dart';
import 'withdraw_funds_screen.dart';

class WalletStatementScreen extends StatefulWidget {
  const WalletStatementScreen({super.key});

  @override
  State<WalletStatementScreen> createState() => _WalletStatementScreenState();
}

class _WalletStatementScreenState extends State<WalletStatementScreen> {
  // Transaction Passbook Data
  final List<Map<String, dynamic>> _transactions = [
    {
      "points": "5",
      "type": "CREDIT",
      "status": "SUCCESSFUL",
      "description": "Welcome Signup Bonus",
      "time": "2026-01-19 23:53:27",
    },
    {
      "points": "500",
      "type": "CREDIT",
      "status": "SUCCESSFUL",
      "description": "UPI Deposit (GPay)",
      "time": "2026-01-18 15:20:10",
    },
    {
      "points": "100",
      "type": "DEBIT",
      "status": "SUCCESSFUL",
      "description": "Milan Day • Single Digit Bet",
      "time": "2026-01-18 15:45:00",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft slate background
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Luxury Wallet Overview Card ---
            _buildWalletOverviewCard(context),

            const SizedBox(height: 20),

            // --- 2. Passbook Section Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TRANSACTION HISTORY",
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  "${_transactions.length} Records",
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- 3. Transaction List ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(_transactions[index]);
              },
            ),
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
              Color(0xFF004D40), // Deep Teal
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
        "Wallet Statement",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildWalletOverviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF004D40), // Deep Forest Teal
            Color(0xFF00695C),
            Color(0xFF00796B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AVAILABLE POINTS",
                style: GoogleFonts.dmSans(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFFFFD54F), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "VERIFIED",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFFFD54F),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Big Balance Text
          Text(
            "₹ 5.00",
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          // Rules info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFFFFD54F), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Withdrawal: 07:00 AM - 10:00 AM • Min: ₹1,000",
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Action Buttons: Withdraw & Add Funds
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WithdrawFundsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_balance_rounded, size: 17),
                  label: const Text("WITHDRAW"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPointsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
                  label: const Text("ADD FUNDS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: const Color(0xFF00382E),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final bool isCredit = tx["type"] == "CREDIT";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Credit/Debit Icon Badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCredit
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx["description"] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tx["time"] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Points & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isCredit ? '+' : '-'}₹${tx['points']}",
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isCredit
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tx["status"] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
