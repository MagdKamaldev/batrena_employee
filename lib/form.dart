import 'dart:convert';
import 'package:batrena_employee/otp_details.dart';
import 'package:geolocator/geolocator.dart';
import 'package:batrena_employee/main.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class FormScreen extends StatefulWidget {
   const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  List<dynamic> branchList = [];
  late Position userPosition;
  dynamic selectedBranch;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> get loadData  async {
    await http.get(Uri.parse("$SERVER_IP/FetchBranchList")).then((value) => branchList = jsonDecode(value.body));
    selectedBranch = branchList[0];
    userPosition = await _determinePosition();
    return true;
  }

  Future<Response> postData(String url, dynamic data) async {
    Response value = await http.post(Uri.parse(url), body: data);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: loadData,
          builder: (context, snapshot)
        {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return
             SingleChildScrollView(
               child: Padding(
                 padding: const EdgeInsets.all(10.0),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: <Widget>[
                    const Text("Please Fill Out Your Credentials", style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ), textAlign: TextAlign.center,),
                     const SizedBox(height: 30,),
                 DropdownSearch<String>(
                   // dropdownSearchTextAlign: TextAlign.left,
                   //
                   // searchFieldProps: TextFieldProps(
                   //   autocorrect: false,
                   //   cursorColor: Theme.of(context).primaryColor,
                   // ),
                   // dropdownDecoratorProps: const InputDecoration(
                   //   border: OutlineInputBorder(
                   //     borderSide: BorderSide(),
                   //   ),
                   //   labelText: "Branch*",
                   // ),
                   dropdownDecoratorProps: const DropDownDecoratorProps(
                     dropdownSearchDecoration:  InputDecoration(
                         border: OutlineInputBorder(
                           borderSide: BorderSide(),
                         ),
                         labelText: "Branch*",
                       ),
                     textAlign: TextAlign.left,
                   ),
                   // mode: Mode.MENU,

                   // showSelectedItems: true,
                   // showSearchBox: true,
                   enabled: true,
                   items: branchList.map((e) => e["name"].toString()).toList(),
                   onChanged: (item) => setState(() {
                     dynamic branch = branchList.where((element) =>
                     element["name"] == item).toList()[0];
                     selectedBranch = branch;
                   }),
                   selectedItem: selectedBranch["name"],
                 ),
                 Container(
                   padding: const EdgeInsets.symmetric(vertical: 10),
                     child: TextField(
                       autocorrect: false,
                       controller: usernameController,
                       decoration: const InputDecoration(
                         enabledBorder: OutlineInputBorder(),
                         focusedBorder: OutlineInputBorder(
                           borderSide: BorderSide(
                             color: Color(0xFF011627),
                             width: 2.5,
                           ),
                         ),
                         labelText: 'Username',
                         labelStyle: TextStyle(
                           color: Color(0xFF011627),
                           fontSize: 17,
                         ),
                       ),
                     ),
                     ),
                     Container(
                       padding: const EdgeInsets.symmetric(vertical: 10),
                       child: TextField(
                         autocorrect: false,
                         obscureText: true,
                         controller: passwordController,
                         decoration: const InputDecoration(
                           enabledBorder: OutlineInputBorder(),
                           focusedBorder: OutlineInputBorder(
                             borderSide: BorderSide(
                               color: Color(0xFF011627),
                               width: 2.5,
                             ),
                           ),
                           labelText: 'Password',
                           labelStyle: TextStyle(
                             color: Color(0xFF011627),
                             fontSize: 17,
                           ),
                         ),
                       ),
                     ),
                     ElevatedButton(onPressed: () async {
                      await postData("$SERVER_IP/GenerateShiftOTP", jsonEncode({
                         "branch_id": selectedBranch["ID"],
                         "lat_lng": {
                          "lat": userPosition.latitude,
                           "lng": userPosition.longitude,
                         },
                         "employee": {
                           "name": usernameController.text,
                           "password": passwordController.text,
                         }
                       })).then((response) {
                         if (response.statusCode == 200) {
                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OTPDetails(token: jsonDecode(response.body)["otp"],)));
                         }
                        if (response.statusCode == 401) {
                          showDialog(context: context, builder: (context) {
                            return const AlertDialog(
                              title: Text("Please Check Your Credentials"),
                            );
                          });
                        } else if (response.statusCode == 423) {
                          showDialog(context: context, builder: (context) {
                            return const AlertDialog(
                              title: Text("Please Make Sure You Are In Range Of The Selected Branch"),
                            );
                          });
                        }
                        });
                     } , child: const Text("Submit"))
                   ],
                 ),
               ),
             );
          },
        ),
      ),
    );
  }
}
