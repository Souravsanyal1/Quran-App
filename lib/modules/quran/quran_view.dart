import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import '../../widgets/banner_ad_widget.dart';
import 'quran_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _QViewTheme {
  _QViewTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color goldSoft     = Color(0xFFFFF8E7);
  static const Color darkSurface  = Color(0xFF141420);
  static const Color darkCard     = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard    = Color(0xFFFFFFFF);
  static const Color textMuted    = Color(0xFF7E8CA0);
}

class QuranView extends GetView<QuranController> {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    // Refresh bookmarks and last read when view is shown
    controller.loadBookmarksAndLastRead();

    return Obx(() {
      final bn = settings.isBangla;
      final isDark = settings.isDark;

      return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: isDark ? _QViewTheme.darkSurface : _QViewTheme.lightSurface,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                toolbarHeight: 64,
                backgroundColor: Colors.transparent,
                leading: const AppBackButton(color: Colors.white),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bn ? 'আল-কুরআন' : 'Al-Quran',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 2,
                      width: 28,
                      decoration: BoxDecoration(
                        color: _QViewTheme.goldLight,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_QViewTheme.emeraldDark, _QViewTheme.emerald, _QViewTheme.emeraldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(bottom: BorderSide(color: _QViewTheme.gold, width: 1.5)),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white),
                    onPressed: () => Get.toNamed(AppRoutes.quranDownload),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    color: isDark ? _QViewTheme.darkSurface : _QViewTheme.lightSurface,
                    child: TabBar(
                      indicatorColor: _QViewTheme.emerald,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: _QViewTheme.emerald,
                      unselectedLabelColor: isDark ? AppColors.textGrey : _QViewTheme.textMuted,
                      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                      unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
                      tabs: [
                        Tab(text: bn ? 'সূরা' : 'Surah'),
                        Tab(text: bn ? 'পারা' : 'Juz / Para'),
                        Tab(text: bn ? 'বুকমার্ক' : 'Bookmarks'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _buildSurahTab(context, settings),
                _buildParaTab(context, settings),
                _buildBookmarksTab(context, settings),
              ],
            ),
          ),
          bottomNavigationBar: const BannerAdWidget(),
        ),
      );
    });
  }

  Widget _buildSurahTab(BuildContext context, SettingsController settings) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Obx(() {
            final query = controller.searchQuery.value;
            final isDark = settings.isDark;
            return TextField(
              controller: controller.searchTextController,
              onChanged: (val) => controller.searchSurah(val),
              style: TextStyle(
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: settings.isBangla ? 'সূরা খুঁজুন...' : 'Search Surah...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, color: _QViewTheme.emerald),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textGrey,
                        ),
                        onPressed: () => controller.clearSearch(),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? _QViewTheme.darkCard : _QViewTheme.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? _QViewTheme.emerald.withOpacity(0.2) : _QViewTheme.emerald.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? _QViewTheme.emerald.withOpacity(0.1) : _QViewTheme.emerald.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: _QViewTheme.emerald,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            );
          }),
        ),

        // Filter Chips Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', settings.isBangla ? 'সব সূরা' : 'All Surahs', settings),
                const SizedBox(width: 8),
                _buildFilterChip('Mecca', settings.isBangla ? 'মক্কা' : 'Mecca', settings),
                const SizedBox(width: 8),
                _buildFilterChip('Medinan', settings.isBangla ? 'মদিনা' : 'Medinan', settings),
              ],
            ),
          ),
        ),

        // Last Read Banner
        Obx(() {
          final lr = controller.lastRead.value;
          if (lr == null) return const SizedBox.shrink();
          final isDark = settings.isDark;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_QViewTheme.emeraldDark, _QViewTheme.emerald],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _QViewTheme.gold.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _QViewTheme.emerald.withOpacity(0.3),
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
                    opacity: 0.1,
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 130,
                      color: _QViewTheme.goldLight,
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
                          const Icon(
                            Icons.history_toggle_off_rounded,
                            color: _QViewTheme.goldLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            settings.isBangla ? 'সর্বশেষ পঠিত' : 'Last Read',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lr.surahName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${settings.isBangla ? "আয়াত নং" : "Ayah No"}: ${lr.ayahNumber}',
                        style: GoogleFonts.poppins(
                          color: _QViewTheme.goldSoft,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          backgroundColor: _QViewTheme.gold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          settings.isBangla ? 'পড়া চালিয়ে যান' : 'Resume Reading',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
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
              return ShimmerList(
                itemCount: 8,
                height: 70,
                spacing: 12,
              );
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.filteredSurahList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final surah = controller.filteredSurahList[index];
                final isDark = settings.isDark;
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? _QViewTheme.darkCard : _QViewTheme.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? _QViewTheme.emerald.withOpacity(0.15) : _QViewTheme.emerald.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? _QViewTheme.emerald.withOpacity(0.15) : _QViewTheme.goldSoft,
                        shape: BoxShape.circle,
                        border: Border.all(color: _QViewTheme.gold, width: 1.5),
                      ),
                      child: Text(
                        surah.number.toString(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: _QViewTheme.emerald,
                        ),
                      ),
                    ),
                    title: Text(
                      surah.englishName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      '${settings.isBangla ? (surah.revelationType.toLowerCase().contains("meccan") ? "মক্কা" : "মদিনা") : surah.revelationType} • ${surah.numberOfAyahs} ${settings.isBangla ? "আয়াত" : "Ayahs"}',
                      style: GoogleFonts.poppins(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          surah.name,
                          style: GoogleFonts.amiri(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _QViewTheme.gold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _QViewTheme.emerald,
                          size: 20,
                        ),
                      ],
                    ),
                    onTap: () => Get.toNamed(
                      AppRoutes.surahDetails,
                      arguments: {
                        'surahNumber': surah.number,
                        'surahName': surah.englishName,
                      },
                    ),
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
    final bn = settings.isBangla;
    final isDark = settings.isDark;

    return Column(
      children: [
        // Information Banner Card
        GestureDetector(
          onTap: () => _showJuzInfoDialog(context, settings),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_QViewTheme.emeraldDark, _QViewTheme.emerald],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _QViewTheme.gold.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: _QViewTheme.emerald.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: _QViewTheme.goldLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bn ? 'পারা বা জুজ (Juz) কী?' : 'What is Juz / Para?',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bn ? 'বিস্তারিত জানতে এখানে স্পর্শ করুন' : 'Tap here to learn details',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _QViewTheme.goldLight,
                  size: 14,
                ),
              ],
            ),
          ),
        ),

        // Para List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: controller.paraList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final para = controller.paraList[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? _QViewTheme.darkCard : _QViewTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? _QViewTheme.emerald.withOpacity(0.15) : _QViewTheme.emerald.withOpacity(0.06),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? _QViewTheme.emerald.withOpacity(0.15) : _QViewTheme.goldSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: _QViewTheme.gold, width: 1.5),
                    ),
                    child: Text(
                      para.number.toString(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: _QViewTheme.emerald,
                      ),
                    ),
                  ),
                  title: Text(
                    bn ? para.nameBn : para.nameMeaning,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    '${settings.isBangla ? "শুরু" : "Starts at"} ${settings.isBangla ? "সূরা" : "Surah"} ${para.startSurah}:${para.startAyah}',
                    style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        para.name,
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _QViewTheme.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: _QViewTheme.emerald, size: 20),
                    ],
                  ),
                  onTap: () => Get.toNamed(
                    AppRoutes.paraDetails,
                    arguments: {
                      'paraNumber': para.number,
                      'paraName': bn ? para.nameBn : para.nameMeaning,
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarksTab(BuildContext context, SettingsController settings) {
    return Obx(() {
      final isDark = settings.isDark;
      if (controller.bookmarkList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bookmark_outline_rounded,
                size: 64,
                color: _QViewTheme.emerald,
              ),
              const SizedBox(height: 16),
              Text(
                settings.isBangla ? 'কোনো বুকমার্ক সংরক্ষিত নেই' : 'No bookmarks saved',
                style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 16),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.bookmarkList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bookmark = controller.bookmarkList[index];
          return Container(
            decoration: BoxDecoration(
              color: isDark ? _QViewTheme.darkCard : _QViewTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? _QViewTheme.emerald.withOpacity(0.15) : _QViewTheme.emerald.withOpacity(0.06),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _QViewTheme.emerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${bookmark.surahName} [${bookmark.surahNumber}:${bookmark.ayahNumber}]',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _QViewTheme.emerald,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () => controller.removeBookmark(
                        bookmark.surahNumber,
                        bookmark.ayahNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.surahDetails,
                    arguments: {
                      'surahNumber': bookmark.surahNumber,
                      'surahName': bookmark.surahName,
                      'initialAyah': bookmark.ayahNumber,
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? _QViewTheme.darkSurface : _QViewTheme.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bookmark.ayahText,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _QViewTheme.gold,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildFilterChip(String filterType, String label, SettingsController settings) {
    return Obx(() {
      final isSelected = controller.selectedTypeFilter.value == filterType;
      final isDark = settings.isDark;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.setTypeFilter(filterType),
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.white : (isDark ? AppColors.textGrey : AppColors.textDark),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        selectedColor: _QViewTheme.emerald,
        backgroundColor: isDark ? _QViewTheme.darkCard : _QViewTheme.lightCard,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? _QViewTheme.emerald : (isDark ? _QViewTheme.emerald.withOpacity(0.15) : _QViewTheme.emerald.withOpacity(0.06)),
            width: 0.5,
          ),
        ),
      );
    });
  }

  void _showJuzInfoDialog(BuildContext context, SettingsController settings) {
    final bn = settings.isBangla;
    final isDark = settings.isDark;

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? _QViewTheme.darkCard : _QViewTheme.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? _QViewTheme.emerald.withOpacity(0.15) : _QViewTheme.emerald.withOpacity(0.06),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _QViewTheme.emerald.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: _QViewTheme.emerald,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bn ? 'পারা বা জুজ (Juz) কী?' : 'What is Juz / Para?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                bn
                    ? "আরবি শব্দ 'জুজ' (জুজ' - অংশ)-এর অর্থ হলো 'অংশ' বা 'ভাগ'। অন্যদিকে ফারসি ও উর্দুতে একে 'পারা' বলা হয়।\n\nপবিত্র কুরআনকে পড়ার সুবিধার্থে ৩০টি সমদৈর্ঘ্যের অংশে ভাগ করা হয়েছে। প্রতিটি অংশকে একেকটি পারা বা জুজ বলা হয়। এই বিভাজনের মূল উদ্দেশ্য হলো যাতে একজন পাঠক ৩০ দিনে (যেমন পবিত্র রমজান মাসে প্রতিদিন ১ পারা করে) পুরো কুরআন তিলাওয়াত সম্পন্ন করতে পারেন।"
                    : "The Arabic word 'Juz' literally means 'part' or 'portion'. In South Asia, it is commonly referred to as 'Para'.\n\nThe Holy Quran is divided into 30 parts of roughly equal length. Each part is called a Juz or Para. This division was created to facilitate systematic reading and recitation, allowing a reader to easily complete the entire Quran in 30 days (such as reciting one Juz daily during the holy month of Ramadan).",
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  height: 1.6,
                  color: isDark ? AppColors.textGrey : AppColors.textDark.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _QViewTheme.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    bn ? 'ঠিক আছে' : 'Got it',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Islamic Star / Geometric Pattern Painter ──────────────────────────────────
class _StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const step = 32.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar6(canvas, paint, Offset(x, y), 9);
      }
    }
  }

  void _drawStar6(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (3.14159 / 180);
      final radius = i.isEven ? r : r * 0.45;
      final point = Offset(
        center.dx + radius * _cos(angle),
        center.dy + radius * _sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double rad) => rad == 0
      ? 1
      : (rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120);
  double _sin(double rad) =>
      rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120;

  @override
  bool shouldRepaint(_StarPatternPainter old) => false;
}
