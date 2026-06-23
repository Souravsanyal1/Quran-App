import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'quran_controller.dart';

class QuranView extends GetView<QuranController> {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    
    // Refresh bookmarks and last read when view is shown
    controller.loadBookmarksAndLastRead();

    return Obx(() {
      final bn = settings.isBangla;
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              bn ? 'আল-কুরআন' : 'Al-Quran',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download_for_offline_outlined),
                onPressed: () => Get.toNamed(AppRoutes.quranDownload),
              ),
            ],
            bottom: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: bn ? 'সূরা' : 'Surah'),
                Tab(text: bn ? 'পারা' : 'Juz / Para'),
                Tab(text: bn ? 'বুকমার্ক' : 'Bookmarks'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildSurahTab(context, settings),
              _buildParaTab(context, settings),
              _buildBookmarksTab(context, settings),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSurahTab(BuildContext context, SettingsController settings) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (val) => controller.searchSurah(val),
            style: TextStyle(color: settings.isDark ? AppColors.textWhite : AppColors.textDark),
            decoration: InputDecoration(
              hintText: settings.isBangla ? 'সূরা খুঁজুন...' : 'Search Surah...',
              hintStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
              filled: true,
              fillColor: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),

        // Last Read Banner
        Obx(() {
          final lr = controller.lastRead.value;
          if (lr == null) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/images/quran_icon.png', // Fallback, or design-based icon
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.menu_book,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            settings.isBangla ? 'সর্বশেষ পঠিত' : 'Last Read',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lr.surahName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${settings.isBangla ? "আয়াত নং" : "Ayah No"}: ${lr.ayahNumber}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.surahDetails,
                          arguments: {
                            'surahNumber': lr.surahNumber,
                            'surahName': lr.surahName,
                            'initialAyah': lr.ayahNumber,
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          settings.isBangla ? 'পড়া চালিয়ে যান' : 'Resume Reading',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // Surah List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (controller.filteredSurahList.isEmpty) {
              return Center(
                child: Text(
                  settings.isBangla ? 'কোনো সূরা পাওয়া যায়নি' : 'No Surah found',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.filteredSurahList.length,
              separatorBuilder: (context, index) => Divider(
                color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              itemBuilder: (context, index) {
                final surah = controller.filteredSurahList[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Text(
                      surah.number.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    surah.englishName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    '${surah.revelationType} • ${surah.numberOfAyahs} ${settings.isBangla ? "আয়াত" : "Ayahs"}',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        surah.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textGrey),
                    ],
                  ),
                  onTap: () => Get.toNamed(
                    AppRoutes.surahDetails,
                    arguments: {
                      'surahNumber': surah.number,
                      'surahName': surah.englishName,
                    },
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildParaTab(BuildContext context, SettingsController settings) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.paraList.length,
      separatorBuilder: (context, index) => Divider(
        color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
      itemBuilder: (context, index) {
        final para = controller.paraList[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Text(
              para.number.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          title: Text(
            para.nameMeaning,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
          subtitle: Text(
            '${settings.isBangla ? "শুরু" : "Starts at"} ${settings.isBangla ? "সূরা" : "Surah"} ${para.startSurah}:${para.startAyah}',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                para.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textGrey),
            ],
          ),
          onTap: () => Get.toNamed(
            AppRoutes.paraDetails,
            arguments: {
              'paraNumber': para.number,
              'paraName': para.nameMeaning,
            },
          ),
        );
      },
    );
  }

  Widget _buildBookmarksTab(BuildContext context, SettingsController settings) {
    return Obx(() {
      if (controller.bookmarkList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_outline, size: 64, color: AppColors.textGrey),
              const SizedBox(height: 16),
              Text(
                settings.isBangla
                    ? 'কোনো বুকমার্ক সংরক্ষিত নেই'
                    : 'No bookmarks saved',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.bookmarkList.length,
        separatorBuilder: (context, index) => Divider(
          color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        itemBuilder: (context, index) {
          final bookmark = controller.bookmarkList[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${bookmark.surahName} [${bookmark.surahNumber}:${bookmark.ayahNumber}]',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => controller.removeBookmark(bookmark.surahNumber, bookmark.ayahNumber),
                ),
              ],
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bookmark.ayahText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            onTap: () => Get.toNamed(
              AppRoutes.surahDetails,
              arguments: {
                'surahNumber': bookmark.surahNumber,
                'surahName': bookmark.surahName,
                'initialAyah': bookmark.ayahNumber,
              },
            ),
          );
        },
      );
    });
  }
}
