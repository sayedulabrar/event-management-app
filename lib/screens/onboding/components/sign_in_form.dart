import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:rive/rive.dart';
import 'package:rive_flutter/constants.dart';
import 'package:rive_flutter/service/alert_service.dart';
import 'package:rive_flutter/service/auth_service.dart';
import 'package:rive_flutter/service/navigation_service.dart';
import '../../entryPoint/entry_point.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GetIt _getIt = GetIt.instance;
  final _loginFormKey = GlobalKey<FormState>();
  String? email, password;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  bool isShowLoading = false;
  bool isShowConfetti = false;
  late SMITrigger error;
  late SMITrigger success;
  late SMITrigger reset;

  late SMITrigger confetti;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  void _onCheckRiveInit(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    artboard.addController(controller!);
    error = controller.findInput<bool>('Error') as SMITrigger;
    success = controller.findInput<bool>('Check') as SMITrigger;
    reset = controller.findInput<bool>('Reset') as SMITrigger;
  }

  void _onConfettiRiveInit(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);

    confetti = controller.findInput<bool>("Trigger explosion") as SMITrigger;
  }

  Future<void> checkUserDisabledStatus() async {
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("User not found.");
    }

    DocumentSnapshot userDoc = userQuery.docs.first;

    if (userDoc.exists && userDoc['disabled'] == true) {
      throw Exception(
          "Your account has been disabled. Please contact support.");
    }
  }

  void signIn(BuildContext context) {
    setState(() {
      isShowConfetti = true;
      isShowLoading = true;
    });

    Future.delayed(
      const Duration(seconds: 1),
      () async {
        try {
          if (_loginFormKey.currentState!.validate()) {
            _loginFormKey.currentState!.save();

            bool result = await _authService.login(email!, password!);
            await checkUserDisabledStatus();
            if (result) {
              success.fire();
              Future.delayed(
                const Duration(seconds: 2),
                () {
                  setState(() {
                    isShowLoading = false;
                  });
                  confetti.fire();
                  // Navigate & hide confetti
                  Future.delayed(const Duration(seconds: 1), () {
                    _navigationService.goBack();
                    _navigationService.pushReplacementNamed('/home');
                  });
                },
              );
              // _navigationService.pushReplacementNamed("/home");
            } else {
              throw Exception("Login failed");
            }
          } else {
            throw Exception("Form validation failed");
          }
        } catch (e) {
          error.fire();
          Future.delayed(
            const Duration(seconds: 2),
            () {
              setState(() {
                isShowLoading = false;
              });
              reset.fire();
            },
          );
          _alertService.showToast(
              text: e.toString(), icon: Icons.error_outline_outlined);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  onSaved: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (value) {
                    if (value != null &&
                        !EMAIL_VALIDATION_REGEX.hasMatch(value)) {
                      return "Email is invalid";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.email),
                    ),
                  ),
                ),
              ),
              const Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  onSaved: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  obscureText: true,
                  validator: (value) {
                    if (value != null &&
                        !PASSWORD_VALIDATION_REGEX.hasMatch(value)) {
                      return "Password is invalid";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.lock),
                    ),
                  ),
                ),
              ),
              SignInButton(
                onTap: () {
                  signIn(context);
                },
              ),
            ],
          ),
        ),
        isShowLoading
            ? CustomPositioned(
                child: RiveAnimation.asset(
                  'assets/RiveAssets/check.riv',
                  fit: BoxFit.cover,
                  onInit: _onCheckRiveInit,
                ),
              )
            : const SizedBox(),
        isShowConfetti
            ? CustomPositioned(
                scale: 6,
                child: RiveAnimation.asset(
                  "assets/RiveAssets/confetti.riv",
                  onInit: _onConfettiRiveInit,
                  fit: BoxFit.cover,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, this.scale = 1, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 100,
            width: 100,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class SignInButton extends StatefulWidget {
  final Function onTap;

  const SignInButton({Key? key, required this.onTap}) : super(key: key);

  @override
  _SignInButtonState createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: InkWell(
        onTap: () {
          setState(() {
            _isTapped = true;
          });
          widget.onTap();
          Future.delayed(Duration(milliseconds: 200), () {
            setState(() {
              _isTapped = false;
            });
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            boxShadow: _isTapped
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
              ),
            ),
            icon: const Icon(
              CupertinoIcons.arrow_right,
            ),
            label: const Text("Sign In"),
          ),
        ),
      ),
    );
  }
}
