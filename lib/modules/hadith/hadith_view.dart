import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'hadith_controller.dart';
import '../../core/constants/app_routes.dart';

class HadithView extends GetView<HadithController> {
  const HadithView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final bn = settings.isBangla;
      final isDark = settings.isDark;

      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: const AppBackButton(),
          elevation: 0,
          title: Text(
            bn ? 'হাদিস' : 'Hadith',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            // Books Selection
            if (controller.selectedBook.value == null)
              Expanded(
                child: controller.isLoadingBooks.value
                    ? const Center(child: CircularProgressIndicator())
                    : _buildBookList(settings),
              )
            else
              Expanded(
                child: _buildHadithList(settings),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildBookList(SettingsController settings) {
    final isDark = settings.isDark;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.books.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = controller.books[index];
        return InkWell(
          onTap: () => controller.selectBook(book),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.book, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${book.available} ${settings.isBangla ? "টি হাদিস" : "Hadiths"}',
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textGrey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHadithList(SettingsController settings) {
    final isDark = settings.isDark;
    final book = controller.selectedBook.value!;

    return Column(
      children: [
        // Selected Book Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.selectedBook.value = null,
              ),
              Expanded(
                child: Text(
                  book.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Hadith List
        Expanded(
          child: Obx(() {
            if (controller.hadiths.isEmpty && controller.isLoadingHadiths.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: controller.hadiths.length + (controller.isLoadingHadiths.value ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == controller.hadiths.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final hadith = controller.hadiths[index];
                return InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.hadithDetail,
                    arguments: {
                      'bookId': book.id,
                      'bookName': book.name,
                      'hadith': hadith,
                    },
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${settings.isBangla ? "হাদিস নং" : "Hadith"} ${hadith.number}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hadith.arab,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri', // Assuming you have this or similar font
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hadith.id,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? AppColors.textGrey : AppColors.textDark,
                          ),
                        ),
                      ],
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
}
