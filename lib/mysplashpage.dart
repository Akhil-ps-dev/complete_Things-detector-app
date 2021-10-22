//@dart=2.9
import 'package:flutter/material.dart';
import 'package:object_dection/home.dart';
import 'package:splashscreen/splashscreen.dart';

class MySplashPage extends StatefulWidget {
  const MySplashPage({Key key}) : super(key: key);


  @override
  _MySplashPageState createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
    
      seconds: 12,
      imageBackground: Image.asset("assets/back.jpg").image,
      loaderColor: Colors.pink,
      loadingText: const Text('Loading'),
      navigateAfterSeconds:const HomePage(),
    );
  }
}
