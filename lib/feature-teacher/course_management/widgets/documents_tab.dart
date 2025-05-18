import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'empty_documents_state.dart';
import 'document_list_item.dart';

class DocumentsTab extends StatelessWidget {
  final List<Map<String, dynamic>> documents;
  final Function() onAddDocument;
  final Function(Map<String, dynamic>) onEditDocument;
  final Function(Map<String, dynamic>) onDownloadDocument;
  final Function(Map<String, dynamic>) onViewDocument;

  const DocumentsTab({
    Key? key,
    required this.documents,
    required this.onAddDocument,
    required this.onEditDocument,
    required this.onDownloadDocument,
    required this.onViewDocument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher des documents...',
              prefixIcon: Icon(FeatherIcons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: documents.isEmpty
              ? EmptyDocumentsState(onAddPressed: onAddDocument)
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return DocumentListItem(
                      document: document,
                      onEdit: () => onEditDocument(document),
                      onDownload: () => onDownloadDocument(document),
                      onTap: () => onViewDocument(document),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
