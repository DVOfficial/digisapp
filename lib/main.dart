
import 'package:digisapp/users/authentication/login_screen.dart';
import 'package:digisapp/users/userPreferences/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digisapp/users/fragments/dashboard_of_fragments.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Digisfresh App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: FutureBuilder(
        future: RememberUserPrefs.readUserInfo(),
        builder: (context, dataSnapShot)
        {
          if(dataSnapShot.data == null)
          {
            return LoginScreen();
          }
          else
          {
            return DashboardOfFragments();
          }
        },
      ),
    );
  }
}


