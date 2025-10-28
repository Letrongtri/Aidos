// import 'package:ct312h_project/ui/comments/add_comment.dart';
// import 'package:ct312h_project/ui/comments/comment_list.dart';
// import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
// import 'package:ct312h_project/viewmodels/comment_item_view_model.dart';
// import 'package:ct312h_project/viewmodels/comment_manager.dart';
// import 'package:ct312h_project/ui/posts/detail_post_content.dart';
// import 'package:ct312h_project/viewmodels/detail_post_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class DetailPostScreen extends StatelessWidget {
//   const DetailPostScreen({
//     super.key,
//     required this.id,
//     this.focusComment = false,
//   });
//   final String id;
//   final bool focusComment;

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // ChangeNotifierProvider(
//         //   create: (_) => getIt<DetailPostManager>()..fetchPostById(id),
//         // ),
//         // ChangeNotifierProvider(create: (_) => getIt<CommentManager>()),
//       ],
//       child: _DetailPostBody(focusComment: focusComment),
//     );
//   }
// }

// class _DetailPostBody extends StatefulWidget {
//   const _DetailPostBody({this.focusComment = false});
//   final bool focusComment;

//   @override
//   State<_DetailPostBody> createState() => _DetailPostBodyState();
// }

// class _DetailPostBodyState extends State<_DetailPostBody> {
//   final FocusNode _commentFocusNode = FocusNode();
//   final TextEditingController _commentController = TextEditingController();
//   CommentItemViewModel? replyingTo;

//   String selectedValue = 'Hotest';

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (widget.focusComment) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _commentFocusNode.requestFocus();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     _commentFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final postManager = context.watch<DetailPostManager>();
//     final commentManager = context.watch<CommentManager>();

//     if (postManager.isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     if (postManager.errorMessage != null) {
//       return Center(child: Text('Lỗi: ${postManager.errorMessage}'));
//     }

//     final post = postManager.post;
//     if (post == null) {
//       return Scaffold(
//         appBar: AppBar(elevation: 0, title: Text("Aido")),
//         body: Center(child: Text("Không tìm thấy bài viết.")),
//       );
//     }

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         elevation: 0,
//         title: Text("Aido"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               showPostActionsBottomSheet(context, onUpdate: () {});
//             },
//             icon: Icon(Icons.more_horiz),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           children: [
//             DetailPostContent(post: post),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 DropdownButton<String>(
//                   value: selectedValue,
//                   underline: SizedBox(),
//                   items: <String>['Hotest', 'Newest'].map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedValue = newValue!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             Divider(),
//             CommentList(
//               postId: postManager.post!.id,
//               comments: context.watch<CommentManager>(),
//               onReply: (comment) {
//                 setState(() {
//                   replyingTo = comment;
//                 });
//                 FocusScope.of(context).requestFocus(_commentFocusNode);
//               },
//             ),
//           ],
//         ),
//       ),

//       // bottom navigation
//       bottomNavigationBar: AnimatedPadding(
//         duration: Duration(milliseconds: 200),
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: AddComment(
//           controller: _commentController,
//           focusNode: _commentFocusNode,
//           replyingTo: replyingTo,
//           onSend: (text) async {
//             await commentManager.addComment(
//               text: text,
//               postId: post.id,
//               currentUserId: 'u001', // TODO: lấy id từ session
//               parentId: replyingTo?.id,
//             );
//           },
//           onCancelReply: () {
//             setState(() {
//               replyingTo = null;
//             });
//             _commentFocusNode.unfocus();
//           },
//         ),
//       ),
//     );
//   }
// }
