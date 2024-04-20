import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redit_clone/core/common/error_text.dart';
import 'package:redit_clone/core/constants/constants.dart';
import 'package:redit_clone/core/constants/firebase_sonstants.dart';
import 'package:redit_clone/core/failure.dart';
import 'package:redit_clone/core/providers/firebase_providers.dart';
import 'package:redit_clone/core/type_def.dart';
import 'package:redit_clone/models/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);

      }else{
        final GoogleSignInAccount? googUser = await _googleSignIn.signIn();
      final googleAuth = await googUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
     
      if (isFromLogin) {
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      }

      }
      

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            name: userCredential.user!.displayName ?? 'UserName NotAvailable',
            profilePic:
                userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: [
              'awesomeAns',
              'gold',
              'platinum',
              'helpful',
              'plusone',
              'rocket',
              'thankyou',
              'til',
            ]);

        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        //-> -> -> if we consider Stream as water bottle then the first drop is as stream first value
        // that are coming from Stream values
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel); // success then we send to Authcontoller
    } on FirebaseException {
      throw const ErrorText(
        error: 'Please Try Again',
      ); // it can  be null so we use !
      // we catch the exception of firebase and sen dit to next catch block
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //for guest user
  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

      UserModel userModel = UserModel(
          name: 'Guest User',
          profilePic: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: false,
          karma: 0,
          awards: []);

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel); // success then we send to Authcontoller
    } on FirebaseException {
      throw const ErrorText(
        error: 'Please Try Again',
      ); // it can  be null so we use !
      // we catch the exception of firebase and sen dit to next catch block
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  //logout user
  void logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
