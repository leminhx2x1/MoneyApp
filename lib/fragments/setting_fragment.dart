import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/user_account_bloc.dart';
import 'package:wallet_exe/event/user_account_event.dart';
import 'package:wallet_exe/notification/notification_manager.dart';
import 'package:wallet_exe/themes/theme.dart';
import 'package:wallet_exe/themes/theme_bloc.dart';

class SettingFragment extends StatefulWidget {
  SettingFragment();

  @override
  _SettingFragmentState createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  late ThemeBloc _bloc;
  late UserAccountBloc _userAccountBloc;
  var _loadingDeleteAccount = false;
  TimeOfDay timePushNotification = TimeOfDay.now();

  _deleteAccount() {
    final passwordTextController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Xóa tài khoản",
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Bạn chắc chắn làm điều này chứ ?\nNếu tài khoản bị xóa bạn sẽ không thể khôi phục"),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: passwordTextController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Mật khẩu'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                    },
                    child: Text('Hủy bỏ')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _loadingDeleteAccount = true;
                      });
                      _userAccountBloc.event.add(DeleteAccountUserEvent(
                          passwordTextController.text.trim()));
                      Navigator.pop(context, 'OK');
                    },
                    child: Text('Xác nhận')),
              ],
            ));
  }

  @override
  void initState() {
    _bloc = context.read<ThemeBloc>();
    _userAccountBloc = context.read<UserAccountBloc>();
    _userAccountBloc.event.add(GetTimePushNotiEvent());
    super.initState();
    _userAccountBloc.timePushNoti.listen((event) {
      setState(() {
        print("aaaa");
        timePushNotification = event;
      });
    });
    _userAccountBloc.deleteAccountSuccess.listen((event) {
      setState(() {
        _loadingDeleteAccount = false;
      });
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/setting_fragment'));
    });
    _userAccountBloc.error.listen((event) {
      setState(() {
        _loadingDeleteAccount = false;
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content:
                    Text('Xóa tài khoản không thành công ! Vui lòng thử lại.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'OK');
                      },
                      child: Text('Xác nhận')),
                ],
              ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
        child: Stack(
      children: [
        Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                StreamBuilder(
                  stream: _bloc.outTheme,
                  builder: (context, AsyncSnapshot<AppTheme?> snapshot) {
                    return ListTile(
                      title: Text('Thiết đặt màu sắc:'),
                      trailing: DropdownButton<AppTheme>(
                        hint: Text("Amber"),
                        value: snapshot.data,
                        items: myThemes.map((AppTheme appTheme) {
                          return DropdownMenuItem<AppTheme>(
                            value: appTheme,
                            child: Text(appTheme.name),
                          );
                        }).toList(),
                        onChanged: (theme) {
                          if (theme == null) return;
                          final index = myThemes.indexOf(theme);
                          if (index != -1) {
                            _bloc.saveTheme(index);
                          }
                          _bloc.inTheme(theme);
                        },
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 4,
                ),
                Divider(
                  height: 2,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      var newTime = await showTimePicker(
                          context: context, initialTime: timePushNotification);
                      if (newTime != null) {
                        context
                            .read<NotificationManager>()
                            .scheduleDailyPushNotification(
                                newTime.hour, newTime.minute);
                        _userAccountBloc.event.add(SaveTimePushNotiEvent(
                            hours: newTime.hour, minute: newTime.minute));
                      }
                      setState(() {
                        timePushNotification = newTime ?? timePushNotification;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Thời gian nhắc nhở  ',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${timePushNotification.hour} : ${timePushNotification.minute}",
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Divider(
                  height: 2,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/change_password');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Thay đổi mật khẩu',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_right,
                            size: 32,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Divider(
                  height: 2,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: _deleteAccount,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Xóa tài khoản',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_right,
                            size: 32,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Divider(
                  height: 2,
                  color: Colors.grey,
                ),
              ],
            )),
        Visibility(
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text('Đang xóa .....'),
                ],
              ),
            ),
            width: screenSize.width,
            height: screenSize.height,
          ),
          visible: _loadingDeleteAccount,
        ),
      ],
    ));
  }
}
