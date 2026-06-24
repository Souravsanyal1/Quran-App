import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'developer_info_controller.dart';

class DeveloperInfoView extends GetView<DeveloperInfoController> {
  const DeveloperInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final bn = settings.isBangla;

      final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
      final textColor = isDark ? Colors.white : AppColors.textDark;
      final subtitleColor = isDark ? AppColors.textMuted : Colors.black54;
      final borderColor = isDark ? AppColors.borderDark : Colors.black12;

      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF9F9F9),
        appBar: AppBar(
          leading: const AppBackButton(),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            bn ? 'ডেভেলপার তথ্য' : 'Developer Information',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                
                // Avatar with premium gradient border
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFFFFB300)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name & Publisher
                Text(
                  'Sourav Sanyal Joy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bn ? 'প্রকাশক: Nexora Labs' : 'Publisher: Nexora Labs',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Section Title: Contact & Socials
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    bn ? 'যোগাযোগ ও সোশ্যাল মিডিয়া' : 'Contact & Social Links',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Social Grid/List Cards
                _buildSocialTile(
                  title: 'Email',
                  subtitle: 'joysanyal1999@gmail.com',
                  icon: Icons.email_rounded,
                  color: Colors.redAccent,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchEmail(),
                ),
                const SizedBox(height: 12),
                
                _buildSocialTile(
                  title: bn ? 'পোর্টফোলিও' : 'Portfolio',
                  subtitle: 'souravs-portfollio.vercel.app',
                  icon: Icons.language_rounded,
                  color: Colors.blueAccent,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://souravs-portfollio.vercel.app/'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'GitHub',
                  subtitle: 'github.com/Souravsanyal1',
                  icon: Icons.code_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://github.com/Souravsanyal1'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'LinkedIn',
                  subtitle: 'linkedin.com/in/sourav-sanyal-joy',
                  icon: Icons.business_center_rounded,
                  color: const Color(0xFF0077B5),
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://www.linkedin.com/in/sourav-sanyal-joy/'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'X / Twitter',
                  subtitle: 'x.com/Souravisms',
                  icon: Icons.tag_rounded,
                  color: Colors.cyan,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://x.com/Souravisms'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'Facebook',
                  subtitle: 'facebook.com/sourav.sanyal.developer',
                  icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://www.facebook.com/sourav.sanyal.developer/'),
                ),
                
                const SizedBox(height: 32),
                
                // Footer
                Text(
                  bn ? 'Quran App এর সাথে থাকার জন্য ধন্যবাদ।' : 'Thank you for supporting Quran App.',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSocialTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: subtitleColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
