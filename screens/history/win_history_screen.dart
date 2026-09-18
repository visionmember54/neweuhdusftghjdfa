import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WinHistoryScreen extends StatefulWidget {
  const WinHistoryScreen({super.key});

  @override
  State<WinHistoryScreen> createState() => _WinHistoryScreenState();
}

class _WinHistoryScreenState extends State<WinHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now().subtract(const Duration(days: 7));
    _toDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    HapticFeedback.selectionClick();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00796B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    HapticFeedback.mediumImpact();
    setState(() => _hasSearched = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft slate background
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date Filter Card
            _buildDateFilterCard(),

            const SizedBox(height: 36),

            // Results / Empty State
            _buildEmptyState(),
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
        "Win History",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildDateFilterCard() {
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
          Text(
            "FILTER BY DATE",
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),

          // Date Selectors Row
          Row(
            children: [
              Expanded(
                child: _buildDatePickerField(
                  label: "From Date",
                  date: _fromDate,
                  isFromDate: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePickerField(
                  label: "To Date",
                  date: _toDate,
                  isFromDate: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                "SEARCH WIN HISTORY",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required bool isFromDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _selectDate(context, isFromDate),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _dateFormat.format(date) : "Select date",
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Color(0xFF00796B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7), // Soft Gold
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFD97706),
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _hasSearched ? "No Winning Bids Found" : "No Wins Recorded Yet",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Winning bids and claimed rewards will appear here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
