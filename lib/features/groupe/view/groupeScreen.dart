import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/groupe/controller/group_controller.dart';
import 'package:educonnect/features/groupe/model/group_model.dart';
import 'package:educonnect/features/groupe/widgets/group_card.dart';
import 'package:educonnect/widgets/customText.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:educonnect/features/groupe/view/group_detail_screen.dart';
import 'package:educonnect/features/groupe/view/create_group_screen.dart';

class GroupeScreen extends StatelessWidget {
  const GroupeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GroupController controller = Get.put(GroupController());

    return Obx(() {
      if (controller.isInGroup.value && controller.currentGroup.value != null) {
        return GroupDetailScreen(
          groupId: controller.currentGroup.value!.id,
        );
      }

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: ColorManager.lightGrey3,
          appBar: AppBar(
            backgroundColor: ColorManager.primaryColor,
            title: Text('Groupes', style: TextStyle(color: ColorManager.white)),
            iconTheme: IconThemeData(color: ColorManager.white),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(FeatherIcons.filter),
                onPressed: controller.showFilterOptions,
              ),
              IconButton(
                icon: Icon(FeatherIcons.users),
                tooltip: 'Groupes par filière',
                onPressed: () => Get.toNamed('/majorGroups'),
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Tous les groupes'),
                Tab(text: 'Mes groupes'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorManager.primaryColor,
            onPressed: () => Get.to(() => CreateGroupScreen()),
            child: const Icon(Icons.add, color: ColorManager.white),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  onChanged: controller.searchGroups,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un groupe...',
                    prefixIcon:
                        Icon(FeatherIcons.search, color: ColorManager.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    hintStyle: TextStyle(color: ColorManager.grey),
                  ),
                ),
              ),

              // Category filter
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    _buildCategoryChip(controller, 'Tous'),
                    _buildCategoryChip(controller, 'Académique'),
                    _buildCategoryChip(controller, 'Technique'),
                    _buildCategoryChip(controller, 'Culturel'),
                    _buildCategoryChip(controller, 'Social'),
                  ],
                ),
              ),

              // Group lists
              Expanded(
                child: TabBarView(
                  children: [
                    // All groups tab
                    _buildGroupsListView(
                      controller,
                      controller.isSearching.value
                          ? 'Résultats pour "${controller.searchQuery.value}"'
                          : controller.selectedCategory.value == 'Tous'
                              ? 'Tous les groupes'
                              : 'Groupes - ${controller.selectedCategory.value}',
                      controller.groups,
                    ),

                    // My groups tab
                    _buildGroupsListView(
                      controller,
                      'Mes groupes',
                      controller.myGroups,
                      showEmptyMessage:
                          'Vous n\'avez pas encore rejoint de groupe',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryChip(GroupController controller, String category) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ChoiceChip(
          label: Text(category),
          selected: isSelected,
          backgroundColor: ColorManager.white,
          selectedColor: ColorManager.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? ColorManager.white : ColorManager.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            if (selected) {
              controller.filterByCategory(category);
            }
          },
        ),
      );
    });
  }

  Widget _buildGroupsListView(
    GroupController controller,
    String title,
    List<GroupModel> groups, {
    String showEmptyMessage = 'Aucun groupe trouvé',
  }) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (groups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FeatherIcons.users, size: 50, color: ColorManager.grey),
              const Gap(10),
              Text(
                showEmptyMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.grey,
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(15),
        children: [
          customText(
            text: title,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(15),
          ...groups.map((group) {
            // Check if user is a member of this group
            final isMember =
                controller.myGroups.any((myGroup) => myGroup.id == group.id);

            return GroupCard(
              group: group,
              isMember: isMember,
              onTap: () => controller.openGroup(group.id),
              onJoin: isMember
                  ? () {} // Already a member, no action needed
                  : () => controller.joinGroup(group.id),
            );
          }).toList(),
        ],
      );
    });
  }
}
