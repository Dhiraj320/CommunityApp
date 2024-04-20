import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:redit_clone/core/failure.dart';
import 'package:redit_clone/core/providers/firebase_providers.dart';
import 'package:redit_clone/core/type_def.dart';
import 'package:redit_clone/models/community_model.dart';
import 'package:redit_clone/models/post_model.dart';

import '../../../core/constants/firebase_sonstants.dart';

//provider of CommunityRepository
final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  //private variable =_firestore.
  //constructor
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

// for creating a  community use createCommunity() funct type is FutureVoid because it provide future errror

  FutureVoid createCommunity(CommunityModel communityModel) async {
    //communityModel accept through function parameter
    try {
      //cummunity Model access
      var communityDoc = await _communities.doc(communityModel.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name is already exists'; // it throw in catch block if there is community already exists
      }
      // else already not exists then created community
      return right(
          _communities.doc(communityModel.name).set(communityModel.toMap()));
    } on FirebaseException catch (e) {
      //throwing error for we use both way
      return left(Failure(e.message!));
      //or
      //throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
      //or
      // throw e.toString();
    }
  }

// making private because we dont want access other class
  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);

  // to display the community that user is part of that community
  //we display that user community not all the community
  Stream<List<CommunityModel>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<CommunityModel> commuinities = [];
      for (var doc in event.docs) {
        commuinities
            .add(CommunityModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return commuinities;
    });
  }

  //function for getting community by name
  Stream<CommunityModel> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((event) =>
        CommunityModel.fromMap(event.data() as Map<String, dynamic>));
  }

  // function for store in firebaseStorage
  FutureVoid editCommunity(CommunityModel communityModel) async {
    try {
      return right(
          _communities.doc(communityModel.name).update(communityModel.toMap()));
    } on FirebaseException catch (e) {
      //throwing error for we use both way
      // return left(Failure(e.message!));
      //or
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
      //or
      // throw e.toString();
    }
  }

  //search suggestion function
  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .snapshots()
        .map((event) {
      List<CommunityModel> communities = [];
      for (var community in event.docs) {
        communities.add(
            CommunityModel.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  //joining  community Function,

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),//FieldValue is used for update the array by adding this userId
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //leaving community Function,


    FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),//FieldValue is used for update the array by adding this userId
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //saving the moderator
   FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(
          _communities.doc(communityName).update({
            'mods' :uids}
          ));
    } on FirebaseException catch (e) {
      //throwing error for we use both way
      // return left(Failure(e.message!));
      //or
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
      //or
      // throw e.toString();
    }
  }


  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);





    Stream<List<Post>> getCommunityPost(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) =>
      event.docs.map((e) => Post.fromMap(e.data() as Map<String, dynamic>),).toList());
    
  }

}
