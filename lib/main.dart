import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/bloc/category_spend_bloc.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/bloc/user_account_bloc.dart';
import 'package:wallet_exe/data/database_helper.dart';
import 'package:wallet_exe/data/local/user_local_data_source.dart';
import 'package:wallet_exe/fragments/login_fragment.dart';
import 'package:wallet_exe/notification/notification_manager.dart';
import 'package:wallet_exe/pages/balance_detail_page.dart';
import 'package:wallet_exe/pages/change_password_page.dart';
import 'package:wallet_exe/pages/main_page.dart';
import 'package:wallet_exe/pages/new_transaction_page.dart';
import 'package:wallet_exe/themes/theme.dart';
import 'package:wallet_exe/themes/theme_bloc.dart';
import './bloc/account_bloc.dart';
import 'fragments/account_fragment.dart';
import 'fragments/chart_fragment.dart';
import 'fragments/register_fragment.dart';
import 'fragments/setting_fragment.dart';
import 'fragments/splash_fragment.dart';
import 'fragments/transaction_fragment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  await Firebase.initializeApp();
  await UserLocalDataSource.initData();
  await NotificationManager.configureLocalTimeZone();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    var accountBloc = AccountBloc();
    var transactionBloc = TransactionBloc();
    var categoryBloc = CategoryBloc();
    var spendLimitBloc = SpendLimitBloc();
    var themeBloc = ThemeBloc();
    var userBloc = UserAccountBloc();
    var categorySpendBloc = CategorySpendBloc();
    var notificationManager = NotificationManager();
    notificationManager.initNotification();
    accountBloc.initData();
    transactionBloc.initData();
    categoryBloc.initData();
    spendLimitBloc.initData();
    themeBloc.getTheme();
    return MultiProvider(
      providers: [
        Provider<NotificationManager>.value(
          value: notificationManager,
        ),
        Provider<AccountBloc>.value(
          value: accountBloc,
        ),
        Provider<TransactionBloc>.value(
          value: transactionBloc,
        ),
        Provider<CategoryBloc>.value(
          value: categoryBloc,
        ),
        Provider<SpendLimitBloc>.value(
          value: spendLimitBloc,
        ),
        Provider<ThemeBloc>.value(
          value: themeBloc,
        ),
        Provider<UserAccountBloc>.value(
          value: userBloc,
        ),
        Provider<CategorySpendBloc>.value(
          value: categorySpendBloc,
        ),
      ],
      child: StreamBuilder<AppTheme?>(
          stream: themeBloc.outTheme,
          builder: (context, snapshot) {
            return ScreenUtilInit(
              designSize: Size(1080, 1920),
              builder: () => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Wallet exe',
                initialRoute: '/splash',
                routes: {
                  '/splash': (context) => SplashFragment(),
                  '/register': (context) => RegisterFragment(),
                  '/home': (context) => MainPage(),
                  '/login': (context) => LoginFragment(),
                  '/balance_detail_page': (context) => BalanceDetailPage(),
                  '/transaction_fragment': (context) => TransactionFragment(),
                  '/account_fragment': (context) => AccountFragment(),
                  '/char_fragment': (context) => ChartFragment(),
                  '/setting_fragment': (context) => SettingFragment(),
                  '/new_transaction_page': (context) => NewTransactionPage(),
                  '/change_password': (context) => ChangePasswordPage(),
                },
                theme: _buildThemeData(snapshot.data ?? myThemes[0]),
              ),
            );
          }),
    );
  }

  _buildThemeData(AppTheme appTheme) {
    return ThemeData(
      brightness: appTheme.theme.brightness,
      primarySwatch: appTheme.theme.primarySwatch,
      // ignore: deprecated_member_use
      accentColor: appTheme.theme.accentColor,
      fontFamily: 'Quicksand',
    );
  }
}
