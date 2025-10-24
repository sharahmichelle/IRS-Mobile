import 'package:flutter/material.dart';
import 'package:upm_drrm_irs_mobile/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User currentUser;
  

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color.fromARGB(255, 161, 29, 28);
    // dummy data
    final User currentUser = User(
      firstName: "Emman",
      middleName: "Sakay",
      lastName: "Estares",
      suffix: "II",
      email: "emanestares0228@gmail.com",
      upCampus: "UP Los Banos",
      office: "Office of the Supreme Leader",
      bldgName: "CAS",
      position: "Security Guard",
      userType: 1,
    );

    final userDetails = [
      ["Position", currentUser.toJson()["position"]],
      ["UP Organization", currentUser.toJson()["upCampus"]],
      ["Office / College", currentUser.toJson()["office"]],
      ["Building Name", currentUser.toJson()["bldgName"]],
    ];

    final List<Widget> bottomCard = [
      ListTile(
        title: Text("FAQs", style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_forward_ios_outlined),
        ),
      ),
      ListTile(
        title: Text(
          "Log out",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: Icon(Icons.logout_outlined, color: Colors.redAccent),
        ),
      ),
    ];
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          const NetworkImage(
                                "https://avatar.iran.liara.run/public/boy",
                              )
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.camera_alt,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${currentUser.firstName} ${currentUser.middleName[0]}. ${currentUser.lastName}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(currentUser.position, style: TextStyle(fontSize: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      weight: 8,
                      color: Colors.blueGrey,
                      size: 12,
                    ),
                    Text(
                      currentUser.email,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 9,
                    bottom: 9,
                  ),
                  child: Card(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: userDetails.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            userDetails[index][1].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(userDetails[index][0].toString()),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 9,
                    bottom: 9,
                  ),
                  child: Card(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(5),
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return bottomCard[index];
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
