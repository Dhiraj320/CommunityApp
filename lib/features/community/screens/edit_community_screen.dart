import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redit_clone/core/common/error_text.dart';
import 'package:redit_clone/core/common/loader.dart';
import 'package:redit_clone/core/constants/constants.dart';
import 'package:redit_clone/core/utils.dart';
import 'package:redit_clone/features/community/controller/community_controller.dart';
import 'package:redit_clone/models/community_model.dart';
import 'package:redit_clone/responsive/responsive.dart';
import 'package:redit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {

  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  File? bannerFile;

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() {
          bannerWebFile = res.files.first.bytes;
          
        });
      }else{
        setState(() {
        bannerFile = File(res.files.first.path!);
      });

      }
      
    }
  }

  File? profileFile;
  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() {
          profileWebFile = res.files.first.bytes;
          
        });
      }else{
        setState(() {
        profileFile = File(res.files.first.path!);
      });

      }
      
    }
  }

  void save(CommunityModel communityModel) {
    ref.read(communityControllerProvider.notifier).editCommunity(
      bannerWebFile: bannerWebFile,
      profileWebFile: profileWebFile,
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        communityModel: communityModel);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme =ref.watch(themeNotifierProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) => Scaffold(
              backgroundColor:currentTheme.secondaryHeaderColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text("Edit Community"),
                centerTitle: false,
                actions: [
                  TextButton(
                      onPressed: () => save(community),
                      child: const Text('Save'))
                ],
              ),
              body:isLoading?const Loader(): Responsive(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 200,
                    child: Stack(children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          color: currentTheme.textTheme.
                              bodyMedium!.color!,
                          child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child:bannerWebFile!=null?Image.memory(
                                      bannerWebFile!,
                                      
                                    ) : bannerFile != null
                                  ? Image.file(
                                      bannerFile!,
                                      
                                    )
                                  : community.banner.isEmpty ||
                                          community.banner ==
                                              Constants.bannerDefault
                                      ? const Center(
                                          child: Icon(Icons.camera_alt_outlined,
                                              size: 40),
                                        )
                                      : Image.network(
                                          community.banner,
                                          fit: BoxFit.cover,
                                        )),
                        ),
                      ),
                      Positioned(
                        bottom: 25,
                        left: 20,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child:profileWebFile!=null
                          ?CircleAvatar(
                            radius: 32,
                            backgroundImage: MemoryImage(profileWebFile!),
                          ) : profileFile != null
                              ? CircleAvatar(
                                  radius: 32,
                                  backgroundImage: FileImage(
                                    profileFile!,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 32,
                                  backgroundImage: NetworkImage(
                                    community.avatar,
                                  ),
                                ),
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
