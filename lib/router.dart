import 'package:flutter/material.dart';
import 'package:redit_clone/features/auth/screens/login_screen.dart';
import 'package:redit_clone/features/community/screens/edit_community_screen.dart';
import 'package:redit_clone/features/home/screens/home_screen.dart';
import 'package:redit_clone/features/post/screens/add_post__type_screen.dart';
import 'package:redit_clone/features/post/screens/add_post_screen.dart';
import 'package:redit_clone/features/post/screens/comments_screen.dart';
import 'package:redit_clone/features/user_profile/screens/edit_profile_screen.dart';
import 'package:redit_clone/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

import 'features/community/screens/add_mods_screen.dart';
import 'features/community/screens/community_screen.dart';
import 'features/community/screens/create_community_screen.dart';
import 'features/community/screens/mod_tools_screen.dart';

//loggedOut
final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});
//loggedIn
final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  //dynamic route because every community is different
  //here we use (_) in place of (route)
  //after / we use : so consider name as parameter
  // we can pass another parameter
  // like
  // '/r/:name:id' :(route) =>  MaterialPage(child:CommunityScreen(name: route.pathParameters['id']!,)),
  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )),
  '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/add-mods/:name': (routeData) => MaterialPage(
          child: AddModsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/u/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/add-post/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(
        type: routeData.pathParameters['type']!,
      )),

      '/post/:postId/comments': (route) => MaterialPage(
          child: CommentsScreen(
            
            postId: route.pathParameters['postId']!,
       
      )),

      '/add-post': (routeData) => const MaterialPage(
          child: AddPostScreen(
       
      )),
});
