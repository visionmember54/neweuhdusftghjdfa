import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GaliDesawerChartScreen extends StatelessWidget {
  const GaliDesawerChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Historical Chart Data
    final List<Map<String, String>> chartData = List.generate(15, (index) {
      return {
        "Date": "${index + 1}-09-2025",
        "DESAWAR": "${(index * 2 + 10) % 99}".padLeft(2, '0'),
        "JACKPOT": "${(index * 3 + 5) % 99}".padLeft(2, '0'),
        "RAJDHANI": "**",
        "DELHI": "**",
        "SHRI": "**",
        "FARIDABAD": "${(index * 5 + 20) % 99}".padLeft(2, '0'),
        "SATTA": "**",
        "GAZIYABAD": "**",
        "MUMBAI": "**",
        "GALI": "**",
      };
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft slate background
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Sub-header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded,
                    color: Color(0xFF00796B), size: 18),
                const SizedBox(width: 8),
                Text(
                  "GALI DESAWER HISTORICAL RESULT CHART",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFE0F2F1), // Soft Mint
                      ),
                      columnSpacing: 18,
                      horizontalMargin: 16,
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      columns: [
                        _buildDataColumn("Date"),
                        _buildDataColumn("DESAWAR"),
                        _buildDataColumn("JACKPOT"),
                        _buildDataColumn("RAJDHANI"),
                        _buildDataColumn("DELHI"),
                        _buildDataColumn("SHRI"),
                        _buildDataColumn("FARIDABAD"),
                        _buildDataColumn("SATTA"),
                        _buildDataColumn("GAZIYABAD"),
                        _buildDataColumn("MUMBAI"),
                        _buildDataColumn("GALI"),
                      ],
                      rows: chartData.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              data["Date"]!,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: const Color(0xFF334155),
                              ),
                            )),
                            DataCell(Center(child: _buildCellNumber(data["DESAWAR"]!))),
                            DataCell(Center(child: _buildCellNumber(data["JACKPOT"]!))),
                            DataCell(Center(child: _buildCellNumber(data["RAJDHANI"]!))),
                            DataCell(Center(child: _buildCellNumber(data["DELHI"]!))),
                            DataCell(Center(child: _buildCellNumber(data["SHRI"]!))),
                            DataCell(Center(child: _buildCellNumber(data["FARIDABAD"]!))),
                            DataCell(Center(child: _buildCellNumber(data["SATTA"]!))),
                            DataCell(Center(child: _buildCellNumber(data["GAZIYABAD"]!))),
                            DataCell(Center(child: _buildCellNumber(data["MUMBAI"]!))),
                            DataCell(Center(child: _buildCellNumber(data["GALI"]!))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
        "Gali Desawer Chart",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: const Color(0xFF004D40),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCellNumber(String number) {
    final bool isStars = number == "**";
    return Text(
      number,
      style: GoogleFonts.robotoMono(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: isStars ? const Color(0xFF94A3B8) : const Color(0xFF00796B),
      ),
    );
  }
}
