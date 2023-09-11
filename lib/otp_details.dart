import 'package:batrena_employee/form.dart';
import 'package:flutter/material.dart';

class OTPDetails extends StatelessWidget {
  const OTPDetails({super.key, required this.token});
  final String token;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text("Your OTP Is: $token"),
            TextButton(onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FormScreen()));
            }, child: const Text("Go Back"))
          ],
        ),
      ),
    );
  }
}
