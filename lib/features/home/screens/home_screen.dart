//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redit_clone/core/constants/constants.dart';
import 'package:redit_clone/features/auth/controller/auth_controller.dart';
import 'package:redit_clone/features/home/drawers/cummunity_list_drawer.dart';
import 'package:redit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../delegate/search_community_delegate.dart';
import '../drawers/profile_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }
   void navigateToWebAddPost(BuildContext context) {
    Routemaster.of(context).push('/add-post');
  }

  


  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () => displayDrawer(context),
              icon: const Icon(Icons.menu));
        }),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: SearchCommunityDelegate(ref));
              },
              icon: const Icon(Icons.search)),
             kIsWeb? IconButton(onPressed: (){
                navigateToWebAddPost(context);
                
              }, icon: const Icon(Icons.add),): const SizedBox(),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => displayEndDrawer(context),
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
            );
          })
        ],
      ),
      body: Constants.tabWidget[_page],
      drawer:  isGuest ? 
      Dialog(

        child: Container(
          color: Pallete.drawerColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('''You are not signed in. Sign in to access more features.'''),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                
              ElevatedButton(
                 
                onPressed: () {
                 Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
               const SizedBox(width: 5),
              ElevatedButton.icon(onPressed: (){
                 ref.read(authControllerProvider.notifier).signInWithGoogle(context, true);


              }, icon: Image.asset('assets/images/google.png', height: 20, width: 20), label: const Text('Google SignIn')),

              
               
              
                ],
              ),
              
            ],
          ),
        ),
      )
       : const CommunityListDrawer(),
      endDrawer: isGuest ? Dialog(
        child: Container(
           color: Pallete.drawerColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('''You are not signed in. Sign in to access more features.'''),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                
              ElevatedButton(
                onPressed: () {
                 Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
               const SizedBox(width: 5),
              ElevatedButton.icon(onPressed: (){
                 ref.read(authControllerProvider.notifier).signInWithGoogle(context, true);


              }, icon: Image.asset('assets/images/google.png', height: 20, width: 20), label: const Text('Google SignIn')),

              
               
              
                ],
              ),
              
            ],
          ),
        ),
      )
      
      
       : const ProfileDrawer(),
      bottomNavigationBar:  isGuest || kIsWeb ? null : CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.secondaryHeaderColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Post')
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
    );
  }
}
