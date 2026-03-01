import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../bloc/comments/comments_bloc.dart';
import '../../../bloc/comments/comments_event.dart';
import '../../../bloc/comments/comments_state.dart';
import '../../../config/colors.dart';



class CommentBottomSheet extends StatelessWidget {
  final bool isReply;
  final String parentId;
  final VoidCallback onCommentAdded;
  final bool isUpdate;
  final String? initialContent;
  final bool isProject;

  const CommentBottomSheet({
    required this.isReply,
    required this.parentId,
    required this.onCommentAdded,
    required this.isProject,
    this.isUpdate = false,
    this.initialContent,
  });

  @override
  Widget build(BuildContext context) {
    return CommentBottomSheetContent(
      isProject: isProject,
      isReply: isReply,
      parentId: parentId,
      onCommentAdded: onCommentAdded,
      isUpdate: isUpdate,
      initialContent: initialContent,
    );
  }
}

class CommentBottomSheetContent extends StatefulWidget {
  final bool isReply;
  final String parentId;
  final VoidCallback onCommentAdded;
  final bool isUpdate;
  final String? initialContent;
  final bool isProject;

  const CommentBottomSheetContent({
    required this.isReply,
    required this.parentId,
    required this.onCommentAdded,
    required this.isProject,
    this.isUpdate = false,
    this.initialContent,
  });

  @override
  State<CommentBottomSheetContent> createState() =>
      CommentBottomSheetContentState();
}

class CommentBottomSheetContentState
    extends State<CommentBottomSheetContent> {
  final TextEditingController controller = TextEditingController();
  List<PlatformFile> selectedFiles = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.initialContent != null) {
      controller.text = widget.initialContent!;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is AddCommentLoading || state is CommentLoading) {
          setState(() => isSubmitting = true);
        } else if (state is CommentLoaded) {
          setState(() => isSubmitting = false);
          Fluttertoast.showToast(
            msg:
            "${widget.isReply ? 'Reply' : widget.isUpdate ? 'Comment updated' : 'Comment'} added successfully",
          );
          Navigator.of(context).pop();
          widget.onCommentAdded();
        } else if (state is CommentError) {
          setState(() => isSubmitting = false);
          Fluttertoast.showToast(
            msg:
            "Failed to ${widget.isUpdate ? 'update' : 'add'} ${widget.isReply ? 'reply' : 'comment_widgets'}",
          );
        }
      },
      builder: (context, state) {
        print("STATE IN DIALOG $state");
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isUpdate
                      ? 'Update Comment'
                      : widget.isReply
                      ? 'Reply to Comment'
                      : 'Add Comment',
                  style: const TextStyle(
                    color: AppColors.pureWhiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Text('COMMENT ',
                        style: TextStyle(
                            color: AppColors.pureWhiteColor,
                            fontWeight: FontWeight.bold)),
                    const Text('* ', style: TextStyle(color: Colors.red)),
                  ],
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  style: TextStyle(color: AppColors.pureWhiteColor),
                  decoration: InputDecoration(
                    hintText: widget.isUpdate
                        ? "Update Comment"
                        : "Please Enter Comment",
                    hintStyle: TextStyle(color: AppColors.pureWhiteColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: AppColors.pureWhiteColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.pureWhiteColor, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                const Text(
                  'ATTACHMENTS (ALLOWED FILE TYPES:',
                  style: TextStyle(color: AppColors.pureWhiteColor),
                ),
                const Text(
                  '.png, .jpg, .pdf, .doc, .docx, .xls, .xlsx, .zip, .rar, .txt, MAX FILES ALLOWED: 10)',
                  style:
                  TextStyle(fontSize: 10, color: AppColors.pureWhiteColor),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 40.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
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
                          if (result != null) {
                            setState(() {
                              selectedFiles = result.files;
                            });
                          }
                        },
                        child: const Text(
                          'Choose Files',
                          style: TextStyle(color: AppColors.pureWhiteColor),
                        ),
                      ),
                      const VerticalDivider(color: AppColors.greyColor),
                      Expanded(
                        child: Text(
                          selectedFiles.isNotEmpty
                              ? selectedFiles
                              .map((file) => file.name)
                              .join(', ')
                              : 'No file chosen',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.pureWhiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: selectedFiles.isNotEmpty ? 100.h : 0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = selectedFiles[index];
                      final isImage = file.extension!.toLowerCase() == 'png' ||
                          file.extension!.toLowerCase() == 'jpg';

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80.w,
                            margin: EdgeInsets.only(right: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isImage
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(file.path!),
                                    width: 70.w,
                                    height: 60.h,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.blueGrey,
                                  size: 40,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  file.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10, color: AppColors.greyColor),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 1,
                            top: -6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFiles.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColors.red,
                                child: Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close',
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff3a1e62), Color(0xffaa8fd2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () {
                            if (controller.text.trim().isNotEmpty) {
                              setState(() => isSubmitting = true);
                              final mediaFiles = selectedFiles
                                  .map((platformFile) =>
                                  File(platformFile.path!))
                                  .toList();
                              context.read<CommentsBloc>().add(
                                widget.isUpdate
                                    ? UpdateComment(
                                  commentId: widget.parentId,
                                  content:
                                  controller.text.trim(),
                                  media: mediaFiles,
                                  isProject: widget.isProject,
                                )
                                    : AddComment(
                                  modelType: widget.isProject
                                      ? 'App\\Models\\Project'
                                      : "App\\Models\\Task",
                                  modelId: 1,
                                  content:
                                  controller.text.trim(),
                                  parentId: widget.isReply
                                      ? widget.parentId
                                      : '',
                                  media: mediaFiles,
                                  isProject: widget.isProject,
                                ),
                              );
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Comment cannot be empty");
                            }
                          },
                          child: isSubmitting
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : Text(
                            widget.isUpdate ? 'Update' : 'Submit',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }
}