import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../bloc/comments/comments_bloc.dart';
import '../../../bloc/comments/comments_event.dart';
import '../../../config/colors.dart';
import '../../../data/model/discussion/discussion_model.dart';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import '../../../utils/widgets/custom_text.dart';
import 'fullscreen_imageview.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class AttachmentBubble extends StatefulWidget {
  final int id;
  final String fileUrl;
  final String fileName;
  final String commentId;
  final String commentContent;
  final bool isProject;
  final List<CommentsAttachments> attachments;

  const AttachmentBubble({
    required this.id,
    required this.fileUrl,
    required this.isProject,
    required this.fileName,
    required this.commentId,
    required this.commentContent,
    required this.attachments,
  });

  @override
  State<AttachmentBubble> createState() => _AttachmentBubbleState();
}

class _AttachmentBubbleState extends State<AttachmentBubble> {
  bool _showIcons = false;

  static const Map<String, IconData> _fileTypeIcons = {
    'png': Icons.image,
    'jpg': Icons.image,
    'pdf': Icons.picture_as_pdf,
    'doc': Icons.description,
    'docx': Icons.description,
    'xls': Icons.table_chart,
    'xlsx': Icons.table_chart,
    'zip': Icons.archive,
    'rar': Icons.archive,
    'txt': Icons.text_fields,
  };

  bool _isImageFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['png', 'jpg'].contains(extension);
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return _fileTypeIcons[extension] ?? Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    final isImage = _isImageFile(widget.fileName);

    return SizedBox(
      width: double.infinity,

      child: Padding(
        padding: EdgeInsets.only(top: 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {},
                  onLongPress: () {
                    setState(() {
                      _showIcons = !_showIcons;
                    });
                  },
                  child: Stack(
                    children: [
                      BubbleNormalImage(
                        isSender: false,
                        id: widget.commentId,
                        onTap: () {
                          if (isImage) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                transitionDuration: Duration(milliseconds: 300),
                                pageBuilder: (_, __, ___) =>
                                    FullScreenImageView(
                                        imageUrl: widget.fileUrl),
                              ),
                            );
                          } else {}
                        },
                        bubbleRadius: BUBBLE_RADIUS_IMAGE,
                        padding: const EdgeInsets.all(1),
                        color: Colors.white.withValues(alpha: 0.7),
                        margin: EdgeInsets.zero,
                        image: isImage
                            ? Image.network(
                                widget.fileUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  _getFileIcon(widget.fileName),
                                  size: 50,
                                  color: Colors.blueGrey,
                                ),
                              )
                            : Icon(
                                _getFileIcon(widget.fileName),
                                size: 50,
                                color: Colors.blueGrey,
                              ),
                        tail: true,
                      ),
                      if (_showIcons && isImage)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              color: Colors.black.withValues(alpha: 0.3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await _downloadFile(
                                          widget.fileUrl, widget.fileName);
                                    },
                                    child: const Icon(Icons.download,
                                        color: Colors.white, size: 20),
                                  ),
                                  SizedBox(width: 8.w),
                                  InkWell(
                                    onTap: () {
                                      _deleteAttachment(
                                          widget.id, widget.isProject);
                                    },
                                    child: const Icon(Icons.delete,
                                        color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_showIcons && !isImage)
                  Padding(
                    padding: EdgeInsets.only(left: 8.w, top: 8.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            await _downloadFile(
                                widget.fileUrl, widget.fileName);
                          },
                          child: const Icon(Icons.download,
                              color: Colors.white, size: 20),
                        ),
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: () {
                            _deleteAttachment(widget.id, widget.isProject);
                          },
                          child: const Icon(Icons.delete,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (!isImage)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: CustomText(
                  text: widget.fileName,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softwrap: true,
                  size: 12,
                  color: AppColors.pureWhiteColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _downloadFile(String fileUrl, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = "${tempDir.path}/$fileName";

      final dio = Dio();
      await dio.download(
        fileUrl,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
                "Download progress: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      final params = SaveFileDialogParams(
          sourceFilePath: tempFilePath, fileName: fileName);
      final savedFilePath = await FlutterFileDialog.saveFile(params: params);

      if (savedFilePath != null) {
        Fluttertoast.showToast(msg: "File saved to: $savedFilePath");
        return savedFilePath;
      } else {
        Fluttertoast.showToast(msg: "Save cancelled by user");
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Download failed: $e");
      print("Download error: $e");
      return null;
    }
  }
  void _deleteAttachment(int id, isProject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200], // ✅ Change background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Optional: Rounded corners
          ),
          title: Text(
            AppLocalizations.of(context)!.confirmDelete,
            style: const TextStyle(color: Colors.black), // Optional: title text color
          ),
          content: Text(
            AppLocalizations.of(context)!.areyousureyouwanttodeletethisimage,
            style: const TextStyle(color: Colors.black87), // Optional: content text color
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Colors.blue), // Optional: cancel button color
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      context.read<CommentsBloc>().add(DeleteCommentAttachment(id, isProject));
    }
  }

}
