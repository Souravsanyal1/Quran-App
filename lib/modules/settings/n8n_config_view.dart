import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import 'n8n_config_controller.dart';
import 'settings_controller.dart';

class _N8nTheme {
  _N8nTheme._();
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color darkSurface = Color(0xFF141420);
  static const Color darkCard = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

class N8nConfigView extends GetView<N8nConfigController> {
  const N8nConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final bn = settings.isBangla;

      final scaffoldBg =
          isDark ? _N8nTheme.darkSurface : _N8nTheme.lightSurface;
      final cardColor = isDark ? _N8nTheme.darkCard : _N8nTheme.lightCard;
      final textColor = isDark ? Colors.white : AppColors.textDark;
      final subtitleColor = isDark ? AppColors.textGrey : Colors.black54;
      final borderColor = isDark
          ? _N8nTheme.emerald.withValues(alpha: 0.15)
          : _N8nTheme.emerald.withValues(alpha: 0.06);

      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            leading: const AppBackButton(color: Colors.white),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _N8nTheme.emeraldDark,
                    _N8nTheme.emerald,
                    _N8nTheme.emeraldLight
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                    bottom: BorderSide(color: _N8nTheme.gold, width: 1.5)),
              ),
            ),
            title: Text(
              bn ? 'লোড হচ্ছে...' : 'Loading Settings...',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: const Center(
            child: CircularProgressIndicator(color: _N8nTheme.emerald),
          ),
        );
      }

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _N8nTheme.emeraldDark,
                  _N8nTheme.emerald,
                  _N8nTheme.emeraldLight
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border:
                  Border(bottom: BorderSide(color: _N8nTheme.gold, width: 1.5)),
            ),
          ),
          title: Text(
            bn ? 'লাইভ চ্যাট সেটিংস (n8n)' : 'Live Chat Settings (n8n)',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              onPressed: () async {
                final success = await controller.saveConfig();
                if (success) {
                  Get.snackbar(
                    bn ? 'সংরক্ষিত হয়েছে' : 'Settings Saved',
                    bn
                        ? 'লাইভ চ্যাট সেটিংস সফলভাবে আপডেট করা হয়েছে'
                        : 'Live chat configurations updated successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: _N8nTheme.emerald.withValues(alpha: 0.92),
                    colorText: Colors.white,
                    borderRadius: 16,
                    margin: const EdgeInsets.all(16),
                  );
                  Get.back();
                }
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info Card ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _N8nTheme.emerald
                        .withValues(alpha: isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _N8nTheme.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: _N8nTheme.gold, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bn
                              ? 'আপনার n8n লাইভ চ্যাট সাপোর্ট বা MCP সার্ভারের ইউআরএল এবং এপিআই কি এখানে কনফিগার করুন। চেঞ্জ সেভ করতে উপরের টিক চিহ্নটিতে ট্যাপ করুন।'
                              : 'Configure your n8n Live Chat Support or MCP Server URL and API Key here. Tap the checkmark icon at the top right to save changes.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: textColor.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Section 1: Endpoint Settings ──
                _buildSectionHeader(
                    bn ? 'এন্ডপয়েন্ট কনফিগারেশন' : 'Endpoint Configuration'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: controller.urlController,
                        label: bn ? 'ইউআরএল (URL)' : 'Webhook / MCP Server URL',
                        hint: 'https://...',
                        icon: Icons.link_rounded,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.apiKeyController,
                        label: bn ? 'এপিআই কী (ঐচ্ছিক)' : 'API Key (Optional)',
                        hint: bn ? 'আপনার n8n এপিআই কী' : 'Enter n8n API Key',
                        icon: Icons.vpn_key_rounded,
                        isDark: isDark,
                        textColor: textColor,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Obx(() => SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              bn
                                  ? 'মডেল কনটেক্সট প্রোটোকল (MCP) প্রোটোকল'
                                  : 'Model Context Protocol (MCP) Mode',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              bn
                                  ? 'অন করলে JSON-RPC ফরম্যাটে ডাটা যাবে, অফ থাকলে সরাসরি POST রিকোয়েস্ট যাবে'
                                  : 'Enable JSON-RPC wrapping for MCP servers, or disable for standard webhooks',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: subtitleColor),
                            ),
                            value: controller.useMcp.value,
                            activeThumbColor: _N8nTheme.gold,
                            activeTrackColor: _N8nTheme.emerald,
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor:
                                Colors.grey.withValues(alpha: 0.2),
                            onChanged: (val) => controller.useMcp.value = val,
                          )),
                      Obx(() {
                        if (!controller.useMcp.value)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _buildTextField(
                            controller: controller.toolNameController,
                            label: bn
                                ? 'টুল নাম (MCP Tool Name)'
                                : 'MCP Tool Name',
                            hint: 'chat',
                            icon: Icons.build_circle_rounded,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Section 2: Connection Testing Console ──
                _buildSectionHeader(
                    bn ? 'কানেকশন টেস্ট কনসোল' : 'Connection Testing Console'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: controller.testMessageController,
                        label: bn ? 'টেস্ট মেসেজ' : 'Test Message',
                        hint: bn
                            ? 'যেমন: আসসালামু আলাইকুম'
                            : 'e.g. Hello, who are you?',
                        icon: Icons.chat_bubble_outline_rounded,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 16),
                      Obx(() => ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _N8nTheme.emerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: controller.isTesting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.bolt_rounded,
                                    color: _N8nTheme.gold),
                            label: Text(
                              controller.isTesting.value
                                  ? (bn ? 'পরীক্ষা করা হচ্ছে...' : 'Testing...')
                                  : (bn
                                      ? 'কানেকশন পরীক্ষা করুন'
                                      : 'Test Connection'),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            onPressed: controller.isTesting.value
                                ? null
                                : () => controller.testConnection(),
                          )),

                      // Test Results
                      Obx(() {
                        if (controller.testResultText.value.isEmpty &&
                            controller.testResultStatus.value == null) {
                          return const SizedBox.shrink();
                        }

                        final status = controller.testResultStatus.value;
                        final isSuccess = status == 200;
                        final badgeColor =
                            isSuccess ? Colors.green : Colors.redAccent;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bn ? 'ফলাফল:' : 'Test Result:',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                ),
                                if (status != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: badgeColor, width: 1),
                                    ),
                                    child: Text(
                                      'HTTP $status',
                                      style: GoogleFonts.poppins(
                                        color: badgeColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Parsed Response Text Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? _N8nTheme.darkSurface
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(
                                controller.testResultText.value,
                                style: GoogleFonts.poppins(
                                  color:
                                      isSuccess ? textColor : Colors.redAccent,
                                  fontSize: 13.5,
                                  height: 1.4,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Detailed Payload Logs Panel
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                leading: const Icon(Icons.terminal_rounded,
                                    color: _N8nTheme.gold, size: 20),
                                title: Text(
                                  bn
                                      ? 'র-পেলোড ও ডাটা ডিটেইলস'
                                      : 'Raw Payload & Log Details',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: subtitleColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    constraints:
                                        const BoxConstraints(maxHeight: 250),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          controller.testResultDetails.value,
                                          style: GoogleFonts.sourceCodePro(
                                            color: Colors.greenAccent,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: _N8nTheme.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _N8nTheme.emerald,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.poppins(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: textColor.withValues(alpha: 0.4), fontSize: 13),
            prefixIcon: Icon(icon, color: _N8nTheme.gold, size: 20),
            filled: true,
            fillColor: isDark ? _N8nTheme.darkSurface : Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _N8nTheme.gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
