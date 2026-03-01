import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../bloc/comments/comments_bloc.dart';
import '../../../bloc/comments/comments_event.dart';
import '../../../bloc/comments/comments_state.dart';
import '../../../config/colors.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';


class FloatingActionBar extends StatefulWidget {
  final CommentsBloc commentsBloc;
  final int? discussionId;
  final VoidCallback onCommentAdded;
  final bool isProject;


  const FloatingActionBar({
    super.key,
    required this.commentsBloc,
    required this.isProject,
    this.discussionId,
    required this.onCommentAdded,
  });

  @override
  State<FloatingActionBar> createState() => _FloatingActionBarState();
}

class _FloatingActionBarState extends State<FloatingActionBar> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PlatformFile> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  @override
  void didUpdateWidget(covariant FloatingActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (context.read<CommentsBloc>().isUpdate) {
      _messageController.text = context.read<CommentsBloc>().content;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    }
  }


  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final size = await photo.length();
      final bytes = await photo.readAsBytes();
      setState(() {
        _selectedFiles.add(PlatformFile(
          name: photo.name,
          path: photo.path,
          size: size,
          bytes: bytes,
        ));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      final size = await photo.length();
      final bytes = await photo.readAsBytes();
      setState(() {
        _selectedFiles.add(PlatformFile(
          name: photo.name,
          path: photo.path,
          size: size,
          bytes: bytes,
        ));
      });
    }
  }

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'zip',
        'rar',
        'txt'
      ],
      withData: true,
    );
    if (result != null && result.files.length <= 10) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    } else if (result != null && result.files.length > 10) {
      Fluttertoast.showToast(msg: "Maximum 10 files allowed");
    }
  }

  Future<void> _showAttachmentPicker(isProject) async {
    print("Parent ID ${context.read<CommentsBloc>().parentId}");
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              // gradient: const LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   // colors: [Color(0xff9e8efe), Color(0xffe67eff)],
              //   colors: [Color(0xff3a1e62), Color(0xffaa8fd2)],
              // ),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(25)),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ATTACHMENTS (ALLOWED FILE TYPES:',
                  style: TextStyle(color: AppColors.pureWhiteColor),
                ),
                Text(
                  '.png, .jpg, .pdf, .doc, .docx, .xls, .xlsx, .zip, .rar, .txt, MAX FILES ALLOWED: 10)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.pureWhiteColor,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _glassOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context, true);
                        _pickFromCamera();
                      },
                      isProject: isProject,
                    ),
                    _glassOption(
                      isProject: isProject,
                      icon: Icons.photo,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context, true);
                        _pickFromGallery();
                      },
                    ),
                    _glassOption(
                      isProject: isProject,
                      icon: Icons.description,
                      label: 'Documents',
                      onTap: () {
                        Navigator.pop(context, true);
                        _pickDocuments();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ) ??
        false;
  }

  Widget _glassOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required isProject,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // colors: [Color(0xff9e8efe), Color(0xffe67eff)],
                colors: AppColors.chatBackgroundColor,
              ),
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(
              icon,
              color: AppColors.pureWhiteColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.pureWhiteColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }



  void _submitComment(isProject) {
    FocusScope.of(context).unfocus();
    String parentId = context.read<CommentsBloc>().parentId;
    print("dcfgvbhnjkm $parentId");
    bool isUpdate = context.read<CommentsBloc>().isUpdate;
    if (_messageController.text.trim().isNotEmpty) {
      final mediaFiles =
      _selectedFiles.map((file) => File(file.path!)).toList();
      if (isUpdate) {
        widget.commentsBloc.add(UpdateComment(
            commentId: parentId,
            content: _messageController.text.trim(),
            media: mediaFiles,
            isProject: isProject!));
      } else {
        widget.commentsBloc.add(AddComment(
            modelType:
            widget.isProject ? 'App\\Models\\Project' : "App\\Models\\Task",
            modelId: widget.discussionId ?? 0,
            content: _messageController.text.trim(),
            parentId: parentId,
            media: mediaFiles,
            isProject: isProject!));
      }
      _messageController.clear();
      context.read<CommentsBloc>().content="";
      context.read<CommentsBloc>().parentName="";
      context.read<CommentsBloc>().parentId="";
      setState(() => _selectedFiles = []);
      widget.onCommentAdded();
    } else {
      Fluttertoast.showToast(msg: "Comment cannot be empty");
    }
  }

  bool _isImageFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return ['.png', '.jpg', '.jpeg'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {

    String parentName = context.read<CommentsBloc>().parentName;
    return BlocListener<CommentsBloc, CommentsState>(
        listener: (context, state) {
          if (state is CommentEditState) {
            _messageController.text = state.content;
            parentName=state.parentName;
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _messageController.text.length),
            );
          }
        },
                child: Container(
          margin: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 8.w),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            // boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 7)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display selected files
              if (_selectedFiles.isNotEmpty)
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.w,
                    children: _selectedFiles.map((file) {
                      if (_isImageFile(file.name) && file.bytes != null) {
                        return Stack(
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  file.bytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Chip(
                                      label: Text(
                                        file.name,
                                        style: TextStyle(
                                          color: AppColors.pureWhiteColor,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                      deleteIcon: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.pureWhiteColor,
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedFiles.remove(file);
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFiles.remove(file);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.pureWhiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Chip(
                          label: Text(
                            file.name,
                            style: TextStyle(
                              color: AppColors.pureWhiteColor,
                              fontSize: 12.sp,
                            ),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.pureWhiteColor,
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedFiles.remove(file);
                            });
                          },
                        );
                      }
                    }).toList(),
                  ),
                ),
              // Replying to section
              if (parentName != "")
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "${AppLocalizations.of(context)!.replyingto} $parentName",
                        size: 15.sp,
                        color: AppColors.pureWhiteColor,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            context.read<CommentsBloc>().parentName = "";
                            context.read<CommentsBloc>().parentId = "";
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.pureWhiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              if (parentName != "" || _selectedFiles.isNotEmpty)
                SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          style: TextStyle(color: AppColors.pureWhiteColor),
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Message",
                            hintStyle:
                            TextStyle(color: AppColors.pureWhiteColor),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
            if(  context.read<CommentsBloc>().isUpdate == false ) IconButton(
                    icon: Icon(Icons.attach_file, color: AppColors.whiteColor),
                    onPressed: () {
                      _showAttachmentPicker(widget.isProject);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.whiteColor),
                    onPressed: () => _submitComment(widget.isProject),
                  ),
                ],
              ),
            ],
          ),
        ),
     );
  }
}