import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wallet_exe/bloc/user_account_bloc.dart';
import 'package:wallet_exe/event/user_account_event.dart';
import 'package:wallet_exe/pages/main_page.dart';
import 'package:wallet_exe/utils/validation_text.dart';

class RegisterFragment extends StatefulWidget {
  const RegisterFragment({Key? key}) : super(key: key);

  @override
  _RegisterFragmentState createState() => _RegisterFragmentState();
}

class _RegisterFragmentState extends State<RegisterFragment> {
  bool hiddenPassword = true;
  final _bloc = UserAccountBloc();
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  var _showLoading = false;

  _setStateLoading(bool state) {
    setState(() {
      _showLoading = state;
    });
  }

  void _submit() {
    ValidateError validateError = ValidateError.NULL;
    if (nameTextController.text.trim().length <= 255 &&
        nameTextController.text.isNotEmpty) {
      final name = nameTextController.text.trim();
      validateError = validateEmail(emailTextController.text.trim());
      if (validateError == ValidateError.NULL) {
        final email = emailTextController.text.trim();
        validateError = validatePassword(passwordTextController.text.trim());
        if (validateError == ValidateError.NULL) {
          validateError = validateConfirmPassword(
              passwordTextController.text.trim(),
              confirmPasswordTextController.text.trim());
          if (validateError == ValidateError.NULL) {
            // Validate Complete
            _setStateLoading(true);
            final password = passwordTextController.text.trim();
            _bloc.event.add(CreateUserEvent(name, email, password));
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _bloc.userModel.listen((user) {
      _setStateLoading(false);
      if (user != null) _navHomePage();
    });
    _bloc.error.listen((error) {
      _setStateLoading(false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('${(error as FirebaseAuthException).message}'),
        ),
      );
    });
  }

  void _navHomePage() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
        ModalRoute.withName('/home'));
  }

  void _navLogin() {
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

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.only(top: 24),
        width: size.width,
        height: size.height,
        color: Theme.of(context).primaryColor,
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _navLogin,
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.all(8),
                  height: 60,
                  child: Icon(
                    Icons.keyboard_backspace_outlined,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: size.width,
                padding: EdgeInsets.only(left: 24, right: 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(60),
                      topLeft: Radius.circular(60),
                    )),
                child: Column(
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      '????ng k??',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          border: Border.all(color: Colors.red.shade200)),
                      child: Text(
                        '. T??n ng?????i d??ng t???i ??a 255 k?? t???\n\n. Email ph???i ????ng ?????nh d???ng abc@xyz.ab \n\n. M???t kh???u l???n h??n ho???c b???ng 6 k?? t???',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54),
                      ),
                    ),
                    SizedBox(
                      height: 42,
                    ),
                    TextField(
                      controller: nameTextController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'T??n ng?????i d??ng'),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    TextField(
                      controller: emailTextController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), hintText: 'Email'),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    TextField(
                      controller: passwordTextController,
                      obscureText: hiddenPassword,
                      decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                              onTap: () {
                                hiddenPassword
                                    ? _showPassword()
                                    : _hiddenPassword();
                              },
                              child: Icon(hiddenPassword
                                  ? Icons.remove_red_eye_rounded
                                  : Icons.remove_red_eye_outlined)),
                          border: OutlineInputBorder(),
                          hintText: 'M???t kh???u'),
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
                                hiddenPassword
                                    ? _showPassword()
                                    : _hiddenPassword();
                              },
                              child: Icon(hiddenPassword
                                  ? Icons.remove_red_eye_rounded
                                  : Icons.remove_red_eye_outlined)),
                          border: OutlineInputBorder(),
                          hintText: 'X??c th???c m???t kh???u'),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Text(
                            '????ng K??',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                      onPressed: _submit,
                    ),
                    _showLoading
                        ? Container(
                            margin: EdgeInsets.only(top: 20),
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'N???u b???n c?? t??i kho???n b???m ',
                        ),
                        GestureDetector(
                          onTap: _navLogin,
                          child: Text(
                            't???i ????y',
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                          ),
                        ),
                        Text(
                          ' ????? ????ng nh???p',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameTextController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }
}
