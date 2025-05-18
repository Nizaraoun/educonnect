import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import '../../../core/themes/color_mangers.dart';
import '../../../core/themes/string_manager.dart';
import '../../../widgets/customtext.dart';
import '../../../widgets/text/custom_text.dart';
import '../controller/revision_controller.dart';
import '../model/revision_model.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({Key? key}) : super(key: key);

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _typeTabController;
  final RevisionController controller = Get.put(RevisionController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _typeTabController = TabController(length: 2, vsync: this);
    controller.tabController = _tabController;
    controller.typeTabController = _typeTabController;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            controller.filterByStatus('En cours');
            break;
          case 1:
            controller.filterByStatus('Terminé');
            break;
        }
      }
    });

    _typeTabController.addListener(() {
      if (!_typeTabController.indexIsChanging) {
        switch (_typeTabController.index) {
          case 0:
            controller.toggleRevisionType('Privé');
            break;
          case 1:
            controller.toggleRevisionType('Public');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _typeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: ColorManager.primaryColor,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.arrow_back, color: ColorManager.primaryColor),
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorManager.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(FeatherIcons.pieChart,
                        color: ColorManager.primaryColor),
                  ),
                  onPressed: () {
                    // Show stats
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorManager.primaryColor,
                        ColorManager.darkPrimary,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.2,
                          child: Image.asset(
                            'assets/images/card_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Header content
                      Positioned(
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(
                              txt: '     Révisions',
                              color: ColorManager.white,
                              size: 32,
                              fontweight: FontWeight.bold,
                              spacing: 0.0,
                            ),
                            const Gap(10),
                            const CustomText(
                              spacing: 0.0,
                              txt:
                                  'Organisez vos sessions de révision et suivez votre progression',
                              color: ColorManager.white,
                              size: 16,
                              fontweight: FontWeight.w400,
                            ),
                            Gap(30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Column(
                  children: [
                    // Public/Private Tabs
                    TabBar(
                      controller: _typeTabController,
                      indicatorColor: ColorManager.white,
                      indicatorWeight: 3,
                      labelColor: ColorManager.white,
                      unselectedLabelColor: ColorManager.white.withOpacity(0.7),
                      tabs: const [
                        Tab(text: 'Privé'),
                        Tab(text: 'Public'),
                      ],
                    ),
                    // Status Tabs
                    TabBar(
                      controller: _tabController,
                      indicatorColor: ColorManager.white,
                      indicatorWeight: 3,
                      labelColor: ColorManager.white,
                      unselectedLabelColor: ColorManager.white.withOpacity(0.7),
                      tabs: const [
                        Tab(text: 'En cours'),
                        Tab(text: 'Terminé'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // À faire tab
            // En cours tab
            _buildRevisionList('En cours'),
            // Terminé tab
            _buildRevisionList('Terminé'),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        // Different FAB for public vs private revisions
        if (controller.selectedTypeTab.value == 'Public') {
          return FloatingActionButton.extended(
            onPressed: () => _showCreatePublicRevisionDialog(context),
            backgroundColor: ColorManager.blueprimaryColor,
            elevation: 4,
            icon: const Icon(Icons.public, color: ColorManager.white),
            label: const Text('Créer une révision publique',
                style: TextStyle(color: ColorManager.white)),
          );
        } else {
          return SizedBox
              .shrink(); // Return an empty widget for private revisions
        }
      }),
    );
  }

  Widget _buildRevisionList(String status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Use the getAllRevisions method to get both personal and group revisions
      final filteredRevisions = controller.getAllRevisions(status);

      if (filteredRevisions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getEmptyStateIcon(status),
                size: 60,
                color: ColorManager.grey,
              ),
              const Gap(20),
              CustomText(
                txt: _getEmptyStateMessage(
                    status, controller.selectedTypeTab.value),
                color: ColorManager.grey,
                size: 16,
                fontweight: FontWeight.w400,
                spacing: 0.0,
              ),
              if (controller.selectedTypeTab.value == 'Public')
                ElevatedButton.icon(
                  onPressed: () => _showCreatePublicRevisionDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Créer une révision publique'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    foregroundColor: ColorManager.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject filters
            // Uncomment if you want to add subject filters
            /*
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSubjectChip('Tous', controller.currentFilter.value == 'Tous'),
                  _buildSubjectChip('Informatique', controller.currentFilter.value == 'Informatique'),
                  _buildSubjectChip('Mathématiques', controller.currentFilter.value == 'Mathématiques'),
                  _buildSubjectChip('Physique', controller.currentFilter.value == 'Physique'),
                  _buildSubjectChip('Histoire', controller.currentFilter.value == 'Histoire'),
                  _buildSubjectChip('Anglais', controller.currentFilter.value == 'Anglais'),
                ],
              ),
            ),
            */
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(
                  text: '$status (${filteredRevisions.length})',
                  textStyle: StylesManager.headline2,
                ),
                if (controller.selectedTypeTab.value == 'Public')
                  TextButton.icon(
                    onPressed: () => _showCreatePublicRevisionDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nouvelle révision'),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorManager.primaryColor,
                    ),
                  ),
              ],
            ),
            const Gap(15),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRevisions.length,
                itemBuilder: (context, index) {
                  final revision = filteredRevisions[index];
                  // Check if this revision is from a group
                  final isGroupRevision = controller.groupRevisions
                      .any((gr) => gr.id == revision.id);

                  // Determine if it's a public revision
                  final isPublicRevision =
                      controller.selectedTypeTab.value == 'Public';

                  return _buildRevisionCard(
                      revision, isGroupRevision, isPublicRevision);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubjectChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => controller.filterBySubject(label),
        borderRadius: BorderRadius.circular(20),
        child: Chip(
          label: Text(label),
          labelStyle: TextStyle(
            color: isSelected ? ColorManager.white : ColorManager.darkGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor:
              isSelected ? ColorManager.primaryColor : ColorManager.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: isSelected ? 2 : 0,
        ),
      ),
    );
  }

  Widget _buildRevisionCard(
      RevisionModel revision, bool isGroupRevision, bool isPublicRevision) {
    // Calculate priority color
    Color priorityColor;
    switch (revision.priority) {
      case 3:
        priorityColor = ColorManager.error;
        break;
      case 2:
        priorityColor = ColorManager.amber;
        break;
      default:
        priorityColor = ColorManager.greenbtn2;
    }

    // Calculate days left
    final daysLeft = revision.deadlineDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorManager.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority indicator
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and subject
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomText(
                                  txt: revision.title,
                                  color: ColorManager.black,
                                  size: 18,
                                  fontweight: FontWeight.bold,
                                  spacing: 0.0,
                                ),
                              ),
                              if (isGroupRevision)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ColorManager.primaryColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FeatherIcons.users,
                                        size: 12,
                                        color: ColorManager.primaryColor,
                                      ),
                                      const Gap(4),
                                      CustomText(
                                        txt: 'Groupe',
                                        color: ColorManager.primaryColor,
                                        size: 12,
                                        fontweight: FontWeight.w500,
                                        spacing: 0.0,
                                      ),
                                    ],
                                  ),
                                ),
                              if (isPublicRevision)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ColorManager.blueprimaryColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.public,
                                        size: 12,
                                        color: ColorManager.blueprimaryColor,
                                      ),
                                      const Gap(4),
                                      CustomText(
                                        txt: 'Public',
                                        color: ColorManager.blueprimaryColor,
                                        size: 12,
                                        fontweight: FontWeight.w500,
                                        spacing: 0.0,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ColorManager.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CustomText(
                                  txt: revision.subject,
                                  color: const Color.fromARGB(255, 8, 136, 115),
                                  size: 12,
                                  fontweight: FontWeight.w500,
                                  spacing: 0.0,
                                ),
                              ),
                              const Gap(10),
                              Icon(
                                FeatherIcons.clock,
                                size: 12,
                                color: ColorManager.grey,
                              ),
                              const Gap(5),
                              CustomText(
                                txt: revision.duration,
                                color: ColorManager.grey,
                                size: 12,
                                fontweight: FontWeight.w500,
                                spacing: 0.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Completion indicator for "En cours" items
                    if (revision.status == 'En cours')
                      CircularPercentIndicator(
                        radius: 25,
                        lineWidth: 5,
                        percent: isPublicRevision
                            ? revision.saturationPercentage / 100
                            : revision.completionPercentage / 100,
                        center: Text(
                          isPublicRevision
                              ? '${revision.saturationPercentage}%'
                              : '${revision.completionPercentage}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                        progressColor: isPublicRevision
                            ? _getSaturationColor(revision.saturationPercentage)
                            : _getCompletionColor(
                                revision.completionPercentage),
                        backgroundColor: ColorManager.grey3,
                      ),
                    // Checkmark for "Terminé" items
                    if (revision.status == 'Terminé')
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: ColorManager.greenbtn2.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: ColorManager.greenbtn2,
                          size: 30,
                        ),
                      ),
                  ],
                ),
                const Gap(15),
                // Description
                CustomText(
                  txt: revision.description,
                  color: ColorManager.darkGrey,
                  size: 14,
                  fontweight: FontWeight.w400,
                  spacing: 0.0,
                ),
                const Gap(15),
                // Tags/Topics
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: revision.topics
                      .map((topic) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorManager.lightGrey3,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              topic,
                              style: TextStyle(
                                color: ColorManager.darkGrey,
                                fontSize: 12,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const Gap(15),
                // Due date and action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FeatherIcons.calendar,
                          size: 16,
                          color:
                              isOverdue ? ColorManager.red : ColorManager.grey,
                        ),
                        const Gap(8),
                        CustomText(
                          txt: isOverdue
                              ? 'Échéance dépassée'
                              : 'Échéance dans ${daysLeft.abs()} jours',
                          color:
                              isOverdue ? ColorManager.red : ColorManager.grey,
                          size: 14,
                          fontweight: FontWeight.bold,
                          spacing: 0.0,
                        ),
                      ],
                    ),
                    // Action button based on status
                    _buildActionButton(
                        revision, isGroupRevision, isPublicRevision),
                  ],
                ),
                if (isPublicRevision) ...[
                  const Gap(10),
                  // Show capacity information for public revisions
                  LinearProgressIndicator(
                    value: revision.currentMembers / revision.maxGroupe,
                    backgroundColor: ColorManager.grey3,
                    color: _getSaturationColor(revision.saturationPercentage),
                  ),
                  const Gap(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${revision.currentMembers}/${revision.maxGroupe} participants',
                        style: TextStyle(
                          color: ColorManager.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        revision.saturationPercentage >= 90
                            ? 'Presque complet'
                            : revision.saturationPercentage >= 75
                                ? 'Se remplit rapidement'
                                : 'Places disponibles',
                        style: TextStyle(
                          color: _getSaturationColor(
                              revision.saturationPercentage),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      RevisionModel revision, bool isGroupRevision, bool isPublicRevision) {
    // For public revisions, show a "Rejoindre" button if not full
    if (isPublicRevision) {
      final isFull = revision.currentMembers >= revision.maxGroupe;

      return ElevatedButton(
        onPressed:
            isFull ? null : () => controller.joinPublicRevision(revision.id),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFull ? ColorManager.grey : ColorManager.blueprimaryColor,
          foregroundColor: ColorManager.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(isFull ? 'Complet' : 'Rejoindre'),
      );
    }

    // For group revisions, show a "Voir groupe" button regardless of status
    if (isGroupRevision) {
      return ElevatedButton(
        onPressed: () {
          // Navigate to the group detail screen
          controller.joinRevisionSession(revision.id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.blueprimaryColor,
          foregroundColor: ColorManager.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Voir groupe'),
      );
    }

    // For personal revisions, show buttons based on status
    switch (revision.status) {
      case 'À faire':
        return ElevatedButton(
          onPressed: () {
            // Start revision
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.primary,
            foregroundColor: ColorManager.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Commencer'),
        );
      case 'En cours':
        return ElevatedButton(
          onPressed: () {
            // Continue revision
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.blueprimaryColor,
            foregroundColor: ColorManager.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Continuer'),
        );
      case 'Terminé':
        return ElevatedButton(
          onPressed: () {
            // Review revision
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.greenbtn2,
            foregroundColor: ColorManager.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Revoir'),
        );
      default:
        return const SizedBox();
    }
  }

  IconData _getEmptyStateIcon(String status) {
    switch (status) {
      case 'À faire':
        return FeatherIcons.clipboard;
      case 'En cours':
        return FeatherIcons.activity;
      case 'Terminé':
        return FeatherIcons.checkCircle;
      default:
        return FeatherIcons.bookOpen;
    }
  }

  String _getEmptyStateMessage(String status, String type) {
    final typePrefix = type == 'Public' ? 'publique ' : '';

    switch (status) {
      case 'À faire':
        return 'Aucune révision ${typePrefix}à faire';
      case 'En cours':
        return 'Aucune révision ${typePrefix}en cours';
      case 'Terminé':
        return 'Aucune révision ${typePrefix}terminée';
      default:
        return 'Aucune révision trouvée';
    }
  }

  Color _getCompletionColor(int completionPercentage) {
    if (completionPercentage >= 75)
      return ColorManager.greenbtn2; // Green when almost complete
    if (completionPercentage >= 50)
      return ColorManager.amber; // Amber when half complete
    return ColorManager.primaryColor; // Blue when just started
  }

  Color _getSaturationColor(int saturationPercentage) {
    if (saturationPercentage >= 90)
      return ColorManager.error; // Red when almost full
    if (saturationPercentage >= 75)
      return ColorManager.amber; // Amber/orange when getting full
    if (saturationPercentage >= 50)
      return ColorManager.primaryColor; // Primary blue when half full
    return ColorManager.greenbtn2; // Green when plenty of spots available
  }

  void _showCreatePublicRevisionDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController maxMembersController =
        TextEditingController(text: "30"); // Default max members is 30

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une révision publique'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la révision',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(15),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const Gap(15),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Matière',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(15),
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
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: const Text('Choisir'),
                  ),
                ],
              ),
              const Gap(15),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Heure (ex: 14:00 - 16:00)',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(15),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(15),
              TextField(
                controller: maxMembersController,
                decoration: const InputDecoration(
                  labelText: 'Nombre maximum de participants',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 30',
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
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  descriptionController.text.trim().isNotEmpty &&
                  subjectController.text.trim().isNotEmpty &&
                  locationController.text.trim().isNotEmpty &&
                  timeController.text.trim().isNotEmpty) {
                // Parse max members with validation
                int maxMembers = 30;
                try {
                  maxMembers = int.parse(maxMembersController.text.trim());
                  // Ensure reasonable limits
                  if (maxMembers <= 0) maxMembers = 1;
                  if (maxMembers > 100) maxMembers = 100;
                } catch (e) {
                  // Default to 30 if parsing fails
                }

                // Create the public revision
                controller.createPublicRevision(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  subject: subjectController.text.trim(),
                  meetingDate: selectedDate,
                  meetingTime: timeController.text.trim(),
                  meetingLocation: locationController.text.trim(),
                  maxMembers: maxMembers,
                );

                Navigator.pop(context);
              } else {
                // Show error for empty fields
                Get.snackbar(
                  'Champs requis',
                  'Veuillez remplir tous les champs obligatoires',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
