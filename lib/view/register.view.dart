import 'package:campus_connect_app/models/auth/authentication.models.dart';
import 'package:campus_connect_app/services/register.service.dart';
import 'package:campus_connect_app/utils/snackbar.dart';
import 'package:campus_connect_app/view/login.view.dart';
import 'package:campus_connect_app/widgets/button.global.dart';
import 'package:campus_connect_app/widgets/spinner.widget.dart';
import 'package:campus_connect_app/widgets/text.form.global.dart';
import 'package:campus_connect_app/utils/global.colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/error.model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final Authentication model;
  late final Errors errors;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        padding: const EdgeInsets.only(top: 100),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Image(
                                  image: AssetImage("images/logo-dark.png"),
                                  height: 100,
                                  width: 100,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "CampusConnect",
                                  style: TextStyle(
                                    color: GlobalColors.mainColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  "Register an account",
                                  style: TextStyle(
                                    color: GlobalColors.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormGlobal(
                                labelText: "Username",
                                controller: usernameController,
                                obscure: false,
                                text: 'Username',
                                textInputType: TextInputType.text,
                              ),
                              //// Password Field
                              const SizedBox(
                                height: 20,
                              ),
                              // Email Address
                              TextFormGlobal(
                                labelText: "Email",
                                controller: emailController,
                                obscure: false,
                                text: 'Email',
                                textInputType: TextInputType.emailAddress,
                              ),
                              //// Password Field
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormGlobal(
                                labelText: "Password",
                                controller: passwordController,
                                obscure: true,
                                text: 'Password',
                                textInputType: TextInputType.text,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              ButtonGlobal(
                                  text: "Register",
                                  onTap: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      dynamic result =
                                          (await RegisterAPIService().register(
                                        usernameController.text,
                                        passwordController.text,
                                        emailController.text,
                                      ))!;

                                      if (result is Authentication) {
                                        model = result;
                                        if (model.success) {
                                          Get.off(() => const LoginView());
                                          generateSuccessSnackbar(
                                              "Success", model.message);
                                        }
                                      } else if (result is Errors) {
                                        errors = result;
                                        generateErrorSnackbar(
                                            "Error", errors.message);
                                        passwordController.text = "";
                                      } else {
                                        // Show an error dialog
                                        generateErrorSnackbar("Error",
                                            "An unspecified error occurred!");
                                      }
                                    } catch (e) {
                                      generateErrorSnackbar("Error",
                                          "An unspecified error occurred!");
                                      passwordController.text = "";
                                    } finally {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  })
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
              if (!isLoading)
                Container(
                  height: 50,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Get.off(() => const LoginView());
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: ModernSpinner(
                      color: GlobalColors.mainColor,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
