import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:redit_clone/core/common/error_text.dart';
import 'package:redit_clone/core/common/loader.dart';
import 'package:redit_clone/core/constants/constants.dart';
import 'package:redit_clone/features/auth/controller/auth_controller.dart';
import 'package:redit_clone/features/community/controller/community_controller.dart';
import 'package:redit_clone/features/post/controller/post_controller.dart';
import 'package:redit_clone/models/post_model.dart';
import 'package:redit_clone/responsive/responsive.dart';
import 'package:redit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  

  void upVotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(
          post,
        );
  }

  void downVotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(
          post,
        );
  }

  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunityProfile(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');


  }

  void awardPost(WidgetRef ref ,BuildContext context, String award)  {
    ref.read(postControllerProvider.notifier).awardPost(
          post: post, context: context,award: award
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        DateTime date =DateTime.parse(post.createdAt.toString());

// Format the date into a human-readable string
String formattedDate = DateFormat('dd-MM-yyyy - hh:mm').format(date);
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
      final isGuest = !user.isAuthenticated;
    return Responsive(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: currentTheme.drawerTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(kIsWeb)
                  Column(
                    
                                    children: [

                                      IconButton(
                                        onPressed: isGuest? (){}: () => upVotePost(ref),
                                        icon: Icon(
                                          Constants.up,
                                          size: 30,
                                          color: post.upvotes.contains(user.uid)
                                              ? Pallete.redColor
                                              : null,
                                        ),
                                      ),
                                      Text(
                                    '${post.upvotes.length - post.downvotes.length == 0 ? '0' : post.upvotes.length - post.downvotes.length}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                   IconButton(
                                    onPressed: isGuest? (){}: () => downVotePost(ref),
                                    icon: Icon(
                                      Constants.down,
                                      size: 30,
                                      color: post.downvotes.contains(user.uid)
                                          ? Pallete.blueColor
                                          : null,
                                    ),
                                  ),
                                    ],
                                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16)
                              .copyWith(right: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            navigateToCommunityProfile(context),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              post.communityProfilePic),
                                          radius: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('r/${post.communityName}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold)),
                                            GestureDetector(
                                              onTap: () =>
                                                  navigateToUserProfile(context),
                                              child: Text('u/${post.username}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  )),
                                            ),
                                            // const SizedBox(height: 2,),
                                            Text(formattedDate, style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (post.uid == user.uid)
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  backgroundColor: currentTheme
                                                      .drawerTheme
                                                      .backgroundColor,
                                                  title:
                                                      const Text('Delete Post'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this post?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child:
                                                            const Text('Cancel')),
                                                    TextButton(
                                                        onPressed: () {
                                                          deletePost(
                                                              ref, context);
                                                          Navigator.pop(context);
                                                        },
                                                        child:
                                                            const Text('Delete'))
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
                              if(post.awards.isNotEmpty) ...[
                                const SizedBox(height: 5,),
                                 SizedBox(height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder: (context, index) {
                                    final award = post.awards[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Image.asset(Constants.awards[award]!, height: 25,),
                                    );
                                  }
                                )
                                ),
                                
                              ],
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(post.title,
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold)),
                              ),
                              if (isTypeImage)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  child: Image.network(
                                    post.link!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (isTypeLink)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 4),
                                  child: AnyLinkPreview(
                                      displayDirection:
                                          UIDirection.uiDirectionHorizontal,
                                      link: post.link!),
                                ),
                              if (isTypeText)
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: .15),
                                  child: Text(post.description!,
                                      style:  TextStyle(
                                        color: Colors.grey[600],
                                      )),
                                ),
                                
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if(!kIsWeb)
                                  
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: isGuest? (){}: () => upVotePost(ref),
                                        icon: Icon(
                                          Constants.up,
                                          size: 30,
                                          color: post.upvotes.contains(user.uid)
                                              ? Pallete.redColor
                                              : null,
                                        ),
                                      ),
                                      Text(
                                    '${post.upvotes.length - post.downvotes.length == 0 ? '0' : post.upvotes.length - post.downvotes.length}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                   IconButton(
                                    onPressed: isGuest? (){}: () => downVotePost(ref),
                                    icon: Icon(
                                      Constants.down,
                                      size: 30,
                                      color: post.downvotes.contains(user.uid)
                                          ? Pallete.blueColor
                                          : null,
                                    ),
                                  ),
                                    ],
                                  ),
                                  
                                 
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          navigateToComments(context);
                                        },
                                        icon: const Icon(
                                          Icons.comment,
                                        ),
                                      ),
                                      Text(
                                        '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ref
                                      .watch(getCommunityByNameProvider(
                                          post.communityName))
                                      .when(
                                        data: (data) {
                                          if (data.mods.contains(user.uid)) {
                                            return IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          backgroundColor:
                                                              currentTheme
                                                                  .drawerTheme
                                                                  .backgroundColor,
                                                          title: Text(
                                                            'You are Moderator,\nYou want to Delete this Post',
                                                            style: TextStyle(
                                                                color: Pallete
                                                                    .redColor),
                                                          ),
                                                          content: const Text(
                                                              'Are you sure you want to delete this post?'),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    'Cancel')),
                                                            TextButton(
                                                                onPressed: () {
                                                                  deletePost(ref,
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    'Delete'))
                                                          ],
                                                        ));
                                              },
                                              icon: const Icon(
                                                Icons.admin_panel_settings,
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                        loading: () => const Loader(),
                                        error: (error, stackTrace) =>
                                            ErrorText(error: error.toString()),
                                      ),
                                  IconButton(
                                      onPressed:isGuest? (){}: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(20),
                                                    child: GridView.builder(
                                                      shrinkWrap: true,
                                                        itemCount:
                                                            user.awards.length,
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 4,
                                                        ),
                                                        itemBuilder:
                                                            (BuildContext context,
                                                                int index) {
                                                          final award =
                                                              user.awards[index];
                                                          return Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: InkWell(
                                                              onTap: () {
                                                              awardPost(ref,context, award);
                                                              Navigator.pop(context);
                                                            },
                                                              child: Image.asset(
                                                                  Constants.awards[
                                                                      award]!),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ));
                                      },
                                      icon: const Icon(
                                          Icons.card_giftcard_outlined))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
