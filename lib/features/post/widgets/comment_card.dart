import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:redit_clone/features/auth/controller/auth_controller.dart';
import 'package:redit_clone/features/post/controller/post_controller.dart';

import 'package:redit_clone/models/comment_model.dart';
import 'package:redit_clone/responsive/responsive.dart';

import 'package:redit_clone/theme/pallete.dart';
import 'package:intl/intl.dart';

class Commentcard extends ConsumerWidget {
  final Comment comment;

  const Commentcard({
    super.key,
    required this.comment,
  });

  void deleComment(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deleteComment(comment, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime date = DateTime.parse(comment.createdAt.toString());

// Format the date into a human-readable string
    String formattedDate = DateFormat('dd-MM-yyyy - hh:mm').format(date);
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    
    return Responsive(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.profilePic),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '/u/${comment.username}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      comment.text,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              )),
              if(comment.profilePic==user.profilePic)
              
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              backgroundColor:
                                  currentTheme.drawerTheme.backgroundColor,
                              title: const Text('Delete Comment'),
                              content: const Text(
                                  'Are you sure you want to delete this Comment?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () {
                                      deleComment(ref, context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'))
                              ],
                            ));
                  },
    
                  // =>deletePost(ref, context),
                  icon: Icon(
                    Icons.delete,
                    color: Pallete.redColor,
                  ),
                ),
            ],
          ),
        
        ]),
      ),
    );
  }
}






///  Row(
          //   children: [
          //     if (comment.id == user.uid)
          //                         IconButton(
          //                           onPressed: () {
          //                             showDialog(
          //                                 context: context,
          //                                 builder: (context) => AlertDialog(
          //                                       backgroundColor: currentTheme
          //                                           .drawerTheme
          //                                           .backgroundColor,
          //                                       title:
          //                                           const Text('Delete Comment'),
          //                                       content: const Text(
          //                                           'Are you sure you want to delete this Comment?'),
          //                                       actions: [
          //                                         TextButton(
          //                                             onPressed: () {
          //                                               Navigator.pop(context);
          //                                             },
          //                                             child:
          //                                                 const Text('Cancel')),
          //                                         TextButton(
          //                                             onPressed: () {
          //                                               deleComment(
          //                                                   ref, context);
          //                                               Navigator.pop(context);
          //                                             },
          //                                             child:
          //                                                 const Text('Delete'))
          //                                       ],
          //                                     ));
          //                           },

          //                           // =>deletePost(ref, context),
          //                           icon: Icon(
          //                             Icons.delete,
          //                             color: Pallete.redColor,
          //                           ),
          //                         ),
          //   ],
          // ),
          