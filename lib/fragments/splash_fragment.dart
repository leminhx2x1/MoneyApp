import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallet_exe/bloc/user_account_bloc.dart';
import 'package:wallet_exe/event/user_account_event.dart';

class SplashFragment extends StatefulWidget {
  const SplashFragment({Key? key}) : super(key: key);

  @override
  _SplashFragmentState createState() => _SplashFragmentState();
}

class _SplashFragmentState extends State<SplashFragment> {
  final _bloc = UserAccountBloc();

  @override
  void initState() {
    super.initState();
    _bloc.event.add(GetCurrentUserEvent());
    _bloc.userModel.listen((user) async {
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacementNamed(
          context, user != null ? '/home' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.only(top: 24),
        width: size.width,
        height: size.height,
        color: Theme.of(context).backgroundColor,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Shimmer.fromColors(
                  child: Container(
                      width: 92,
                      height: 92,
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                        color: Colors.yellow,
                      ),
                      child: SizedBox(width: 92, height: 92)),
                  baseColor: Colors.white,
                  highlightColor: Color(0xFFD3DEFD),
                ),
                Container(
                  width: 92,
                  height: 92,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'App Manager Money',
                style: TextStyle(
                    fontFamily: 'Quick Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
