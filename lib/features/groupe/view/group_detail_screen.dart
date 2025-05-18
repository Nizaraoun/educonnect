import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/chat/controller/ChatController.dart';
import 'package:educonnect/features/chat/view/group_chat_screen.dart';
import 'package:educonnect/features/groupe/controller/group_controller.dart';
import 'package:educonnect/features/groupe/model/group_model.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();

    // Make sure ChatController is registered
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }

    // Load the group data when the screen is built
    groupController.openGroup(groupId);

    return Scaffold(
      backgroundColor: ColorManager.scaffoldbg,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ColorManager.white),
        centerTitle: true,
        backgroundColor: ColorManager.primaryColor,
        elevation: 0,
        title: Obx(() => Text(
            groupController.currentGroup.value?.name ?? 'Détails du groupe',
            style: TextStyle(color: ColorManager.white))),
        leading: IconButton(
          icon: Icon(FeatherIcons.arrowLeft),
          onPressed: () {
            Get.back();
            groupController.exitGroup();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.moreVertical),
            onPressed: () {
              _showGroupOptions(context, groupController);
            },
          ),
        ],
      ),
      body: Obx(() {
        final group = groupController.currentGroup.value;
        if (group == null) {
          return Center(child: Text('Groupe non trouvé'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupHeader(group, groupController),
              _buildGroupBody(group, groupController, context),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (!groupController.isInGroup.value) return SizedBox();
        return FloatingActionButton(
          backgroundColor: ColorManager.blueprimaryColor,
          child: Icon(FeatherIcons.plus, color: Colors.white),
          onPressed: () {
            _showActionOptions(context, groupController);
          },
        );
      }),
    );
  }

  Widget _buildGroupHeader(GroupModel group, GroupController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorManager.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group image and info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  image: group.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(group.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: group.imageUrl.isEmpty
                    ? Center(
                        child: Icon(
                          FeatherIcons.users,
                          color: ColorManager.primaryColor,
                          size: 40,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ColorManager.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        group.category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    // Group name
                    Text(
                      group.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    // Member count
                    Row(
                      children: [
                        Icon(
                          FeatherIcons.users,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${group.memberCount} membres',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    // Creator info
                    Row(
                      children: [
                        Icon(
                          FeatherIcons.user,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Créé par ${group.creatorName}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          // Group description
          Text(
            group.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          SizedBox(height: 20),
          // Join/Leave group button
          Obx(() => _buildJoinLeaveButton(controller)),
        ],
      ),
    );
  }

  Widget _buildJoinLeaveButton(GroupController controller) {
    final isInGroup = controller.isInGroup.value;
    final group = controller.currentGroup.value;

    if (group == null) return SizedBox();

    return InkWell(
      onTap: () {
        if (isInGroup) {
          _showLeaveGroupDialog(Get.context!, controller, group.id);
        } else {
          controller.joinGroup(group.id);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isInGroup ? Colors.redAccent : ColorManager.blueprimaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            isInGroup ? 'Quitter le groupe' : 'Rejoindre le groupe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupBody(
      GroupModel group, GroupController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs for different sections
          Obx(() {
            if (!controller.isInGroup.value) {
              // Show limited view for non-members
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('À propos de ce groupe'),
                  _buildAboutSection(group),
                ],
              );
            }

            // Show full view for members
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Annonces récentes'),
                _buildAnnouncementsSection(controller),
                Gap(20),
                _buildSectionTitle('Chat de groupe'),
                _buildChatSection(group, controller),
                Gap(20),
                _buildSectionTitle('Sessions de révision'),
                _buildRevisionGroupsSection(controller),
                Gap(20),
                _buildSectionTitle('Membres'),
                _buildMembersSection(group),
                Gap(20),
                _buildSectionTitle('À propos de ce groupe'),
                _buildAboutSection(group),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorManager.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection(GroupController controller) {
    return Obx(() {
      if (controller.announcements.isEmpty) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Aucune annonce pour le moment.',
              style: TextStyle(
                color: ColorManager.grey,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      return Column(
        children: controller.announcements.map((announcement) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ColorManager.lightBlue.withOpacity(0.2),
                      child: Icon(
                        FeatherIcons.messageCircle,
                        color: ColorManager.blueprimaryColor,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Par ${announcement.authorName} • ${_formatDate(announcement.createdAt)}',
                            style: TextStyle(
                              color: ColorManager.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  announcement.content,
                  style: TextStyle(fontSize: 14),
                ),
                if (announcement.attachments.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: announcement.attachments.map((attachment) {
                      return Chip(
                        backgroundColor: ColorManager.clouds1,
                        label: Text(
                          _getFileName(attachment),
                          style: TextStyle(fontSize: 12),
                        ),
                        avatar: Icon(
                          FeatherIcons.paperclip,
                          size: 14,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildRevisionGroupsSection(GroupController controller) {
    return Obx(() {
      if (controller.revisionGroups.isEmpty) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Aucune session de révision planifiée.',
              style: TextStyle(
                color: ColorManager.grey,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      return Column(
        children: controller.revisionGroups.map((revisionGroup) {
          final bool isUserMember = revisionGroup.memberIds
              .contains(controller.currentGroup.value?.creatorId ?? '');

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorManager.green.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.calendar,
                        color: ColorManager.green,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          revisionGroup.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: ColorManager.SoftBlack,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ColorManager.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          revisionGroup.subject,
                          style: TextStyle(
                            color: ColorManager.darkGreen,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        revisionGroup.description,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 15),
                      // Session details
                      _buildRevisionSessionDetail(
                        icon: FeatherIcons.clock,
                        title: 'Date et heure',
                        detail:
                            '${_formatDate(revisionGroup.meetingDate)} • ${revisionGroup.meetingTime}',
                      ),
                      _buildRevisionSessionDetail(
                        icon: FeatherIcons.mapPin,
                        title: 'Lieu',
                        detail: revisionGroup.meetingLocation,
                      ),
                      _buildRevisionSessionDetail(
                        icon: FeatherIcons.users,
                        title: 'Participants',
                        detail: '${revisionGroup.memberCount} participants',
                      ),
                      SizedBox(height: 10),
                      // Join button
                      InkWell(
                        onTap: () {
                          if (isUserMember) {
                            controller.leaveRevisionGroup(revisionGroup.id);
                          } else {
                            controller.joinRevisionGroup(revisionGroup.id);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isUserMember
                                ? Colors.redAccent
                                : ColorManager.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              isUserMember
                                  ? 'Quitter la session'
                                  : 'Rejoindre la session',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildRevisionSessionDetail({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: ColorManager.grey,
            size: 16,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(GroupModel group) {
    // In a real app, you would fetch the member details from Firestore
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${group.memberCount} membres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  // View all members
                },
                child: Text('Voir tous'),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Member avatars - using a Row instead of Stack for better layout
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(
                  min(5, group.memberIds.length),
                  (index) => Container(
                    margin: EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: ColorManager.primaryColor,
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                if (group.memberIds.length > 5)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorManager.lightGrey,
                    child: Text(
                      '+${group.memberIds.length - 5}',
                      style: TextStyle(color: ColorManager.primaryColor),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(GroupModel group) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutDetail(
            icon: FeatherIcons.calendar,
            title: 'Créé le',
            detail: _formatDate(group.createdAt),
          ),
          _buildAboutDetail(
            icon: FeatherIcons.activity,
            title: 'Dernière activité',
            detail: _formatDate(group.lastActivity),
          ),
          _buildAboutDetail(
            icon: FeatherIcons.lock,
            title: 'Visibilité',
            detail: group.isPublic ? 'Public' : 'Privé',
          ),
          _buildAboutDetail(
            icon: FeatherIcons.user,
            title: 'Créateur',
            detail: group.creatorName,
          ),
          _buildAboutDetail(
            icon: FeatherIcons.tag,
            title: 'Catégorie',
            detail: group.category,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutDetail({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorManager.clouds1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: ColorManager.primaryColor,
              size: 16,
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(BuildContext context, GroupController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Options du groupe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            if (controller.isCurrentUserAdmin())
              _buildOptionTile(
                icon: FeatherIcons.userPlus,
                title: 'Ajouter par code d\'invitation',
                onTap: () {
                  Navigator.pop(context);
                  _showAddUserByCodeDialog(context, controller);
                },
              ),
            _buildOptionTile(
              icon: FeatherIcons.messageCircle,
              title: 'Aller au chat du groupe',
              onTap: () {
                Navigator.pop(context);
                if (controller.currentGroup.value != null &&
                    controller.currentGroup.value!.hasChat) {
                  _navigateToGroupChat(controller.currentGroup.value!);
                } else {
                  Get.snackbar(
                    'Chat désactivé',
                    'Le chat n\'est pas activé pour ce groupe',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
            _buildOptionTile(
              icon: FeatherIcons.share2,
              title: 'Partager le groupe',
              onTap: () {
                Navigator.pop(context);
                // Share functionality
              },
            ),
            _buildOptionTile(
              icon: FeatherIcons.alertCircle,
              title: 'Signaler le groupe',
              onTap: () {
                Navigator.pop(context);
                // Report functionality
              },
            ),
            if (controller.isInGroup.value) ...[
              _buildOptionTile(
                icon: FeatherIcons.logOut,
                title: 'Quitter le groupe',
                onTap: () {
                  Navigator.pop(context);
                  _showLeaveGroupDialog(
                    context,
                    controller,
                    controller.currentGroup.value?.id ?? '',
                  );
                },
                color: Colors.redAccent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showActionOptions(BuildContext context, GroupController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Créer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildOptionTile(
              icon: FeatherIcons.messageCircle,
              title: 'Nouvelle annonce',
              onTap: () {
                Navigator.pop(context);
                _showNewAnnouncementDialog(
                  context,
                  controller,
                  controller.currentGroup.value?.id ?? '',
                );
              },
            ),
            _buildOptionTile(
              icon: FeatherIcons.messageSquare,
              title: 'Ouvrir le chat',
              onTap: () {
                Navigator.pop(context);
                if (controller.currentGroup.value != null &&
                    controller.currentGroup.value!.hasChat) {
                  _navigateToGroupChat(controller.currentGroup.value!);
                } else {
                  Get.snackbar(
                    'Chat désactivé',
                    'Le chat n\'est pas activé pour ce groupe',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
            _buildOptionTile(
              icon: FeatherIcons.calendar,
              title: 'Nouvelle session de révision',
              onTap: () {
                Navigator.pop(context);
                _showNewRevisionSessionDialog(
                  context,
                  controller,
                  controller.currentGroup.value?.id ?? '',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? ColorManager.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? ColorManager.SoftBlack,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLeaveGroupDialog(
    BuildContext context,
    GroupController controller,
    String groupId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quitter le groupe'),
        content: Text(
          'Êtes-vous sûr de vouloir quitter ce groupe ? Vous ne pourrez plus accéder à son contenu sans rejoindre à nouveau.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.leaveGroup(groupId);
            },
            child: Text(
              'Quitter',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewAnnouncementDialog(
    BuildContext context,
    GroupController controller,
    String groupId,
  ) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle annonce'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (titleController.text.trim().isNotEmpty &&
                  contentController.text.trim().isNotEmpty) {
                controller.createGroupAnnouncement(
                  groupId: groupId,
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                );
              }
            },
            child: Text('Publier'),
          ),
        ],
      ),
    );
  }

  void _showNewRevisionSessionDialog(
    BuildContext context,
    GroupController controller,
    String groupId,
  ) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController maxMembersController =
        TextEditingController(text: "20"); // Default max members is 20

    DateTime selectedDate = DateTime.now().add(Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle session de révision'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la session',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 15),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Matière',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                      }
                    },
                    child: Text('Choisir'),
                  ),
                ],
              ),
              SizedBox(height: 15),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Heure (ex: 14:00 - 16:00)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: maxMembersController,
                decoration: InputDecoration(
                  labelText: 'Nombre maximum de participants',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 20',
                  helperText:
                      'Limite le nombre de personnes pouvant participer',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (nameController.text.trim().isNotEmpty &&
                  descriptionController.text.trim().isNotEmpty &&
                  subjectController.text.trim().isNotEmpty &&
                  locationController.text.trim().isNotEmpty &&
                  timeController.text.trim().isNotEmpty &&
                  maxMembersController.text.trim().isNotEmpty) {
                // Parse the max members, defaulting to 20 if invalid
                int maxMembers = 20;
                try {
                  maxMembers = int.parse(maxMembersController.text.trim());
                  // Ensure a reasonable limit
                  if (maxMembers <= 0) maxMembers = 1;
                  if (maxMembers > 100) maxMembers = 100;
                } catch (e) {
                  // Default to 20 if parsing fails
                }

                controller.createStudySession(
                  parentGroupId: groupId,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  subject: subjectController.text.trim(),
                  meetingDate: selectedDate,
                  meetingTime: timeController.text.trim(),
                  meetingLocation: locationController.text.trim(),
                  maxMembers: maxMembers, // Pass the max members limit
                );
              }
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showAddUserByCodeDialog(
    BuildContext context,
    GroupController controller,
  ) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez le code d\'invitation personnel de l\'utilisateur pour l\'ajouter au groupe',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 15),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Code d\'invitation',
                border: OutlineInputBorder(),
                hintText: 'Ex: AB12CD',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                // Call the controller method to add user by invitation code
                controller.addUserByInvitationCode(
                  controller.currentGroup.value?.id ?? '',
                  code,
                );
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String _getFileName(String url) {
    final Uri uri = Uri.parse(url);
    final String path = uri.path;
    return path.substring(path.lastIndexOf('/') + 1);
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }

  Widget _buildMissingIndexMessage() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            FeatherIcons.alertTriangle,
            color: Colors.orange,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration requise',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cette fonctionnalité nécessite des index dans Firebase. Veuillez consulter la console de développement pour créer les index manquants.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection(GroupModel group, GroupController controller) {
    return GestureDetector(
      onTap: () {
        if (group.hasChat) {
          // Make sure ChatController is registered
          if (!Get.isRegistered<ChatController>()) {
            Get.put(ChatController());
          }
          _navigateToGroupChat(group);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorManager.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                FeatherIcons.messageCircle,
                color: ColorManager.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat du groupe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Discuter avec les autres membres',
                    style: TextStyle(
                      color: ColorManager.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.blueprimaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FeatherIcons.arrowRight,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGroupChat(GroupModel group) {
    if (!group.hasChat) {
      Get.snackbar(
        'Chat désactivé',
        'Le chat n\'est pas activé pour ce groupe',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Make sure ChatController is registered
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }

    // Use the group ID as forum ID since they are the same
    Get.to(
      () => GroupChatScreen(
        forumId: group.id,
        groupName: group.name,
      ),
    );
  }
}
