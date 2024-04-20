import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redit_clone/core/enums/enums.dart';
import 'package:redit_clone/core/providers/storage_repository_providers.dart';
import 'package:redit_clone/core/utils.dart';
import 'package:redit_clone/features/auth/controller/auth_controller.dart';
import 'package:redit_clone/features/post/repository/post_repository.dart';
import 'package:redit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:redit_clone/models/comment_model.dart';
import 'package:redit_clone/models/community_model.dart';
import 'package:redit_clone/models/post_model.dart';

import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
      postRepository: postRepository,
      ref: ref,
      storageRepository: storageRepository);
});

final userPostsProvider =
    StreamProvider.family((ref, List<CommunityModel> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final guestPostsProvider =
    StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchGuestPosts();
});

final getPostOfCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getCommentsOfPost(postId);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      description: description,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
    );

    final result = await _postRepository.addPost(post);

    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    result.fold(
        (l) => showSnackBar(
              context,
              l.message,
            ), (r) {
      showSnackBar(
        context,
        'Post added successfully',
      );
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      link: link,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
    );

    final result = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    result.fold(
        (l) => showSnackBar(
              context,
              l.message,
            ), (r) {
      showSnackBar(
        context,
        'Post added successfully',
      );
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required File? file,
    required Uint8List? webFile
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageResult = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
      webFile: webFile
    );
    imageResult.fold(
        (l) => showSnackBar(
              context,
              l.message,
            ), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        link: r,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
      );
      final result = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      result.fold(
          (l) => showSnackBar(
                context,
                l.message,
              ), (r) {
        showSnackBar(
          context,
          'Post added successfully',
        );
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(
    Post post,
    BuildContext context,
  ) async {
    final result = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);

    result.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, 'Post deleted successfully'));
  }

  void upvote(
    Post post,
  ) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upVote(post, uid);
  }

  void downvote(
    Post post,
  ) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downVote(post, uid);
  }

  Stream<Post> getPostById(
    String postId,
  ) {
    return _postRepository.getPostById(postId);
  }

  void addComment(
      {required BuildContext context,
      required String text,
      required Post post}) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user.name,
        profilePic: user.profilePic);
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, 'Commented successfully'));
  }

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  void deleteComment(
    Comment comment,
    BuildContext context,
  ) async {
    final result = await _postRepository.deleteComment(comment);

    result.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, 'Comment deleted successfully'));
  }

  void awardPost({
    required BuildContext context,
    required Post post,
    required String award,
  }) async {
    final user = _ref.read(userProvider)!;
    final result = await _postRepository.awardPost(post, award, user.uid);
    result.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);

      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });

      Routemaster.of(context).pop();  
    });
  }

   Stream<List<Post>> fetchGuestPosts() {
    
    return _postRepository.fetchGuestPosts();
    }
  
}
