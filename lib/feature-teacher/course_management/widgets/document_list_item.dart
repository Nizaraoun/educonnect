import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import '../../../../core/themes/color_mangers.dart';
import '../../../../widgets/custom_text.dart';

class DocumentListItem extends StatelessWidget {
  final Map<String, dynamic> document;
  final VoidCallback onEdit;
  final VoidCallback onDownload;
  final VoidCallback onTap;

  const DocumentListItem({
    Key? key,
    required this.document,
    required this.onEdit,
    required this.onDownload,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color documentColor;
    try {
      documentColor = Color(int.parse('0xFF${document['color'].substring(1)}'));
    } catch (e) {
      documentColor = ColorManager.primaryColor;
    }

    // Determine icon based on file type
    IconData fileIcon;
    switch (document['type']) {
      case 'pdf':
        fileIcon = FeatherIcons.fileText;
        break;
      case 'doc':
      case 'docx':
        fileIcon = FeatherIcons.file;
        break;
      case 'ppt':
      case 'pptx':
        fileIcon = FeatherIcons.monitor;
        break;
      case 'xls':
      case 'xlsx':
        fileIcon = FeatherIcons.grid;
        break;
      case 'zip':
      case 'rar':
        fileIcon = FeatherIcons.archive;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = FeatherIcons.image;
        break;
      case 'sql':
        fileIcon = FeatherIcons.database;
        break;
      default:
        fileIcon = FeatherIcons.file;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: documentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            fileIcon,
            color: documentColor,
          ),
        ),
        title: customText(
          text: document['title'] ?? '',
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: '${document['courseCode']} - ${document['moduleTitle']}',
              textStyle: TextStyle(
                fontSize: 12,
                color: ColorManager.grey,
              ),
            ),
            customText(
              text: 'Ajouté le ${document['uploadDate']} • ${document['size']}',
              textStyle: TextStyle(
                fontSize: 11,
                color: ColorManager.grey,
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 96, // Constrain width to fit two icons
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                constraints: BoxConstraints(),
                padding: EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  FeatherIcons.edit2,
                  size: 18,
                  color: ColorManager.grey,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                constraints: BoxConstraints(),
                padding: EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  FeatherIcons.download,
                  size: 18,
                  color: ColorManager.blueprimaryColor,
                ),
                onPressed: onDownload,
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
