import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToPostType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = kIsWeb?360:120;
    double iconSize =  kIsWeb?120:60;

    final currenTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () =>navigateToPostType(context,'image'),
            child: SizedBox(
              height: cardHeightWidth,
              width: cardHeightWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: currenTheme.secondaryHeaderColor,
                elevation: 16,
                child: Center(
                  child: Icon(Icons.image_outlined, size: iconSize),
                ),
              ),
            ),
          ),
          GestureDetector(
             onTap: () =>navigateToPostType(context,'text'),
            child: SizedBox(
              height: cardHeightWidth,
              width: cardHeightWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: currenTheme.secondaryHeaderColor,
                elevation: 16,
                child: Center(
                  child: Icon(Icons.font_download_outlined, size: iconSize),
                ),
              ),
            ),
          ),
          GestureDetector(
             onTap: () =>navigateToPostType(context,'link'),
            child: SizedBox(
              height: cardHeightWidth,
              width: cardHeightWidth,
              child: Card(
                
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: currenTheme.secondaryHeaderColor,
                elevation: 16,
                child: Center(
                  child: Icon(Icons.link_outlined, size: iconSize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
