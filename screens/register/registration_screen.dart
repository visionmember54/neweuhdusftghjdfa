import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_constants.dart';
import '../home/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.mediumImpact();

      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Header ---
              _buildHeader(size),

              // --- Main Form Content ---
              Transform.translate(
                offset: const Offset(0, -32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildRegisterCard(),
                      const SizedBox(height: 20),
                      _buildLoginLink(),
                      const SizedBox(height: 24),
                      _buildSecurityBadge(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.36,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00382E), // Deep Emerald
            Color(0xFF005A4C),
            Color(0xFF007A68),
            Color(0xFF009688),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo with Gold Ring
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      AppConstants.appLogoImage,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFFFD54F),
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "CREATE ACCOUNT",
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "Join Kalyan Official • 100% Trusted App",
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Register New User",
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Enter your basic details to start playing",
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),

            // Full Name Field
            _buildFieldLabel("Full Name", Icons.person_outline_rounded),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
              decoration: _buildInputDecoration("e.g. Aman Jha", Icons.person_rounded),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // Mobile Number Field
            _buildFieldLabel("Mobile Number", Icons.phone_android_rounded),
            const SizedBox(height: 6),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: 1.0,
              ),
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.smartphone_rounded,
                          color: Color(0xFF00796B), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "+91",
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
                hintText: "9876543210",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
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
              validator: (val) {
                if (val == null || val.trim().length != 10) {
                  return 'Enter a valid 10-digit mobile number';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // Password Field
            _buildFieldLabel("Password", Icons.lock_outline_rounded),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.key_rounded,
                    color: Color(0xFF00796B), size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF64748B),
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                hintText: "Create a password (min 6 chars)",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
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
              validator: (val) {
                if (val == null || val.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // Security PIN Field (4 digits)
            _buildFieldLabel("Security MPIN (4 Digits)", Icons.pin_rounded),
            const SizedBox(height: 6),
            TextFormField(
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: 2.0,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.security_rounded,
                    color: Color(0xFF00796B), size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePin
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF64748B),
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
                hintText: "••••",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
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
              validator: (val) {
                if (val == null || val.trim().length != 4) {
                  return 'Enter a 4-digit security PIN';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFF00796B).withValues(alpha: 0.35),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "CREATE ACCOUNT",
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
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

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF00796B)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF00796B), size: 18),
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(
        fontSize: 14,
        color: const Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 1.5),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              "Sign In",
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00796B),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_rounded,
            size: 14, color: const Color(0xFF00796B).withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Text(
          "256-Bit Encrypted • 100% Private & Protected",
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
