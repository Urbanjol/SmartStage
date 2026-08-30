import 'package:flutter/material.dart';
import '../Config/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('HELP & SUPPORT'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFFB197FC),
              Color(0xFFF8FAFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSupportCard(
              icon: Icons.chat_bubble_outline,
              title: 'Chat with Assistant',
              subtitle: 'Ask SmartStage Assistant anything',
              color: const Color(0xFF2563EB),
              onTap: () {
                // Open assistant
              },
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'smartstage.ug@gmail.com',
              color: const Color(0xFF7B2FF7),
              onTap: () {
                // Open email
              },
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.call_outlined,
              title: 'Call Support',
              subtitle: '+256 700 000 000',
              color: const Color(0xFF10B981),
              onTap: () {
                // Open dialer
              },
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.report_problem_outlined,
              title: 'Report a Problem',
              subtitle: 'Tell us what went wrong',
              color: const Color(0xFFFFB800),
              onTap: () {
                // Show report form
              },
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.help_outline,
              title: 'FAQs',
              subtitle: 'Common questions and answers',
              color: const Color(0xFF1E40AF),
              onTap: () {
                // Show FAQs
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}