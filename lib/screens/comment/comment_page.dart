import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/chat_shimmer.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../bloc/comments/comments_bloc.dart';
import '../../bloc/comments/comments_event.dart';
import '../../bloc/comments/comments_state.dart';
import '../../config/app_images.dart';
import '../../data/model/discussion/discussion_model.dart';
import '../../data/repositories/comments/comment_repo.dart';
import 'package:intl/intl.dart';
import 'comment_widgets/chat_header.dart';
import 'comment_widgets/floating_actionbar.dart';
import 'comment_widgets/receiver_message.dart';
import 'comment_widgets/sender_message.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class CommentSection extends StatefulWidget {
  final int? id;
  final String? title;
  final bool? isProject;

  const CommentSection({super.key, this.id, this.title, this.isProject});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final ScrollController _scrollController = ScrollController();
  late CommentsBloc _commentsBloc;
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _commentsBloc = CommentsBloc(discussionRepo: DiscussionRepo())
      ..add(LoadComments(
          id: widget.id ?? 0,
          limit: 20,
          offset: 0,
          isProject: widget.isProject!));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _commentsBloc.loadMoreComments(widget.isProject!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentsBloc.close();
    super.dispose();
  }

  // Future<void> _onRefresh() async {
  //   _commentsBloc
  //       .add(RefreshComments(id: widget.id ?? 0, isProject: widget.isProject!));
  //   await Future.delayed(const Duration(milliseconds: 500));
  // }
  Future<void> _onRefresh() async {
    _commentsBloc
        .add(RefreshComments(id: widget.id ?? 0, isProject: widget.isProject!));
    await _commentsBloc.stream.firstWhere(
      (state) => state is CommentLoaded || state is CommentError,
    );
  }

  void _toggleExpanded(String commentId) {
    setState(() {
      _isExpanded[commentId] = !(_isExpanded[commentId] ?? false);
    });
  }

  String _getDateHeader(DateTime commentDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final commentDay =
        DateTime(commentDate.year, commentDate.month, commentDate.day);

    if (commentDay == today) {
      return "Today";
    } else if (commentDay == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('MMMM d, yyyy').format(commentDate);
    }
  }

  List<MapEntry<String, List<CommentModel>>> _groupCommentsByDate(
      List<CommentModel> comments) {
    final Map<DateTime, List<CommentModel>> groupedComments = {};
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (var comment in comments) {
      final sentTime =
          comment.createdAt != null && comment.createdAt!.isNotEmpty
              ? dateFormat.parse(comment.createdAt!)
              : DateTime.now();
      final dateKey = DateTime(sentTime.year, sentTime.month, sentTime.day);
      if (!groupedComments.containsKey(dateKey)) {
        groupedComments[dateKey] = [];
      }
      groupedComments[dateKey]!.add(comment);
    }

    groupedComments.forEach((key, value) {
      value.sort((a, b) => dateFormat
          .parse(b.createdAt!)
          .compareTo(dateFormat.parse(a.createdAt!)));
    });

    final sortedEntries = groupedComments.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return sortedEntries.map((entry) {
      return MapEntry(_getDateHeader(entry.key), entry.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _commentsBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.chatBackgroundColor,
            ),
          ),
          child: Column(
            children: [
              ChatHeader(title: widget.title ?? ""),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: AppColors.white10,
                  color: AppColors.pureWhiteColor,
                  onRefresh: _onRefresh,
                  child: BlocConsumer<CommentsBloc, CommentsState>(
                    listener: (context, state) {
                      if (state is CommentDeleteSuccess) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!
                                .deletedsuccessfully);
                      } else if (state is CommentDeleteError) {
                        Fluttertoast.showToast(msg: state.errorMessage);
                      } else if (state is CommentError) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!
                                .failedtoaddorupdatecomment);
                      }
                    },
                    builder: (context, state) {
                      print("Sattae of Comment $state");
                      List<CommentModel> comments = [];
                      bool isLoadingMore = false;
                      if (state is CommentInitial) {
                        return ChatShimmer();
                      }
                      if (state is CommentLoading) {
                        comments = state.currentComments;
                      } else if (state is CommentLoadMoreLoading) {
                        comments = state.currentComments;
                        isLoadingMore = true;
                      } else if (state is CommentLoaded ||
                          state is CommentEditState) {
                        comments = state is CommentLoaded
                            ? state.comments
                            : (state as CommentEditState).comments;
                      } else if (state is CommentError) {
                        return Center(child: Text(state.message));
                      }

                      // ✅ Show shimmer if first-time loading and comments are empty
                      if (state is CommentLoading && comments.isEmpty) {
                        return ChatShimmer();
                      }

                      // ✅ Show "No Chat" if loaded but empty
                      if (comments.isEmpty) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.noChatImage,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 10.h),
                              CustomText(
                                text: AppLocalizations.of(context)!.chatisempty,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                size: 28.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              SizedBox(height: 10.h),
                              CustomText(
                                text: AppLocalizations.of(context)!
                                    .betheonetobreaktheice,
                                color: Colors.grey.shade300,
                                size: 18.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        );
                      }

                      // ✅ Group comments by date
                      final groupedComments = _groupCommentsByDate(comments);

                      // ✅ Render the ListView
                      return ListView.builder(
                        key: ValueKey(comments.length),
                        padding: EdgeInsets.only(bottom: 50.h, top: 0.h),
                        controller: _scrollController,
                        physics:
                            const AlwaysScrollableScrollPhysics(), // This enables pull-to-refresh even with few items

                        itemCount: groupedComments.fold<int>(0,
                                (sum, group) => sum + group.value.length + 1) +
                            (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          int currentIndex = 0;
                          for (var group in groupedComments) {
                            // ✅ Date header
                            if (currentIndex == index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 18.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 10, sigmaY: 10),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Center(
                                              child: CustomText(
                                                text: group.key,
                                                color: AppColors.pureWhiteColor,
                                                size: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            currentIndex++;

                            // ✅ Comment items
                            if (index >= currentIndex &&
                                index < currentIndex + group.value.length) {
                              final comment = group.value[index - currentIndex];
                              return _buildCommentItem(
                                  context, comment, group.value);
                            }
                            currentIndex += group.value.length;
                          }

                          // ✅ Loading spinner for pagination
                          if (index == currentIndex && isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: SpinKitThreeBounce(
                                  color: AppColors.pureWhiteColor,
                                  size: 40.0,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),
                ),

              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                child: FloatingActionBar(
                  isProject: widget.isProject!,
                  commentsBloc: _commentsBloc,
                  discussionId: widget.id,
                  onCommentAdded: () {
                    _commentsBloc.add(LoadComments(
                        id: widget.id ?? 0,
                        limit: 20,
                        offset: 0,
                        isProject: widget.isProject!));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, CommentModel comment,
      List<CommentModel> groupComments) {
    final commentId = comment.id?.toString() ?? '';
    final replyCount = comment.children?.length ?? 0;
    final isExpanded = _isExpanded[commentId] ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Draw vertical line if this is a child comment and parent exists

          ReceiverMessage(
            avatarUrl:
                comment.commenter?.photo ?? 'https://i.pravatar.cc/150?img=4',
            name:
                '${comment.commenter?.firstName ?? ''} ${comment.commenter?.lastName ?? ''}',
            message: comment.content ?? '',
            time: comment.sentTime ?? '',
            attachments: comment.attachments ?? <CommentsAttachments>[],
            commentId: commentId,
            replyCount: replyCount,
            onToggleExpanded: () => _toggleExpanded(commentId),
            onUpdate: (message, parentName, parentId) {
              setState(() {
                context.read<CommentsBloc>().isUpdate = true;
                context.read<CommentsBloc>().parentId = parentId;
                context.read<CommentsBloc>().content = message;
                print(
                    "crftbghjnkmll, ${context.read<CommentsBloc>().isUpdate}");
                print(
                    "crftbghjnkmll, ${context.read<CommentsBloc>().parentId}");
                print("crftbghjnkmll, ${context.read<CommentsBloc>().content}");
              });
            },
            onDelete: () async {
              FocusScope.of(context).unfocus();
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.grey[200], // ✅ Background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // ✅ Rounded corners
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.confirmDelete,
                      style: const TextStyle(
                          color: Colors.black), // ✅ Title text color
                    ),
                    content: const Text(
                      "Are you sure you want to delete this comment?",
                      style: TextStyle(
                          color: Colors.black87), // ✅ Content text color
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: const TextStyle(
                              color: Colors.blue), // ✅ Cancel button color
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          AppLocalizations.of(context)!.delete,
                          style: const TextStyle(
                              color: Colors.red), // ✅ Delete button color
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                context.read<CommentsBloc>().add(
                    DeleteComment(int.parse(comment.id!), widget.isProject!));
              }
            },
            isProject: widget.isProject!,
            commentatorId: comment.commenter!.id.toString(),
          ),

          Padding(
            padding: EdgeInsets.only(left: 60.w, top: 0.h, bottom: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      context.read<CommentsBloc>().parentId = comment.id!;
                      context.read<CommentsBloc>().isUpdate = false;
                      context.read<CommentsBloc>().parentName =
                          comment.commenter!.firstName!;
                    });
                  },
                  child: Row(
                    children: [
                      HeroIcon(HeroIcons.chatBubbleOvalLeft,
                          style: HeroIconStyle.outline,
                          size: 15.sp,
                          color: AppColors.pureWhiteColor),
                      SizedBox(
                        width: 2.w,
                      ),
                      CustomText(
                        text: AppLocalizations.of(context)!.reply,
                        color: AppColors.pureWhiteColor,
                        size: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
                if (replyCount > 0) ...[
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: () => _toggleExpanded(commentId),
                    child: CustomText(
                      text: isExpanded
                          ? "${AppLocalizations.of(context)!.hidereplies} $replyCount"
                          : "${AppLocalizations.of(context)!.view} $replyCount ${AppLocalizations.of(context)!.morereplies}",
                      color: AppColors.pureWhiteColor.withValues(alpha: 0.8),
                      size: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isExpanded &&
              comment.children != null &&
              comment.children!.isNotEmpty)
            ...comment.children!.map(
              (child) {
                print("Child ID: ${child.id}"); // ✅ Print child.id here
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SenderMessage(
                    avatarUrl: child.commenter?.photo ??
                        'https://i.pravatar.cc/150?img=4',
                    name:
                        '${child.commenter?.firstName ?? ''} ${child.commenter?.lastName ?? ''}',
                    message: child.content ?? '',
                    time: child.sentTime ?? '',
                    attachments: child.attachments ?? <CommentsAttachments>[],
                    commentId: child.id?.toString() ?? '',
                    replyCount: 0,
                    onUpdate: (message, parentName, parentId) {
                      setState(() {
                        context.read<CommentsBloc>().isUpdate = true;
                        context.read<CommentsBloc>().parentId = parentId;
                        context.read<CommentsBloc>().content = message;
                        print(
                            "isUpdate: ${context.read<CommentsBloc>().isUpdate}");
                        print(
                            "parentId: ${context.read<CommentsBloc>().parentId}");
                        print(
                            "content: ${context.read<CommentsBloc>().content}");
                      });
                    },
                    onDelete: () async {
                      FocusScope.of(context).unfocus();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor:
                                Colors.grey[200], // ✅ Change background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  16), // ✅ Rounded corners
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.confirmDelete,
                              style: const TextStyle(
                                  color: Colors.black), // ✅ Title text color
                            ),
                            content: Text(
                              AppLocalizations.of(context)!
                                  .areyousurewanttodeletethiscomment,
                              style: const TextStyle(
                                  color:
                                      Colors.black87), // ✅ Content text color
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                  style: const TextStyle(
                                      color:
                                          Colors.blue), // ✅ Cancel button color
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: const TextStyle(
                                      color:
                                          Colors.red), // ✅ Delete button color
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        context.read<CommentsBloc>().add(DeleteComment(
                            int.parse(child.id!), widget.isProject!));
                      }
                    },
                    isProject: widget.isProject!,
                    commentatorId: child.commenter!.id.toString(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Custom Painter for drawing the vertical line
class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
