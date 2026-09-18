import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GaliDesawerBetScreen extends StatefulWidget {
  final String gameName;
  final String betType; // "Left Digit", "Right Digit", "Jodi Digit"

  const GaliDesawerBetScreen({
    super.key,
    required this.gameName,
    required this.betType,
  });

  @override
  State<GaliDesawerBetScreen> createState() => _GaliDesawerBetScreenState();
}

class _GaliDesawerBetScreenState extends State<GaliDesawerBetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _digitController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  late String _currentDate;

  final List<int> _quickPoints = [10, 50, 100, 500];

  @override
  void initState() {
    super.initState();
    _currentDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _digitController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _submitBet() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Bet placed: ${widget.betType} (${_digitController.text}) for ${_pointsController.text} points!",
          ),
          backgroundColor: const Color(0xFF00796B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft slate background
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Top Card: Date & Bet Summary ---
              _buildTopInfoCard(),

              const SizedBox(height: 16),

              // --- 2. Digit Input Container ---
              _buildFormCard(),

              const SizedBox(height: 24),

              // --- 3. Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitBet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF00796B).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    "SUBMIT BET",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              Color(0xFF00796B), // Rich Teal
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.betType,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            widget.gameName.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: const Color(0xFFFFD54F),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFFFFD54F),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                "₹ 5",
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopInfoCard() {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.gameName,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Date: $_currentDate",
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.betType.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00796B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final bool isJodi = widget.betType.toLowerCase().contains("jodi");

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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Digit Input
          Text(
            isJodi ? "Enter Jodi Digit (00 - 99)" : "Enter Digit (0 - 9)",
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _digitController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(isJodi ? 2 : 1),
            ],
            style: GoogleFonts.robotoMono(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: isJodi ? "e.g. 45" : "e.g. 7",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.pin_rounded,
                color: Color(0xFF00796B),
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF00796B), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a digit';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Points Input
          Text(
            "Enter Points (Min ₹10)",
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pointsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: "e.g. 100",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.currency_rupee,
                color: Color(0xFF00796B),
                size: 18,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF00796B), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter points';
              }
              final int? pts = int.tryParse(value);
              if (pts == null || pts < 10) {
                return 'Minimum points is 10';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Quick Points Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _quickPoints.map((pts) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _pointsController.text = pts.toString());
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    "+₹$pts",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
