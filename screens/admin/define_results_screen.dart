import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';

class DefineResultsScreen extends StatefulWidget {
  const DefineResultsScreen({super.key});

  @override
  State<DefineResultsScreen> createState() => _DefineResultsScreenState();
}

class _DefineResultsScreenState extends State<DefineResultsScreen> {
  final TextEditingController _resultController = TextEditingController();

  final List<String> _markets = [
    'MILAN DAY',
    'RAJDHANI DAY',
    'KALYAN NIGHT',
    'MILAN NIGHT',
    'GALI',
    'DESAWAR',
  ];

  final List<String> _sessions = ['OPEN', 'CLOSE'];
  final List<String> _statuses = ['PENDING', 'PUBLISHED', 'LOCKED'];

  String _selectedMarket = 'MILAN DAY';
  String _selectedSession = 'OPEN';
  String _selectedStatus = 'PENDING';

  final List<Map<String, String>> _resultEntries = [
    {'market': 'MILAN DAY', 'session': 'OPEN', 'result': '88', 'status': 'PUBLISHED'},
    {'market': 'RAJDHANI DAY', 'session': 'CLOSE', 'result': '41', 'status': 'PUBLISHED'},
    {'market': 'GALI', 'session': 'OPEN', 'result': '72', 'status': 'LOCKED'},
  ];

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  void _saveResult() {
    final value = _resultController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a result number.'),
          backgroundColor: AppColors.goldDark,
        ),
      );
      return;
    }

    setState(() {
      _resultEntries.insert(
        0,
        {
          'market': _selectedMarket,
          'session': _selectedSession,
          'result': value,
          'status': _selectedStatus,
        },
      );
    });

    _resultController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result saved for $_selectedMarket ($_selectedSession)'),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormCard(),
            const SizedBox(height: 20),
            Text(
              'Recent declarations',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._resultEntries.map((entry) => _buildResultRow(entry)).toList(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 2,
      shadowColor: AppColors.emeraldDarkest.withValues(alpha: 0.35),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.emeraldDark,
              AppColors.emeraldDeep,
              AppColors.emerald,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Define Results',
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market declaration',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Market',
            value: _selectedMarket,
            items: _markets,
            onChanged: (value) => setState(() => _selectedMarket = value ?? _selectedMarket),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            label: 'Session',
            value: _selectedSession,
            items: _sessions,
            onChanged: (value) => setState(() => _selectedSession = value ?? _selectedSession),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _resultController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Winning result',
              labelStyle: GoogleFonts.dmSans(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.emerald),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            label: 'Status',
            value: _selectedStatus,
            items: _statuses,
            onChanged: (value) => setState(() => _selectedStatus = value ?? _selectedStatus),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Result',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderSubtle),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceMuted,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.dmSans(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(Map<String, String> entry) {
    final statusColor = entry['status'] == 'PUBLISHED'
        ? AppColors.emerald
        : entry['status'] == 'LOCKED'
            ? AppColors.goldDark
            : AppColors.textSlate;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['market']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry['session']} • Result ${entry['result']}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry['status']!,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
