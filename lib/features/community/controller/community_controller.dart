import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:redit_clone/core/constants/constants.dart';
import 'package:redit_clone/core/providers/storage_repository_providers.dart';
import 'package:redit_clone/features/auth/controller/auth_controller.dart';
import 'package:redit_clone/features/community/repository/community_repository.dart';
import 'package:redit_clone/models/community_model.dart';
import 'package:redit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/failure.dart';
import '../../../core/utils.dart';

//display user community provider
final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

// provider for getting community by name
final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  // we dont have name parameter so we use .family on stream provider
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

//search suggestion function
final seachCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final getCommunityPostProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPost(name);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
      communityRepository: communityRepository,
      ref: ref,
      storageRepository: storageRepository);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref; // thsi is for to contact userProvider to get userId;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ??
        ''; // user null then show ''(empty string)
    CommunityModel communityModel = CommunityModel(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [uid],
        mods: [uid]);

    final result = await _communityRepository.createCommunity(communityModel);
    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully');

      Routemaster.of(context).pop();
    });
  }

//display user community function

  Stream<List<CommunityModel>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  // function for getting community by name

  Stream<CommunityModel> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  // function for copy  data before updating data in firebaseStorage
  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required CommunityModel communityModel,
  }) async {
    state = true;
    //community/profile/dhiraj_dev
    if (profileFile != null || profileWebFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'commnities/profile',
          id: communityModel.name,
          webFile: profileWebFile,
          file: profileFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => communityModel = communityModel.copyWith(avatar: r));
    }
    if (bannerFile != null ||bannerWebFile!=null) {
      //community/banner/dhiraj_dev
      final res = await _storageRepository.storeFile(

          path: 'commnities/banner', id: communityModel.name, file: bannerFile, webFile: bannerWebFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => communityModel = communityModel.copyWith(banner: r));
    }

    final res = await _communityRepository.editCommunity(communityModel);
    state = false;
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  //search suggestion function
  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  //joining  community Function,and leaving community Function,
  void joinCommunity(
      CommunityModel communityModel, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;
    if (communityModel.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(
          communityModel.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(
          communityModel.name, user.uid);
    }
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (communityModel.members.contains(user.uid)) {
        showSnackBar(context, 'Community left successfully');
      } else {
        showSnackBar(context, 'Community joined successfully');
      }
    });
  }

  //saving the moderator
  void addMods(String communityName, List<String> uids, BuildContext context)async {
   final res = await _communityRepository.addMods(communityName, uids);
   res.fold((l) => showSnackBar(context, l.message), (r) =>Routemaster.of(context).pop() );
  }


    Stream<List<Post>> getCommunityPost(String name) {
    return _communityRepository.getCommunityPost(name);
  }


}
