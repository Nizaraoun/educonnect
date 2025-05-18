import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import '../../../../core/themes/color_mangers.dart';
import '../../../../widgets/custom_text.dart';
import 'statistics_widgets.dart';

class StatisticsTab extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic> statsData;
  final Color Function(String) getColorFromHex;

  const StatisticsTab({
    Key? key,
    required this.isLoading,
    required this.statsData,
    required this.getColorFromHex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: ColorManager.primaryColor,
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: 'Résumé',
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.SoftBlack,
                  ),
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatCard(
                      icon: FeatherIcons.bookOpen,
                      value: '${statsData['totalCourses']}',
                      label: 'Cours',
                      color: ColorManager.primaryColor,
                    ),
                    StatCard(
                      icon: FeatherIcons.fileText,
                      value: '${statsData['totalDocuments']}',
                      label: 'Documents',
                      color: ColorManager.blueprimaryColor,
                    ),
                    StatCard(
                      icon: FeatherIcons.users,
                      value: '${statsData['totalStudents']}',
                      label: 'Étudiants',
                      color: ColorManager.green,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Gap(24),

          // Course Activity
          customText(
            text: 'Activité par cours (7 derniers jours)',
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorManager.SoftBlack,
            ),
          ),
          Gap(16),

          _buildActivitySection(),

          Gap(24),

          // Document Downloads
          customText(
            text: 'Documents les plus téléchargés',
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorManager.SoftBlack,
            ),
          ),
          Gap(16),

          _buildPopularDocumentsSection(),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < (statsData['courseActivity'] as List).length; i++)
            ActivityBar(
              title: statsData['courseActivity'][i]['title'],
              code: statsData['courseActivity'][i]['code'],
              value: statsData['courseActivity'][i]['activity'],
              color: getColorFromHex(statsData['courseActivity'][i]['color']),
              count: statsData['courseActivity'][i]['count'].toString(),
              isLast: i == (statsData['courseActivity'] as List).length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildPopularDocumentsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var document in (statsData['popularDocuments'] as List))
            PopularDocumentItem(
              title: document['title'],
              type: document['type'],
              course: document['courseCode'],
              downloads: document['downloads'],
              color: getColorFromHex(document['color']),
            ),
        ],
      ),
    );
  }
}
