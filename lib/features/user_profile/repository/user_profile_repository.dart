import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:redit_clone/core/constants/firebase_sonstants.dart';
import 'package:redit_clone/core/failure.dart';
import 'package:redit_clone/core/providers/firebase_providers.dart';
import 'package:redit_clone/core/type_def.dart';
import 'package:redit_clone/models/post_model.dart';
import 'package:redit_clone/models/user_model.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
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

  Stream<List<Post>> getUserPost(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) =>
      event.docs.map((e) => Post.fromMap(e.data() as Map<String, dynamic>),).toList());
    
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'karma':user.karma,
      }));
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





}
