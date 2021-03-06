
import 'package:flutter/material.dart';
import 'package:ppmsweb/Navigation_UI/components/side_menu.dart';
import 'package:ppmsweb/Navigation_UI/controllers/MenuController.dart';
import 'package:ppmsweb/activity/ProfilePage/personal_deatil.dart';
import 'package:provider/provider.dart';
import '../../responsive.dart';


class ProfilePageScreen extends StatefulWidget {

  const ProfilePageScreen({Key? key}) : super(key: key);
  @override
  _ProfilePage_Screen createState() => _ProfilePage_Screen();
}

class _ProfilePage_Screen extends State<ProfilePageScreen> {
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MenuController(),
        ),
      ],
      child: const ProfilePage(),
    );

  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            const Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child:  Padding(
                padding: EdgeInsets.fromLTRB(20,20,20,20),
                child: PersonalDeatilCard(),

              ),
            ),
          ],
        ),
      ),
    );
  }
}


