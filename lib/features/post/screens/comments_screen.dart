import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redit_clone/core/common/error_text.dart';
import 'package:redit_clone/core/common/loader.dart';
import 'package:redit_clone/core/common/post_card.dart';
import 'package:redit_clone/features/auth/controller/auth_controller.dart';

import 'package:redit_clone/features/post/controller/post_controller.dart';
import 'package:redit_clone/features/post/widgets/comment_card.dart';
import 'package:redit_clone/models/post_model.dart';
import 'package:redit_clone/responsive/responsive.dart';
import 'package:redit_clone/theme/pallete.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addComment(
    Post post,
  ) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), post: post);

    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
   
    
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
        appBar: AppBar(),
        body: ref.watch(getPostByIdProvider(widget.postId)).when(
              data: (data) {
                return SingleChildScrollView(
                  child: Column(
                  
                    children: [
                      PostCard(post: data),
                      if(!isGuest)
                      Responsive(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                              onSubmitted: (value) => addComment(data),
                              controller: commentController,
                              decoration: InputDecoration(
                                  hintText: "Comment your thought?",
                                  filled: true,
                                  fillColor:
                                      currentTheme.drawerTheme.shadowColor,
                                  border: InputBorder.none)
                                  ),
                                 
                        ),
                      ),
                      ref.watch(getPostOfCommentsProvider(widget.postId)).when(
                        data: (data){
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount:data.length ,
                            itemBuilder: (BuildContext context, int index){
                              final comment =data[index];
                              return Commentcard(comment: comment); 
                
                          });
                        }, 
                         error: (error, stackTrace) {
                         
                          return  ErrorText(error: error.toString());
                
                         },
                         
                              loading: () => const Loader(),
                         )
                    ],
                  ),
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ));
  }
}
