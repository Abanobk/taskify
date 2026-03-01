import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/comments/comments_bloc.dart';
import '../../../config/colors.dart';
import '../../../data/localStorage/hive.dart';
import '../../../data/model/discussion/discussion_model.dart';


import '../../../utils/widgets/custom_text.dart';
import 'attachment_bubble.dart';

class ReceiverMessage extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final String message;
  final String time;
  final List<CommentsAttachments> attachments;
  final String commentId;
  final int replyCount;
  final VoidCallback onToggleExpanded;
  final Function(String,String,String) onUpdate;
  final VoidCallback onDelete;
  final bool isProject;
  final String commentatorId; // Added to store the commenter's ID

  const ReceiverMessage({
    required this.avatarUrl,
    required this.name,
    required this.message,
    required this.time,
    required this.attachments,
    required this.commentId,
    required this.replyCount,
    required this.onToggleExpanded,
    required this.onUpdate,
    required this.onDelete,
    required this.isProject,
    required this.commentatorId,
  });

  @override
  State<ReceiverMessage> createState() => _ReceiverMessageState();
}

class _ReceiverMessageState extends State<ReceiverMessage> {
  bool _showIcons = false;
  int? userId; // State variable to store the user ID

  @override
  void initState() {
    super.initState();
    _getUserID(); // Fetch user ID when widget is initialized
  }

  Future<void> _getUserID() async {
    final id = await HiveStorage.getUserId();
    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetch permissions from AuthBloc
    final bool hasPermission =
        context.read<AuthBloc>().hasAllDataAccess ?? false;
    final String role = context.read<AuthBloc>().role ?? '';
    final bool isAdmin =
        role.toLowerCase() == 'admin'; // Adjust based on your role logic
    // Adjust based on your AuthBloc

    // Condition for edit/delete permissions
    final bool canEditOrDelete =
        isAdmin || hasPermission || widget.commentatorId == userId.toString();

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.avatarUrl),
                      radius: 18,
                    ),

                  ],
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 120, // ✅ Max width for name
                                  minWidth: 20, // ✅ Optional: Minimum width
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  // color: Colors.red,
                                  child: CustomText(
                                    text: widget.name,
                                    size: 12.sp,
                                    color: AppColors.pureWhiteColor,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow
                                        .ellipsis, // ✅ Handles long names
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              Text(
                                " • ${widget.time}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.pureWhiteColor,
                                ),
                              ),
                            ],
                          ),
                          if (_showIcons && canEditOrDelete)
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      context.read<CommentsBloc>().parentId =
                                          widget.commentId;
                                      context.read<CommentsBloc>().parentName =
                                          widget.name;
                                      context.read<CommentsBloc>().content =
                                          widget.message;
                                      context.read<CommentsBloc>().isUpdate = true;
                                    });
                                    widget.onUpdate(widget.message,widget.name,widget.commentId);


                                    print("content  ${context.read<CommentsBloc>().content}");
                                    print("parentName ${context.read<CommentsBloc>().parentName}");
                                  },
                                  child: HeroIcon(
                                    HeroIcons.pencil,
                                    size: 16.sp,
                                    color: AppColors.pureWhiteColor,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                InkWell(
                                  onTap: widget.onDelete,
                                  child: HeroIcon(
                                    HeroIcons.trash,
                                    size: 16.sp,
                                    color: AppColors.pureWhiteColor,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onLongPress: () {
                          if (canEditOrDelete) {
                            setState(() {
                              _showIcons = !_showIcons;
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BubbleSpecialOne(
                              text: widget.message,
                              color: const Color(0xffb3daf0),
                              // color: const Color(0xffd7c6fe),
                              tail: true,
                              textStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              isSender: false,
                            ),
                            SizedBox(height: 4.h),
                          ],
                        ),
                      ),
                      if (widget.attachments.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h, left: 15.w),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: widget.attachments
                                .map((attachment) => AttachmentBubble(
                                      id: attachment.id!,
                                      fileUrl: attachment.url ?? "",
                                      fileName: attachment.fileName ?? "",
                                      commentId: widget.commentId,
                                      commentContent: widget.message,
                                      attachments: widget.attachments,
                                      isProject: widget.isProject,
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

