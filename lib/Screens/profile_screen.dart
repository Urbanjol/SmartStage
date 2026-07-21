import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import our modular toolkit components and theme provider
import '../Widgets/verification_badge.dart';
import '../Providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Detect current theme mode for fine-tuned color accents
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    // UI Theme Constants based on state
    final Color primaryBrandColor = const Color(0xFF0056b3);
    final Color textPrimaryColor = isDarkMode ? Colors.white : Colors.black87;
    final Color textSecondaryColor = isDarkMode ? Colors.white70 : Colors.grey
        .shade600;

    // Mock dynamic profile data
    const String mockUserName = "Ronald Mukasa";
    const String mockUserPhone = "+256 772 000 000";
    const double mockWalletBalance = 185000.0;

    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "SmartStage Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDarkMode
            ? const Color(0xFF172A45)
            : primaryBrandColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. AVATAR PROFILE HEADER BLOCK
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF172A45) : primaryBrandColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 32, top: 8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: isDarkMode
                        ? const Color(0xFF0A192F)
                        : Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: isDarkMode ? Colors.white : primaryBrandColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    mockUserName,
                    style: TextStyle(color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    mockUserPhone,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Reusable Trust Verification Badge
                  const VerificationBadge(
                    isVerified: true,
                    title: "Identity Authenticated",
                  ),
                ],
              ),
            ),

            // 2. ESCROW DIGITAL WALLET CONTAINER
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors
                      .grey.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ESCROW DIGITAL WALLET",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textSecondaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Icon(
                          Icons.account_balance_wallet, color: Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${mockWalletBalance.toInt()} UGX",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.orange : primaryBrandColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Funds locked securely inside automated transaction containers.",
                    style: TextStyle(fontSize: 11, color: textSecondaryColor),
                  ),
                  Divider(height: 24, color: Theme
                      .of(context)
                      .dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_card, size: 18),
                        label: const Text("Deposit MoMo"),
                        style: TextButton.styleFrom(
                          foregroundColor: isDarkMode
                              ? Colors.orange
                              : primaryBrandColor,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text("Audit Ledger"),
                        style: TextButton.styleFrom(
                            foregroundColor: textSecondaryColor),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 3. SYSTEM OPTIONS MENU LIST
            // A. PRE-BUILT INTEGRATED DARK MODE INTERFACE TOGGLE SWITCH
            ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.orange : primaryBrandColor,
              ),
              title: Text(
                "Dark Theme Interface",
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimaryColor),
              ),
              trailing: Switch(
                value: isDarkMode,
                activeColor: Colors.orange,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
            ),
            Divider(height: 1, indent: 56, color: Theme
                .of(context)
                .dividerColor),

            ListTile(
              leading: Icon(Icons.history_edu,
                  color: isDarkMode ? Colors.orange : primaryBrandColor),
              title: Text(
                "My Dispatch Bookings",
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimaryColor),
              ),
              trailing: Icon(
                  Icons.arrow_forward_ios, size: 14, color: textSecondaryColor),
              onTap: () {},
            ),
            Divider(height: 1, indent: 56, color: Theme
                .of(context)
                .dividerColor),

            ListTile(
              leading: Icon(Icons.security,
                  color: isDarkMode ? Colors.orange : primaryBrandColor),
              title: Text(
                "Privacy & Trust Protocols",
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimaryColor),
              ),
              trailing: Icon(
                  Icons.arrow_forward_ios, size: 14, color: textSecondaryColor),
              onTap: () {},
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}