import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketBetScreen extends StatefulWidget {
  final String gameName;
  final String betType; // "SINGLE DIGIT", "JODI DIGIT", "SINGLE PANA", etc.

  const MarketBetScreen({
    super.key,
    required this.gameName,
    required this.betType,
  });

  @override
  State<MarketBetScreen> createState() => _MarketBetScreenState();
}

class _MarketBetScreenState extends State<MarketBetScreen> {
  final Set<String> _selectedNumbers = {};
  final TextEditingController _amountController = TextEditingController();

  // Session selector: "OPEN" or "CLOSE" for relevant bet types
  String _selectedSession = "OPEN";

  final List<int> _quickAmounts = [10, 50, 100, 500];
  List<String> _gridNumbers = [];

  bool get _canChooseSession =>
      widget.betType != "JODI DIGIT" &&
      widget.betType != "HALF SANGAM" &&
      widget.betType != "FULL SANGAM";

  int get _payoutMultiplier {
    switch (widget.betType) {
      case "SINGLE DIGIT":
        return 95;
      case "JODI DIGIT":
        return 950;
      case "SINGLE PANA":
        return 1500;
      case "DOUBLE PANA":
        return 3000;
      case "TRIPLE PANA":
        return 9000;
      case "HALF SANGAM":
        return 12000;
      case "FULL SANGAM":
        return 100000;
      default:
        return 95;
    }
  }

  @override
  void initState() {
    super.initState();
    _generateGridNumbers();
    _amountController.text = "";
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _generateGridNumbers() {
    if (widget.betType == "SINGLE DIGIT") {
      _gridNumbers = List.generate(10, (index) => index.toString());
    } else if (widget.betType == "JODI DIGIT") {
      _gridNumbers =
          List.generate(100, (index) => index.toString().padLeft(2, '0'));
    } else if (widget.betType == "DOUBLE PANA") {
      _gridNumbers = _generateDoublePanas();
    } else if (widget.betType == "TRIPLE PANA") {
      _gridNumbers = _generateTriplePanas();
    } else if (widget.betType == "SINGLE PANA") {
      _gridNumbers = _generateSinglePanas();
    } else {
      _gridNumbers = List.generate(10, (index) => index.toString());
    }
  }

  List<String> _generateDoublePanas() {
    final List<String> panas = [];
    for (int i = 0; i <= 9; i++) {
      for (int j = 0; j <= 9; j++) {
        if (i == j) continue;
        final digits = [i, i, j]..sort();
        final pana = digits.join();
        if (!panas.contains(pana)) {
          panas.add(pana);
        }
      }
    }
    panas.sort();
    return panas;
  }

  List<String> _generateTriplePanas() {
    return List.generate(10, (i) => "$i$i$i");
  }

  List<String> _generateSinglePanas() {
    final List<String> panas = [];
    for (int i = 0; i <= 9; i++) {
      for (int j = i + 1; j <= 9; j++) {
        for (int k = j + 1; k <= 9; k++) {
          panas.add("$i$j$k");
        }
      }
    }
    return panas;
  }

  void _toggleSelection(String number) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        if (widget.betType == "DOUBLE PANA" && _selectedNumbers.length >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Only 2 numbers can be selected for Double Pana"),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        _selectedNumbers.add(number);
      }
    });
  }

  void _submitBet(int totalAmount) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Bet placed successfully for ${_selectedNumbers.length} numbers (₹$totalAmount)!",
        ),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int amountPerNumber = int.tryParse(_amountController.text) ?? 0;
    final int totalAmount = _selectedNumbers.length * amountPerNumber;
    final int potentialWin = (amountPerNumber * (_payoutMultiplier / 10)).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Subtle, glare-free canvas
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // --- 1. Market & Session Header Card ---
          _buildMarketHeaderCard(),

          // --- 2. Number Grid Selection Header ---
          _buildGridHeader(),

          // --- 3. Interactive Numbers Grid ---
          Expanded(child: _buildNumbersGrid()),

          // --- 4. Bottom Input, Chips & Bet Summary Sheet ---
          _buildBottomBetSheet(totalAmount, potentialWin),
        ],
      ),
    );
  }

  // --- AppBar with Unified Emerald Theme ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 2,
      shadowColor: const Color(0xFF004D40).withValues(alpha: 0.3),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF004D40), // Deep Forest Teal
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
              fontSize: 17,
              letterSpacing: 0.5,
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
        // Wallet Balance Indicator
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

  // --- 1. Market & Session Header Card ---
  Widget _buildMarketHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.gameName,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    "Payout: 10 - $_payoutMultiplier",
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00796B),
                    ),
                  ),
                ],
              ),
              // Session Selector (Open vs Close)
              if (_canChooseSession)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSessionPill("OPEN", "Open Session"),
                      _buildSessionPill("CLOSE", "Close Session"),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "DUAL SESSION",
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
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

  Widget _buildSessionPill(String value, String tooltip) {
    final bool isSelected = _selectedSession == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedSession = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00796B) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // --- 2. Grid Header ---
  Widget _buildGridHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "SELECT LUCKY NUMBERS",
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _selectedNumbers.isNotEmpty
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${_selectedNumbers.length} Selected",
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _selectedNumbers.isNotEmpty
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Interactive Numbers Grid ---
  Widget _buildNumbersGrid() {
    if (_gridNumbers.isEmpty) {
      return Center(
        child: Text(
          "No numbers available for this game mode",
          style: GoogleFonts.dmSans(color: const Color(0xFF64748B)),
        ),
      );
    }

    final bool isPana = widget.betType.contains("PANA");

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isPana ? 3 : 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isPana ? 2.4 : 1.25,
      ),
      itemCount: _gridNumbers.length,
      itemBuilder: (context, index) {
        final number = _gridNumbers[index];
        final isSelected = _selectedNumbers.contains(number);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleSelection(number),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00796B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00796B)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
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
              alignment: Alignment.center,
              child: Text(
                number,
                style: GoogleFonts.robotoMono(
                  fontSize: isPana ? 14 : 16,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 4. Bottom Input, Chips & Bet Summary Sheet ---
  Widget _buildBottomBetSheet(int totalAmount, int potentialWin) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) => setState(() {}),
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.currency_rupee,
                        color: Color(0xFF00796B),
                        size: 18,
                      ),
                      hintText: "Enter points per number",
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                  ),
                ),
                const SizedBox(width: 8),
                // Clear Selection Button
                if (_selectedNumbers.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_all_rounded,
                        color: Color(0xFFDC2626)),
                    tooltip: "Clear all",
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedNumbers.clear());
                    },
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Quick Chips Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _quickAmounts.map((amt) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _amountController.text = amt.toString());
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
                      "+₹$amt",
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

            const SizedBox(height: 14),

            // Summary Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected: ${_selectedNumbers.length} Numbers",
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total Points: ₹$totalAmount",
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Session: $_selectedSession",
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF00796B),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Win: ₹$potentialWin",
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Place Bet Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: totalAmount > 0
                    ? () => _submitBet(totalAmount)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: totalAmount > 0 ? 3 : 0,
                ),
                child: Text(
                  totalAmount > 0
                      ? "PLACE BET • ₹$totalAmount"
                      : "SELECT NUMBER & AMOUNT",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
