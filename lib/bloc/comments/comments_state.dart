// // // import 'package:equatable/equatable.dart';
// // // import 'package:taskify/data/model/discussion/discussion_model.dart';
// // //
// // // abstract class CommentsState extends Equatable {
// // //   const CommentsState();
// // //
// // //   @override
// // //   List<Object> get props => [];
// // // }
// // //
// // // class CommentInitial extends CommentsState {}
// // //
// // // class CommentLoading extends CommentsState {}
// // //
// // //
// // // class AddCommentLoading extends CommentsState {
// // //   // final List<CommentModel> comments;
// // //   //
// // //   // const AddCommentLoading(this.comments);
// // //   //
// // //   // @override
// // //   // List<Object> get props => [comments];
// // // }
// // // class CommentLoaded extends CommentsState {
// // //   final List<CommentModel> comments;
// // //
// // //   const CommentLoaded(this.comments);
// // //
// // //   @override
// // //   List<Object> get props => [comments];
// // // }
// // //
// // // class CommentError extends CommentsState {
// // //   final String message;
// // //
// // //   const CommentError(this.message);
// // //
// // //   @override
// // //   List<Object> get props => [message];
// // // }
// // // class CommentDeleteSuccess extends CommentsState {
// // //
// // //
// // //   CommentDeleteSuccess();
// // //
// // //   @override
// // //   List<Object> get props => [];
// // // }
// // // class CommentDeleteError extends CommentsState {
// // //   final String errorMessage;
// // //
// // //   CommentDeleteError(this.errorMessage);
// // //
// // //   @override
// // //   List<Object> get props => [errorMessage];
// // // }
// // // comments_state.dart
// // import 'package:equatable/equatable.dart';
// // import 'package:taskify/data/model/discussion/discussion_model.dart';
// //
// // abstract class CommentsState extends Equatable {
// //   const CommentsState();
// //
// //   @override
// //   List<Object?> get props => [];
// // }
// //
// // class CommentInitial extends CommentsState {}
// //
// // class CommentLoading extends CommentsState {}
// //
// // class CommentLoadMoreLoading extends CommentsState {
// //   final List<CommentModel> currentComments;
// //
// //   const CommentLoadMoreLoading(this.currentComments);
// //
// //   @override
// //   List<Object?> get props => [currentComments];
// // }
// //
// // class CommentLoaded extends CommentsState {
// //   final List<CommentModel> comments;
// //
// //   const CommentLoaded(this.comments);
// //
// //   @override
// //   List<Object?> get props => [comments];
// // }
// //
// // class CommentError extends CommentsState {
// //   final String message;
// //
// //   const CommentError(this.message);
// //
// //   @override
// //   List<Object?> get props => [message];
// // }
// //
// // class CommentDeleteSuccess extends CommentsState {}
// //
// // class CommentDeleteError extends CommentsState {
// //   final String errorMessage;
// //
// //   const CommentDeleteError(this.errorMessage);
// //
// //   @override
// //   List<Object?> get props => [errorMessage];
// // }
// // comments_state.dart
// import 'package:equatable/equatable.dart';
// import 'package:taskify/data/model/discussion/discussion_model.dart';
//
// abstract class CommentsState extends Equatable {
//   const CommentsState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class CommentInitial extends CommentsState {}
//
// class CommentLoading extends CommentsState {}
//
// class CommentLoadMoreLoading extends CommentsState {
//   final List<CommentModel> currentComments;
//
//   const CommentLoadMoreLoading(this.currentComments);
//
//   @override
//   List<Object?> get props => [currentComments];
// }
//
// class CommentLoaded extends CommentsState {
//   final List<CommentModel> comments;
//
//   const CommentLoaded(this.comments);
//
//   @override
//   List<Object?> get props => [comments];
// }
//
// class CommentError extends CommentsState {
//   final String message;
//
//   const CommentError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// class CommentDeleteSuccess extends CommentsState {}
//
// class CommentDeleteError extends CommentsState {
//   final String errorMessage;
//
//   const CommentDeleteError(this.errorMessage);
//
//   @override
//   List<Object?> get props => [errorMessage];
// }
//
// class AddCommentLoading extends CommentsState {}
// comments_state.dart
import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/discussion/discussion_model.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentsState {}

class CommentEditState extends CommentsState {
  final List<CommentModel> comments;
  final String content;
  final String parentName;

  CommentEditState({
    required this.comments,
    required this.content,
    required this.parentName,
  });
}


class CommentLoading extends CommentsState {
  final List<CommentModel> currentComments;
  final bool isInitial;

  CommentLoading({required this.currentComments, this.isInitial = false});

  @override
  List<Object?> get props => [currentComments, isInitial];
}

class CommentTest extends CommentsState{}


class CommentLoadMoreLoading extends CommentsState {
  final List<CommentModel> currentComments;

  const CommentLoadMoreLoading(this.currentComments);

  @override
  List<Object?> get props => [currentComments];
}

class CommentLoaded extends CommentsState {
  final List<CommentModel> comments;

  const CommentLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentError extends CommentsState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentDeleteSuccess extends CommentsState {}

class CommentDeleteError extends CommentsState {
  final String errorMessage;

  const CommentDeleteError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class AddCommentLoading extends CommentsState {}