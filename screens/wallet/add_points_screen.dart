import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPointsScreen extends StatefulWidget {
  const AddPointsScreen({super.key});

  @override
  State<AddPointsScreen> createState() => _AddPointsScreenState();
}

class _AddPointsScreenState extends State<AddPointsScreen> {
  final TextEditingController _pointsController = TextEditingController();

  final List<String> _quickAmounts = ["500", "1000", "2000", "5000", "10000"];

  void _setPoints(String amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _pointsController.text = amount;
    });
  }

  void _handleAddPoints() {
    final int amount = int.tryParse(_pointsController.text) ?? 0;
    if (amount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Minimum deposit amount is ₹500"),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Redirecting to UPI payment gateway for ₹$amount..."),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft slate canvas
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- 1. Current Balance Header ---
            _buildBalanceCard(),

            const SizedBox(height: 16),

            // --- 2. Deposit Amount Card ---
            _buildDepositCard(),

            const SizedBox(height: 20),

            // --- 3. Information & UPI Guarantee Card ---
            _buildInfoCard(),
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
              Color(0xFF004D40), // Deep Forest Teal
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
        "Add Funds / Points",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF00796B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Balance",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₹ 5.00",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "INSTANT",
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Points to Add",
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // Points Text Field
          TextField(
            controller: _pointsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00796B),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.currency_rupee_rounded,
                color: Color(0xFF00796B),
                size: 24,
              ),
              hintText: "Min ₹500",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 18,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF00796B), width: 1.8),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Quick Select Amount",
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          // Quick Amount Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts.map((amt) {
              return GestureDetector(
                onTap: () => _setPoints(amt),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    "+₹$amt",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleAddPoints,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF00796B).withValues(alpha: 0.35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "ADD POINTS VIA UPI",
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Warm Cream
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded,
                  color: Color(0xFFE65100), size: 20),
              const SizedBox(width: 8),
              Text(
                "Instant UPI Automated Deposit",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "• Minimum deposit points: 500.\n• Points are credited immediately to your wallet.\n• Supports Google Pay, PhonePe, Paytm, and all UPI apps.\n• 100% Safe, Secure & Encrypted transactions.",
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF795548),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
