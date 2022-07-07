import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/change_password_bloc.dart';
import 'package:wallet_exe/event/user_account_event.dart';
import 'package:wallet_exe/utils/validation_text.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  late ChangePasswordBloc _changePasswordBloc;
  bool _showErrorOldPassword = false;

  var _showLoading = false;
  var hiddenPassword = true;

  void _navSetting() {
    Navigator.pop(context);
  }

  void _showPassword() {
    setState(() {
      hiddenPassword = false;
    });
  }

  void _hiddenPassword() {
    setState(() {
      hiddenPassword = true;
    });
  }

  void _setSateLoading(bool state) {
    setState(() {
      _showLoading = state;
    });
  }

  void _submit() {
    ValidateError validateError = ValidateError.NULL;
    validateError = validatePassword(oldPasswordTextController.text.trim());
    if (validateError == ValidateError.NULL) {
      validateError = validatePassword(passwordTextController.text.trim());
      if (validateError == ValidateError.NULL) {
        validateError = validateConfirmPassword(
            passwordTextController.text.trim(),
            confirmPasswordTextController.text.trim());
        if (validateError == ValidateError.NULL) {
          // Validate Complete
          _setSateLoading(true);
          final oldPassword = oldPasswordTextController.text.trim();
          final password = passwordTextController.text.trim();
          _changePasswordBloc.event
              .add(ChangePasswordEvent(oldPassword, password));
        }
      }
    }
  }

  @override
  void initState() {
    _changePasswordBloc = ChangePasswordBloc();
    super.initState();
    _changePasswordBloc.changePasswordSuccess.listen((event) {
      _setSateLoading(false);
      _navSetting();
    });
    _changePasswordBloc.error.listen((event) {
      setState(() {
        _showErrorOldPassword = true;
      });
      _setSateLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Thay đổi mật khẩu'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30.0),
          width: sizeScreen.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: Colors.red)),
                child: Text(
                  ' Mật khẩu lớn hơn hoặc bằng 6 ký tự và không nhập khoảng trắng',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87),
                ),
              ),
              SizedBox(
                height: 42,
              ),
              TextField(
                controller: oldPasswordTextController,
                obscureText: hiddenPassword,
                decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                        onTap: () {
                          hiddenPassword ? _showPassword() : _hiddenPassword();
                        },
                        child: Icon(hiddenPassword
                            ? Icons.remove_red_eye_rounded
                            : Icons.remove_red_eye_outlined)),
                    border: OutlineInputBorder(),
                    hintText: 'Mật khẩu cũ'),
              ),
              _showErrorOldPassword
                  ? Text('Bạn đã nhập sai mật khẩu vui lòng nhập lại.',style: TextStyle(color: Colors.red),)
                  : Container(),
              SizedBox(
                height: 42,
              ),
              TextField(
                controller: passwordTextController,
                obscureText: hiddenPassword,
                decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                        onTap: () {
                          hiddenPassword ? _showPassword() : _hiddenPassword();
                        },
                        child: Icon(hiddenPassword
                            ? Icons.remove_red_eye_rounded
                            : Icons.remove_red_eye_outlined)),
                    border: OutlineInputBorder(),
                    hintText: 'Mật khẩu'),
              ),
              SizedBox(
                height: 32,
              ),
              TextField(
                controller: confirmPasswordTextController,
                obscureText: hiddenPassword,
                decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                        onTap: () {
                          hiddenPassword ? _showPassword() : _hiddenPassword();
                        },
                        child: Icon(hiddenPassword
                            ? Icons.remove_red_eye_rounded
                            : Icons.remove_red_eye_outlined)),
                    border: OutlineInputBorder(),
                    hintText: 'Xác thực mật khẩu'),
              ),
              SizedBox(
                height: 32,
              ),
              TextButton(
                child: Container(
                    alignment: Alignment.center,
                    width: 120,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Text(
                      'Xác nhận',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
                onPressed: _submit,
              ),
              _showLoading
                  ? Container(
                      margin: EdgeInsetsDirectional.only(top: 20),
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
