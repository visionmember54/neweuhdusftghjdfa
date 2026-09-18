import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: "Aman Jha");
  final TextEditingController _emailController =
      TextEditingController(text: "aman.jha@example.com");
  final TextEditingController _mobileController =
      TextEditingController(text: "+91 8076580694");

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    HapticFeedback.mediumImpact();
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Color(0xFF00796B),
      ),
    );
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
            // --- 1. User Avatar & Brand Card ---
            _buildAvatarCard(),

            const SizedBox(height: 16),

            // --- 2. Profile Details Form Card ---
            _buildDetailsCard(),

            const SizedBox(height: 20),

            // --- 3. Account Status & Security Card ---
            _buildSecurityCard(),
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
        "My Profile",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isEditing ? Icons.check_rounded : Icons.edit_rounded,
            color: const Color(0xFFFFD54F),
          ),
          tooltip: _isEditing ? "Save" : "Edit",
          onPressed: () {
            if (_isEditing) {
              _saveProfile();
            } else {
              HapticFeedback.lightImpact();
              setState(() => _isEditing = true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAvatarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          // Circular Avatar with Gold Halo
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFD54F),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00796B).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF004D40),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    AppConstants.appLogoImage,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // User Name & Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _nameController.text,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF00796B),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _mobileController.text,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PERSONAL DETAILS",
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              if (!_isEditing)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isEditing = true);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 14, color: Color(0xFF00796B)),
                      const SizedBox(width: 4),
                      Text(
                        "Edit",
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00796B),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Full Name
          _buildField(
            label: "Full Name",
            controller: _nameController,
            icon: Icons.person_outline_rounded,
            enabled: _isEditing,
          ),

          const SizedBox(height: 14),

          // Mobile Number
          _buildField(
            label: "Mobile Number",
            controller: _mobileController,
            icon: Icons.phone_android_rounded,
            enabled: false, // Protected
          ),

          const SizedBox(height: 14),

          // Email Address
          _buildField(
            label: "Email Address",
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            enabled: _isEditing,
          ),

          if (_isEditing) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  "SAVE PROFILE CHANGES",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
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
        TextField(
          controller: controller,
          enabled: enabled,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: enabled ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF00796B), size: 20),
            filled: true,
            fillColor:
                enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF00796B), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF80CBC4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded,
              color: Color(0xFF00796B), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account Security Verified",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Your wallet & personal details are protected with 256-bit encryption.",
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF004D40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
