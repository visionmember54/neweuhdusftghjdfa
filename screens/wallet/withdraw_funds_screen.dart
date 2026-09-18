import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  String _selectedPaymentMethod = 'Bank Details';
  final TextEditingController _amountController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "name": "Bank Details",
      "icon": Icons.account_balance_rounded,
      "color": Color(0xFF00796B),
      "bgColor": Color(0xFFE0F2F1),
    },
    {
      "name": "PhonePe",
      "icon": Icons.touch_app_rounded,
      "color": Color(0xFF673AB7),
      "bgColor": Color(0xFFEDE7F6),
    },
    {
      "name": "Google Pay",
      "icon": Icons.payment_rounded,
      "color": Color(0xFF1976D2),
      "bgColor": Color(0xFFE3F2FD),
    },
    {
      "name": "Paytm",
      "icon": Icons.account_balance_wallet_rounded,
      "color": Color(0xFF0288D1),
      "bgColor": Color(0xFFE1F5FE),
    },
  ];

  void _handleWithdraw() {
    final int amount = int.tryParse(_amountController.text) ?? 0;
    if (amount < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Minimum withdrawal amount is ₹1,000"),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Withdrawal request submitted for ₹$amount via $_selectedPaymentMethod!",
        ),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
            // --- 1. Balance & Timing Schedule Banner ---
            _buildBalanceScheduleBanner(),

            const SizedBox(height: 16),

            // --- 2. Select Payment Method Section ---
            _buildSectionTitle("SELECT WITHDRAWAL METHOD"),
            const SizedBox(height: 10),
            _buildPaymentMethodsRow(),

            const SizedBox(height: 20),

            // --- 3. Withdrawal Form Card ---
            _buildWithdrawalFormCard(),

            const SizedBox(height: 20),

            // --- 4. Terms / Rules Notice Card ---
            _buildRulesNoticeCard(),
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
        "Withdraw Funds",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBalanceScheduleBanner() {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Withdrawable Balance",
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
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "MIN: ₹1,000",
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
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 16, color: Color(0xFF00796B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Withdrawal Window: 07:00 AM to 10:00 AM daily",
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00796B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF64748B),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildPaymentMethodsRow() {
    return Row(
      children: _paymentMethods.map((method) {
        final bool isSelected = _selectedPaymentMethod == method["name"];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPaymentMethod = method["name"]);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00796B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00796B)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00796B).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(
                    method["icon"] as IconData,
                    color: isSelected ? Colors.white : method["color"] as Color,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    method["name"] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWithdrawalFormCard() {
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
            "Selected Method: $_selectedPaymentMethod",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00796B),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "Enter Withdrawal Amount",
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.currency_rupee_rounded,
                color: Color(0xFF00796B),
                size: 22,
              ),
              hintText: "Enter points (Min ₹1,000)",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

          const SizedBox(height: 20),

          // Submit Request Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF00796B).withValues(alpha: 0.35),
              ),
              child: Text(
                "SUBMIT WITHDRAWAL REQUEST",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesNoticeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF00796B), size: 18),
              const SizedBox(width: 8),
              Text(
                "Withdrawal Guidelines",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "• Withdraw requests are accepted between 07:00 AM and 10:00 AM.\n• Minimum withdrawal limit is 1,000 points.\n• Payouts are transferred directly to your verified bank or UPI account.\n• Processing time: 10 to 30 minutes on business days.",
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
