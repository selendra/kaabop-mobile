import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:wallet_apps/index.dart';
import 'package:wallet_apps/src/models/createAccountM.dart';
import 'package:wallet_apps/src/models/fmt.dart';
import 'package:wallet_apps/src/screen/main/import_user_info/import_user_info_body.dart';

class ImportUserInfo extends StatefulWidget {
  final CreateAccModel importAccModel;

  static const route = '/importUserInfo';

  ImportUserInfo(this.importAccModel);

  @override
  State<StatefulWidget> createState() {
    return ImportUserInfoState();
  }
}

class ImportUserInfoState extends State<ImportUserInfo> {
  ModelUserInfo _userInfoM = ModelUserInfo();

  PostRequest _postRequest = PostRequest();

  Backend _backend = Backend();

  LocalAuthentication _localAuth;

  @override
  void initState() {
    // print(widget.importAccModel.mnemonicList);
    AppServices.noInternetConnection(_userInfoM.globalKey);
    /* If Registering Account */
    // if (widget.passwords != null) getToken();

    super.initState();
  }

  @override
  void dispose() {
    /* Clear Everything When Pop Screen */
    _userInfoM.userNameCon.clear();
    _userInfoM.passwordCon.clear();
    _userInfoM.confirmPasswordCon.clear();
    _userInfoM.enable = false;
    super.dispose();
  }

  Future<void> _subscribeBalance() async {
    print('subscribe');
    final channel = await widget.importAccModel.sdk.api.account
        .subscribeBalance(widget.importAccModel.keyring.current.address, (res) {
      setState(() {
        widget.importAccModel.balance = res;
        widget.importAccModel.mBalance =
            Fmt.balance(widget.importAccModel.balance.freeBalance, 18);
      });
    });
    setState(() {
      widget.importAccModel.msgChannel = channel;
      print('Channel $channel');
    });
  }

  Future<void> _balanceOf(String from, String who) async {
    final res = await widget.importAccModel.sdk.api.balanceOf(from, who);
    if (res != null) {
      setState(() {
        widget.importAccModel.kpiBalance =
            BigInt.parse(res['output']).toString();
      });
    }
  }

  Future<void> _importFromMnemonic() async {
    print(" firstName ${_userInfoM.controlFirstName.text}");
    print(" Password ${_userInfoM.confirmPasswordCon.text}");

    try {
      final json = await widget.importAccModel.sdk.api.keyring.importAccount(
        widget.importAccModel.keyring,
        keyType: KeyType.mnemonic,
        key: widget.importAccModel.mnemonicList.join(" "),
        name: _userInfoM.userNameCon.text,
        password: _userInfoM.confirmPasswordCon.text,
      );
      print("My json $json");

      final acc = await widget.importAccModel.sdk.api.keyring.addAccount(
        widget.importAccModel.keyring,
        keyType: KeyType.mnemonic,
        acc: json,
        password: _userInfoM.confirmPasswordCon.text,
      );

      print("My account name ${acc.name}");
      if (acc != null) {
        _subscribeBalance();
        if (widget.importAccModel.keyring.keyPairs.length != 0) {
          _balanceOf(widget.importAccModel.keyring.keyPairs[0].address,
              widget.importAccModel.keyring.keyPairs[0].address);
        }
        await dialog(context, Text("You haved imported successfully"),
            Text('Congratulation'),
            action: FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Home.route, ModalRoute.withName('/'));
                },
                child: Text('Continue')));
      }
    } catch (e) {
      print(e.toString());
      await dialog(
        context,
        Text("Invalid mnemonic"),
        Text('Message'),
      );
      Navigator.pop(context);
    }

    //Close Dialog Loading
    Navigator.pop(context);
  }

  void switchBiometric(bool value) async {
    _localAuth = LocalAuthentication();
    await _localAuth.canCheckBiometrics.then((value) async {
      if (value == false) {
        snackBar(_userInfoM.globalKey, "Your device doesn't have finger print");
      } else {
        //   try {
        //     if (value){
        //       await authenticateBiometric(_localAuth).then((values) async {
        //         if (_userInfoM.authenticated){
        //           _userInfoM.switchBio = value;
        //           await StorageServices.setData({'bio': values}, 'biometric');
        //         }
        //       });
        //     } else {
        //       await authenticateBiometric(_localAuth).then((values) async {
        //         if(values) {
        //           _menuModel.switchBio = value;
        //           await StorageServices.removeKey('biometric');
        //         }
        //       });
        //     }
        //     // // Reset Switcher
        //     setState(() { });
        //   } catch (e) {

        //   }
      }
    });
  }

  void popScreen() {
    Navigator.pop(context);
  }

  /* Change Select Gender */
  void changeGender(String gender) async {
    // _userInfoM.genderLabel = gender;
    // setState(() {
    //   if (gender == "Male")
    //     _userInfoM.gender = "M";
    //   else
    //     _userInfoM.gender = "F";
    // });
    // await Future.delayed(Duration(milliseconds: 100), () {
    //   setState(() {
    //     /* Unfocus All Field */
    //     if (_userInfoM.gender != null)
    //       enableButton(true); /* Enable Button If User Set Gender */
    //     FocusScope.of(context).unfocus();
    //   });
    // });
  }

  void onSubmit() async {
    if (_userInfoM.userNameNode.hasFocus) {
      FocusScope.of(context).requestFocus(_userInfoM.passwordNode);
    } else if (_userInfoM.passwordNode.hasFocus) {
      FocusScope.of(context).requestFocus(_userInfoM.confirmPasswordNode);
    } else {
      FocusScope.of(context).unfocus();
      validateAll();
      if (_userInfoM.enable) await submitProfile();
    }
  }

  void onChanged(String value) {
    _userInfoM.formStateAddUserInfo.currentState.validate();
    validateAll();
  }

  String validateFirstName(String value) {
    if (_userInfoM.nodeFirstName.hasFocus) {
      _userInfoM.responseFirstname = instanceValidate.validateUserInfo(value);
      if (_userInfoM.responseFirstname == null)
        return null;
      else
        _userInfoM.responseFirstname += "user name";
    }
    return _userInfoM.responseFirstname;
  }

  String validatePassword(String value) {
    if (_userInfoM.passwordNode.hasFocus) {
      _userInfoM.responseMidname = instanceValidate.validatePin(value);
      if (_userInfoM.responseMidname == null)
        return null;
      else
        _userInfoM.responseMidname += "password";
    }
    return _userInfoM.responseMidname;
  }

  String validateConfirmPassword(String value) {
    if (_userInfoM.confirmPasswordNode.hasFocus) {
      _userInfoM.responseLastname = instanceValidate.validatePin(value);

      if (_userInfoM.responseLastname == null){
        return null;
      }
      else
        _userInfoM.responseLastname += "confirm password";
    }
    return _userInfoM.responseLastname;
  }

  void validateAll(){
    if (
      _userInfoM.userNameCon.text.isNotEmpty &&
      _userInfoM.passwordCon.text.isNotEmpty &&
      _userInfoM.confirmPasswordCon.text.isNotEmpty
    ) {
      if (_userInfoM.passwordCon.text == _userInfoM.confirmPasswordCon.text) {
        setState((){ enableButton(true);});
      }
    } else if (_userInfoM.enable) setState((){ enableButton(false);});
  }

  // Submit Profile User
  Future<void> submitProfile() async {
    // Show Loading Process
    dialogLoading(context);

    await _importFromMnemonic();
  }

  PopupMenuItem item(Map<String, dynamic> list) {
    return PopupMenuItem(
      value: list['gender'],
      child: Text("${list['gender']}"),
    );
  }

  void enableButton(bool value) => _userInfoM.enable = value;

  Widget build(BuildContext context) {
    return Scaffold(
      key: _userInfoM.globalKey,
      body: BodyScaffold(
          height: MediaQuery.of(context).size.height,
          child: ImportUserInfoBody(
              modelUserInfo: _userInfoM,
              onSubmit: onSubmit,
              onChanged: onChanged,
              changeGender: changeGender,
              validateFirstName: validateFirstName,
              validatepassword: validatePassword,
              validateConfirmPassword: validateConfirmPassword,
              submitProfile: submitProfile,
              popScreen: popScreen,
              switchBio: switchBiometric,
              item: item)),
    );
  }
}