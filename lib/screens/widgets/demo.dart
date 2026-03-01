// import 'dart:io';
// import 'dart:ui';
// import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
// import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_file_dialog/flutter_file_dialog.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:heroicons/heroicons.dart';
// import 'package:taskify/config/colors.dart';
// import 'package:taskify/screens/widgets/chat_shimmer.dart';
// import 'package:taskify/utils/widgets/custom_text.dart';
// import '../../bloc/comments/comments_bloc.dart';
// import '../../bloc/comments/comments_event.dart';
// import '../../bloc/comments/comments_state.dart';
// import '../../data/model/discussion/discussion_model.dart';
// import '../../data/repositories/comments/comment_repo.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// const double BUBBLE_RADIUS_IMAGE = 16;
//
// class CommentSectionUI extends StatefulWidget {
//   const CommentSectionUI({super.key});
//
//   @override
//   State<CommentSectionUI> createState() => _CommentSectionUIState();
// }
//
// class _CommentSectionUIState extends State<CommentSectionUI> {
//   final ScrollController _scrollController = ScrollController();
//   late CommentsBloc _commentsBloc;
//   final Map<String, bool> _isExpanded = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _commentsBloc = CommentsBloc(discussionRepo: DiscussionRepo())
//       ..add(const LoadComments(id: 1, limit: 20, offset: 0));
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent * 0.8) {
//         _commentsBloc.loadMoreComments();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _commentsBloc.close();
//     super.dispose();
//   }
//
//   Future<void> _onRefresh() async {
//     _commentsBloc.add(const RefreshComments(id: 1));
//     await Future.delayed(const Duration(milliseconds: 500));
//   }
//
//   void _toggleExpanded(String commentId) {
//     setState(() {
//       _isExpanded[commentId] = !(_isExpanded[commentId] ?? true);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _commentsBloc,
//       child: Scaffold(
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: AppColors.pureWhiteColor,
//           onPressed: () {
//             showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 builder: (dialogCtx) => ClipRRect(
//                     borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(25)),
//                     child: BackdropFilter(
//                         filter:
//                         ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur effect
//                         child: Container(
//                           padding: EdgeInsets.only(
//                             bottom: MediaQuery.of(context).viewInsets.bottom,
//                             top: 16,
//                             left: 16,
//                             right: 16,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2), // Glass effect
//                             borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(25)),
//                             border: Border.all(
//                                 color: Colors.white.withOpacity(0.3), width: 1.5),
//                           ),
//                           child:_CommentBottomSheet(
//                             isReply: false,
//                             parentId: '',
//                             onCommentAdded: () {
//                               _commentsBloc
//                                   .add(const LoadComments(id: 1, limit: 20, offset: 0));
//                             },
//                           ),
//                         ))));
//           },
//           child: const Icon(Icons.add, color: Color(0xff9e8efe)),
//           tooltip: 'Add Comment',
//         ),
//         backgroundColor: Theme.of(context).colorScheme.background,
//         body: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xff9e8efe),
//                 Color(0xffe67eff),
//               ],
//             ),
//           ),
//           child: Column(
//             children: [
//               const _ChatHeader(),
//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: _onRefresh,
//                   child: BlocConsumer<CommentsBloc, CommentsState>(
//                     listener: (context, state) {
//                       if (state is CommentDeleteSuccess) {
//                         Fluttertoast.showToast(
//                             msg: "Comment deleted successfully");
//                       } else if (state is CommentDeleteError) {
//                         Fluttertoast.showToast(msg: state.errorMessage);
//                       } else if (state is CommentError) {
//                         Fluttertoast.showToast(
//                             msg: "Failed to add or update comment");
//                       }
//                     },
//                     builder: (context, state) {
//                       print("Comment State: $state");
//                       List<CommentModel> comments = [];
//                       bool isLoadingMore = false;
//
//                       if (state is CommentLoading) {
//                         comments = state.currentComments;
//                         print(
//                             "CommentLoading with ${comments.length} comments");
//                       } else if (state is CommentLoadMoreLoading) {
//                         comments = state.currentComments;
//                         isLoadingMore = true;
//                         print(
//                             "CommentLoadMoreLoading with ${comments.length} comments");
//                       } else if (state is CommentLoaded) {
//                         comments = state.comments;
//                         print("CommentLoaded with ${comments.length} comments");
//                       } else if (state is CommentError) {
//                         return Center(child: Text(state.message));
//                       }
//
//                       if (comments.isEmpty && !isLoadingMore) {
//                         return ChatShimmer();
//                       }
//
//                       return ListView.builder(
//                         padding: EdgeInsets.only(bottom: 50.h, top: 20.h),
//                         controller: _scrollController,
//                         itemCount: comments.length + (isLoadingMore ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           if (index == comments.length && isLoadingMore) {
//                             return const Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Center(
//                                 child: SpinKitThreeBounce(
//                                   color: AppColors.pureWhiteColor,
//                                   size: 40.0,
//                                 ),
//                               ),
//                             );
//                           }
//                           return _buildCommentItem(context, comments[index]);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCommentItem(BuildContext context, CommentModel comment) {
//     final commentId = comment.id?.toString() ?? '';
//     final isExpanded = _isExpanded[commentId] ?? true;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 10.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _ReceiverMessage(
//             avatarUrl:
//             comment.commenter?.photo ?? 'https://i.pravatar.cc/150?img=4',
//             name:
//             '${comment.commenter?.firstName ?? ''} ${comment.commenter?.lastName ?? ''}',
//             message: comment.content ?? '',
//             time: comment.sentTime ?? '',
//             attachments: comment.attachments ?? <CommentsAttachments>[],
//             commentId: commentId,
//             isExpanded: isExpanded,
//             onToggleExpanded: () => _toggleExpanded(commentId),
//             onUpdate: () => _showUpdateBottomSheet(
//                 context, commentId, comment.content ?? ''),
//             onDelete: () async {
//               final confirm = await showDialog<bool>(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: const Text("Confirm Delete"),
//                     content: const Text(
//                         "Are you sure you want to delete this comment?"),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, false),
//                         child: const Text("Cancel"),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, true),
//                         child: const Text("Delete",
//                             style: TextStyle(color: Colors.red)),
//                       ),
//                     ],
//                   );
//                 },
//               );
//
//               if (confirm == true) {
//                 context
//                     .read<CommentsBloc>()
//                     .add(DeleteComment(int.parse(comment.id!)));
//               }
//             },
//           ),
//           Padding(
//             padding: EdgeInsets.only(left: 38.w, top: 5.h, bottom: 20.h),
//             child: InkWell(
//               onTap: () {
//                 print("Reply to comment ${comment.id}");
//                 _showReplyBottomSheet(context, commentId);
//               },
//               child: CustomText(
//                 text: "Reply",
//                 color: AppColors.pureWhiteColor,
//                 size: 15.sp,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           if (isExpanded &&
//               comment.children != null &&
//               comment.children!.isNotEmpty)
//             ...comment.children!.map(
//                   (child) => Padding(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: _SenderMessage(
//                   avatarUrl: child.commenter?.photo ??
//                       'https://i.pravatar.cc/150?img=4',
//                   name:
//                   '${child.commenter?.firstName ?? ''} ${child.commenter?.lastName ?? ''}',
//                   message: child.content ?? '',
//                   time: child.sentTime ?? '',
//                   attachments: child.attachments ?? <CommentsAttachments>[],
//                   commentId: child.id?.toString() ?? '',
//                   onUpdate: () => _showUpdateBottomSheet(
//                       context, child.id?.toString() ?? '', child.content ?? ''),
//                   onDelete: () async {
//                     final confirm = await showDialog<bool>(
//                       context: context,
//                       builder: (context) {
//                         return AlertDialog(
//                           title: const Text("Confirm Delete"),
//                           content: const Text(
//                               "Are you sure you want to delete this comment?"),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: const Text("Cancel"),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: const Text("Delete",
//                                   style: TextStyle(color: Colors.red)),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//
//                     if (confirm == true) {
//                       context
//                           .read<CommentsBloc>()
//                           .add(DeleteComment(int.parse(child.id!)));
//                     }
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   void _showReplyBottomSheet(BuildContext context, String parentId) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent, // Set to transparent for glassmorphism
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (dialogCtx) =>ClipRRect(
//           borderRadius:
//           const BorderRadius.vertical(top: Radius.circular(25)),
//           child: BackdropFilter(
//               filter:
//               ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur effect
//               child: Container(
//                   padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom,
//                     top: 16,
//                     left: 16,
//                     right: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2), // Glass effect
//                     borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(25)),
//                     border: Border.all(
//                         color: Colors.white.withOpacity(0.3), width: 1.5),
//                   ),
//                   child: _CommentBottomSheet(
//                     isReply: true,
//                     parentId: parentId,
//                     onCommentAdded: () {
//                       _commentsBloc.add(const LoadComments(id: 1, limit: 20, offset: 0));
//                     },
//                   )))),
//     );
//   }
//
//   void _showUpdateBottomSheet(BuildContext context, String commentId, String initialContent) {
//     showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent, // Set to transparent for glassmorphism
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (dialogCtx) =>ClipRRect(
//             borderRadius:
//             const BorderRadius.vertical(top: Radius.circular(25)),
//             child: BackdropFilter(
//                 filter:
//                 ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur effect
//                 child: Container(
//                   padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom,
//                     top: 16,
//                     left: 16,
//                     right: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2), // Glass effect
//                     borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(25)),
//                     border: Border.all(
//                         color: Colors.white.withOpacity(0.3), width: 1.5),
//                   ),
//                   child: _CommentBottomSheet(
//                     isReply: false,
//                     parentId: commentId,
//                     onCommentAdded: () {
//                       _commentsBloc.add(const LoadComments(id: 1, limit: 20, offset: 0));
//                     },
//                     isUpdate: true,
//                     initialContent: initialContent,
//                   ),
//                 ))));
//   }
// }
//
// class _ChatHeader extends StatelessWidget {
//   const _ChatHeader();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100.h,
//       width: double.infinity,
//       alignment: Alignment.center,
//       child: Padding(
//         padding: EdgeInsets.only(left: 0.w, right: 10.w, top: 20.h),
//         child: Row(
//           children: [
//             IconButton(
//               icon: HeroIcon(
//                 HeroIcons.chevronLeft,
//                 size: 26.sp,
//                 color: AppColors.pureWhiteColor,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             Expanded(
//               child: Center(
//                 child: CustomText(
//                   text: "Stay One Step Ahead of Cyber Threats",
//                   maxLines: 1,
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                   color: AppColors.whiteColor,
//                   size: 20.sp,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _CommentBottomSheet extends StatelessWidget {
//   final bool isReply;
//   final String parentId;
//   final VoidCallback onCommentAdded;
//   final bool isUpdate;
//   final String? initialContent;
//
//   const _CommentBottomSheet({
//     required this.isReply,
//     required this.parentId,
//     required this.onCommentAdded,
//     this.isUpdate = false,
//     this.initialContent,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return _CommentBottomSheetContent(
//       isReply: isReply,
//       parentId: parentId,
//       onCommentAdded: onCommentAdded,
//       isUpdate: isUpdate,
//       initialContent: initialContent,
//     );
//   }
// }
//
// class _CommentBottomSheetContent extends StatefulWidget {
//   final bool isReply;
//   final String parentId;
//   final VoidCallback onCommentAdded;
//   final bool isUpdate;
//   final String? initialContent;
//
//   const _CommentBottomSheetContent({
//     required this.isReply,
//     required this.parentId,
//     required this.onCommentAdded,
//     this.isUpdate = false,
//     this.initialContent,
//   });
//
//   @override
//   State<_CommentBottomSheetContent> createState() =>
//       _CommentBottomSheetContentState();
// }
//
// class _CommentBottomSheetContentState
//     extends State<_CommentBottomSheetContent> {
//   final TextEditingController controller = TextEditingController();
//   List<PlatformFile> selectedFiles = [];
//   bool isSubmitting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.isUpdate && widget.initialContent != null) {
//       controller.text = widget.initialContent!;
//     }
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<CommentsBloc, CommentsState>(
//       listener: (context, state) {
//         if (state is AddCommentLoading || state is CommentLoading) {
//           setState(() => isSubmitting = true);
//         } else if (state is CommentLoaded) {
//           setState(() => isSubmitting = false);
//           Fluttertoast.showToast(
//             msg:
//             "${widget.isReply ? 'Reply' : widget.isUpdate ? 'Comment updated' : 'Comment'} added successfully",
//           );
//           Navigator.of(context).pop();
//           widget.onCommentAdded();
//         } else if (state is CommentError) {
//           setState(() => isSubmitting = false);
//           Fluttertoast.showToast(
//             msg:
//             "Failed to ${widget.isUpdate ? 'update' : 'add'} ${widget.isReply ? 'reply' : 'comment'}",
//           );
//         }
//       },
//       builder: (context, state) {
//         print("STATE IN DIALOG $state");
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 16.w,
//             right: 16.w,
//             top: 16.h,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.isUpdate
//                       ? 'Update Comment'
//                       : widget.isReply
//                       ? 'Reply to Comment'
//                       : 'Add Comment',
//                   style: const TextStyle(
//                     color: AppColors.pureWhiteColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Row(
//                   children: [
//                     const Text('COMMENT ',
//                         style: TextStyle(color: AppColors.pureWhiteColor)),
//                     const Text('* ', style: TextStyle(color: Colors.red)),
//                   ],
//                 ),
//                 SizedBox(height: 8.h),
//                 TextField(
//                   controller: controller,
//                   minLines: 1,
//                   maxLines: 5,
//                   decoration: InputDecoration(
//                     hintText: widget.isUpdate
//                         ? "Update Comment"
//                         : "Please Enter Comment",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: AppColors.pureWhiteColor),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide:
//                       const BorderSide(color: AppColors.pureWhiteColor, width: 2),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 const Text('ATTACHMENTS (ALLOWED FILE TYPES:',style: TextStyle(color: AppColors.pureWhiteColor),),
//                 const Text(
//                   '.png, .jpg, .pdf, .doc, .docx, .xls, .xlsx, .zip, .rar, .txt, MAX FILES ALLOWED: 10)',
//                   style: TextStyle(fontSize: 10, color: AppColors.pureWhiteColor),
//                 ),
//                 SizedBox(height: 8.h),
//                 Container(
//                   height: 40.h,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.greyColor),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       TextButton(
//                         onPressed: () async {
//                           FilePickerResult? result =
//                           await FilePicker.platform.pickFiles(
//                             allowMultiple: true,
//                             type: FileType.custom,
//                             allowedExtensions: [
//                               'png',
//                               'jpg',
//                               'pdf',
//                               'doc',
//                               'docx',
//                               'xls',
//                               'xlsx',
//                               'zip',
//                               'rar',
//                               'txt'
//                             ],
//                             withData: true,
//                           );
//                           if (result != null) {
//                             setState(() {
//                               selectedFiles = result.files;
//                             });
//                           }
//                         },
//                         child: const Text('Choose Files',style: TextStyle(color: AppColors.pureWhiteColor),),
//                       ),
//                       const VerticalDivider(color: AppColors.greyColor),
//                       Expanded(
//                         child: Text(
//                           selectedFiles.isNotEmpty
//                               ? selectedFiles
//                               .map((file) => file.name)
//                               .join(', ')
//                               : 'No file chosen',
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 // Selected Files Preview
//                 SizedBox(
//                   height: selectedFiles.isNotEmpty ? 100.h : 0, // Adjust height dynamically
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: selectedFiles.length,
//                     itemBuilder: (context, index) {
//                       final file = selectedFiles[index];
//                       final isImage = file.extension!.toLowerCase() == 'png' ||
//                           file.extension!.toLowerCase() == 'jpg' ||
//                           file.extension!.toLowerCase() == 'jpeg';
//
//                       return Stack(
//                         clipBehavior: Clip.none,
//                         children: [
//                           Container(
//                             width: 80.w,
//                             margin: EdgeInsets.only(right: 12.w),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 isImage
//                                     ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.file(
//                                     File(file.path!),
//                                     width: 70.w,
//                                     height: 60.h,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                                     : Icon(
//                                   Icons.insert_drive_file,
//                                   color: Colors.blueGrey,
//                                   size: 40,
//                                 ),
//                                 SizedBox(height: 4.h),
//                                 Text(
//                                   file.name,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                       fontSize: 10, color: AppColors.greyColor),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Positioned(
//                             right: 1,
//                             top: -6,
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedFiles.removeAt(index);
//                                 });
//                               },
//                               child: const CircleAvatar(
//                                 radius: 10,
//                                 backgroundColor: AppColors.red,
//                                 child: Icon(Icons.close, size: 14, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text('Close',
//                           style: TextStyle(color: Colors.white)),
//                     ),
//                     SizedBox(width: 8.w),
//                     Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [  Color(0xff9e8efe),
//                               Color(0xffe67eff),], // Your gradient colors
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: ElevatedButton(
//
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent, // Make button transparent
//                             shadowColor: Colors.transparent, // Remove shadow
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           onPressed: isSubmitting
//                               ? null
//                               : () {
//                             if (controller.text.trim().isNotEmpty) {
//                               setState(() => isSubmitting = true);
//                               final mediaFiles = selectedFiles
//                                   .map((platformFile) =>
//                                   File(platformFile.path!))
//                                   .toList();
//                               context.read<CommentsBloc>().add(
//                                 widget.isUpdate
//                                     ? UpdateComment(
//                                   commentId: widget.parentId,
//                                   content: controller.text.trim(),
//                                   media: mediaFiles,
//                                 )
//                                     : AddComment(
//                                   modelType: 'App\\Models\\Project',
//                                   modelId: 1,
//                                   content: controller.text.trim(),
//                                   parentId: widget.isReply
//                                       ? widget.parentId
//                                       : '',
//                                   media: mediaFiles,
//                                 ),
//                               );
//                             } else {
//                               Fluttertoast.showToast(
//                                   msg: "Comment cannot be empty");
//                             }
//                           },
//                           child: isSubmitting
//                               ? const SizedBox(
//                             height: 18,
//                             width: 18,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                               : Text(
//                             widget.isUpdate ? 'Update' : 'Submit',
//                             style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
//                           ),
//                         )),
//                   ],
//                 ),
//                 SizedBox(height: 16.h),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _ReceiverMessage extends StatefulWidget {
//   final String avatarUrl;
//   final String name;
//   final String message;
//   final String time;
//   final List<CommentsAttachments> attachments;
//   final String commentId;
//   final bool isExpanded;
//   final VoidCallback onToggleExpanded;
//   final VoidCallback onUpdate;
//   final VoidCallback onDelete;
//
//   const _ReceiverMessage({
//     required this.avatarUrl,
//     required this.name,
//     required this.message,
//     required this.time,
//     required this.attachments,
//     required this.commentId,
//     required this.isExpanded,
//     required this.onToggleExpanded,
//     required this.onUpdate,
//     required this.onDelete,
//   });
//
//   @override
//   State<_ReceiverMessage> createState() => _ReceiverMessageState();
// }
//
// class _ReceiverMessageState extends State<_ReceiverMessage> {
//   bool _showIcons = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 0, right: 10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               backgroundImage: NetworkImage(widget.avatarUrl),
//               radius: 18,
//             ),
//             SizedBox(width: 8.w),
//             Flexible(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Flexible(
//                         child: CustomText(
//                           text: widget.name,
//                           size: 12.sp,
//                           color: AppColors.pureWhiteColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           if (_showIcons) ...[
//                             InkWell(
//                               onTap: widget.onUpdate,
//                               child: HeroIcon(
//                                 HeroIcons.pencil,
//                                 size: 16.sp,
//                                 color: AppColors.pureWhiteColor,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             InkWell(
//                               onTap: widget.onDelete,
//                               child: HeroIcon(
//                                 HeroIcons.trash,
//                                 size: 16.sp,
//                                 color: AppColors.pureWhiteColor,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                           ],
//                           InkWell(
//                             onTap: widget.onToggleExpanded,
//                             child: HeroIcon(
//                               widget.isExpanded
//                                   ? HeroIcons.chevronUp
//                                   : HeroIcons.chevronDown,
//                               size: 20.sp,
//                               color: AppColors.pureWhiteColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 4.h),
//                   GestureDetector(
//                     onLongPress: () {
//                       setState(() {
//                         _showIcons = !_showIcons;
//                       });
//                     },
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         BubbleSpecialThree(
//                           text: widget.message,
//                           color: const Color(0xffd7c6fe),
//                           tail: true,
//                           textStyle: const TextStyle(
//                             color: Colors.black87,
//                             fontSize: 16,
//                           ),
//                           isSender: false,
//                         ),
//                         SizedBox(height: 4.h),
//                         Padding(
//                           padding: EdgeInsets.only(left: 25.w),
//                           child: Text(
//                             widget.time,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: AppColors.pureWhiteColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (widget.isExpanded && widget.attachments.isNotEmpty)
//                     Padding(
//                       padding: EdgeInsets.only(top: 8.h),
//                       child: Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: widget.attachments
//                             .map((attachment) => _AttachmentBubble(
//                           fileUrl: attachment.url ?? "",
//                           fileName: attachment.fileName ?? "",
//                           commentId: widget.commentId,
//                           commentContent: widget.message,
//                           attachments: widget.attachments,
//                         ))
//                             .toList(),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SenderMessage extends StatefulWidget {
//   final String avatarUrl;
//   final String name;
//   final String message;
//   final String time;
//   final List<CommentsAttachments> attachments;
//   final String commentId;
//   final VoidCallback onUpdate;
//   final VoidCallback onDelete;
//
//   const _SenderMessage({
//     required this.avatarUrl,
//     required this.name,
//     required this.message,
//     required this.time,
//     required this.attachments,
//     required this.commentId,
//     required this.onUpdate,
//     required this.onDelete,
//   });
//
//   @override
//   State<_SenderMessage> createState() => _SenderMessageState();
// }
//
// class _SenderMessageState extends State<_SenderMessage> {
//   bool _showIcons = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 12, left: 60),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               backgroundImage: widget.avatarUrl != ""
//                   ? NetworkImage(widget.avatarUrl)
//                   : const AssetImage("assets/images/png/person.png")
//               as ImageProvider,
//               radius: 18,
//             ),
//             SizedBox(width: 8.w),
//             Flexible(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomText(
//                         text: widget.name,
//                         size: 11.sp,
//                         color: AppColors.pureWhiteColor,
//                       ),
//                       if (_showIcons)
//                         Row(
//                           children: [
//                             InkWell(
//                               onTap: widget.onUpdate,
//                               child: HeroIcon(
//                                 HeroIcons.pencil,
//                                 size: 16.sp,
//                                 color: AppColors.pureWhiteColor,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             InkWell(
//                               onTap: widget.onDelete,
//                               child: HeroIcon(
//                                 HeroIcons.trash,
//                                 size: 16.sp,
//                                 color:AppColors.pureWhiteColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                   SizedBox(height: 4.h),
//                   GestureDetector(
//                     onLongPress: () {
//                       setState(() {
//                         _showIcons = !_showIcons;
//                       });
//                     },
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         BubbleSpecialThree(
//                           text: widget.message,
//                           color: AppColors.pureWhiteColor,
//                           tail: true,
//                           textStyle: const TextStyle(
//                             color: Colors.black87,
//                             fontSize: 16,
//                           ),
//                           isSender: false,
//                         ),
//                         SizedBox(height: 4.h),
//                         Padding(
//                           padding: EdgeInsets.only(left: 25.w),
//                           child: Text(
//                             widget.time,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: AppColors.pureWhiteColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (widget.attachments.isNotEmpty)
//                     Padding(
//                       padding: EdgeInsets.only(top: 8.h),
//                       child: Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: widget.attachments
//                             .map((attachment) => _AttachmentBubble(
//                           fileUrl: attachment.url ?? "",
//                           fileName: attachment.fileName ?? "",
//                           commentId: widget.commentId,
//                           commentContent: widget.message,
//                           attachments: widget.attachments,
//                         ))
//                             .toList(),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class _AttachmentBubble extends StatefulWidget {
//   final String fileUrl;
//   final String fileName;
//   final String commentId;
//   final String commentContent;
//   final List<CommentsAttachments> attachments;
//
//   const _AttachmentBubble({
//     required this.fileUrl,
//     required this.fileName,
//     required this.commentId,
//     required this.commentContent,
//     required this.attachments,
//   });
//
//   @override
//   State<_AttachmentBubble> createState() => _AttachmentBubbleState();
// }
//
// class _AttachmentBubbleState extends State<_AttachmentBubble> {
//   bool _showIcons = false;
//
//   // Map to associate file extensions with icons
//   static const Map<String, IconData> _fileTypeIcons = {
//     'png': Icons.image,
//     'jpg': Icons.image,
//     'jpeg': Icons.image,
//     'pdf': Icons.picture_as_pdf,
//     'doc': Icons.description,
//     'docx': Icons.description,
//     'xls': Icons.table_chart,
//     'xlsx': Icons.table_chart,
//     'zip': Icons.archive,
//     'rar': Icons.archive,
//     'txt': Icons.text_fields,
//   };
//
//   // Determine if the file is an image
//   bool _isImageFile(String fileName) {
//     final extension = fileName.split('.').last.toLowerCase();
//     return ['png', 'jpg', 'jpeg'].contains(extension);
//   }
//
//   // Get the appropriate icon for the file type
//   IconData _getFileIcon(String fileName) {
//     final extension = fileName.split('.').last.toLowerCase();
//     return _fileTypeIcons[extension] ?? Icons.insert_drive_file;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isImage = _isImageFile(widget.fileName);
//
//     return Padding(
//       padding: EdgeInsets.only(top: 8.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               GestureDetector(
//                 onTap: () {},
//                 onLongPress: () {
//                   setState(() {
//                     _showIcons = !_showIcons;
//                   });
//                 },
//                 child: BubbleNormalImage(
//                   id: widget.commentId,
//                   bubbleRadius: BUBBLE_RADIUS_IMAGE,
//                   padding: const EdgeInsets.all(1),
//                   color: Colors.white.withOpacity(0.7),
//                   margin: EdgeInsets.zero,
//                   image: isImage
//                       ? Image.network(
//                     widget.fileUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Icon(
//                       _getFileIcon(widget.fileName),
//                       size: 50,
//                       color: Colors.blueGrey,
//                     ),
//                   )
//                       : Icon(
//                     _getFileIcon(widget.fileName),
//                     size: 50,
//                     color: Colors.blueGrey,
//                   ),
//                   tail: true,
//                 ),
//               ),
//               if (_showIcons)
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       color: Colors.black.withOpacity(0.3),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           InkWell(
//                             onTap: () async {
//                               await _downloadFile(widget.fileUrl, widget.fileName);
//                             },
//                             child: const Icon(Icons.download,
//                                 color: Colors.white, size: 20),
//                           ),
//                           SizedBox(width: 8.w),
//                           InkWell(
//                             onTap: _deleteAttachment,
//                             child: const Icon(Icons.delete,
//                                 color: Colors.white, size: 20),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             widget.fileName,
//             style: const TextStyle(
//               fontSize: 12,
//               color: AppColors.pureWhiteColor,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<String?> _downloadFile(String fileUrl, String fileName) async {
//     try {
//       // Step 1: Get temporary directory
//       final tempDir = await getTemporaryDirectory();
//       final tempFilePath = "${tempDir.path}/$fileName";
//
//       // Step 2: Download file to temporary location
//       final dio = Dio();
//       await dio.download(
//         fileUrl,
//         tempFilePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             print("Download progress: ${(received / total * 100).toStringAsFixed(0)}%");
//           }
//         },
//       );
//
//       // Step 3: Show "Save As" dialog using SAF
//       final params = SaveFileDialogParams(sourceFilePath: tempFilePath, fileName: fileName);
//       final savedFilePath = await FlutterFileDialog.saveFile(params: params);
//
//       if (savedFilePath != null) {
//         Fluttertoast.showToast(msg: "File saved to: $savedFilePath");
//         return savedFilePath;
//       } else {
//         Fluttertoast.showToast(msg: "Save cancelled by user");
//         return null;
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Download failed: $e");
//       print("Download error: $e");
//       return null;
//     }
//   }
//
//   Future<bool> _requestStoragePermission() async {
//     // For Android 12 and below, request legacy storage permissions
//     if (Platform.isAndroid) {
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         status = await Permission.storage.request();
//       }
//       return status.isGranted;
//     }
//     // For Android 13+, no permission needed for Downloads folder
//     return true;
//   }
//
//   void _deleteAttachment() {
//     final updatedAttachments = widget.attachments
//         .where((attachment) => attachment.url != widget.fileUrl)
//         .toList();
//     context.read<CommentsBloc>().add(
//       UpdateComment(
//         commentId: widget.commentId,
//         content: widget.commentContent,
//         media: updatedAttachments
//             .map((attachment) => File(attachment.filePath ?? ''))
//             .toList(),
//       ),
//     );
//   }
// }
