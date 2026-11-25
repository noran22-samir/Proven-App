import 'package:flutter/material.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
  final VoidCallback onLogout;
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Mazen Emad";

  String university = "Ain Shams University • Computer Science";

  String bio =
      "Graduating senior passionate about building enterprise healthcare mobile apps and scalable cloud architectures. Creator of ClinicFlow.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff081726),
      appBar: AppBar(
        backgroundColor: const Color(0xff081726),
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff10243a),
            border: Border.all(color: const Color.fromARGB(164, 21, 101, 192)),
          ),
          child: Column(
            children: [
              /// HEADER
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final nameController = TextEditingController(
                            text: name,
                          );

                          final universityController = TextEditingController(
                            text: university,
                          );

                          final bioController = TextEditingController(
                            text: bio,
                          );

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Edit Profile"),

                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          labelText: "Name",
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      TextField(
                                        controller: universityController,
                                        decoration: const InputDecoration(
                                          labelText: "University",
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      TextField(
                                        controller: bioController,
                                        maxLines: 4,
                                        decoration: const InputDecoration(
                                          labelText: "Bio",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        name = nameController.text;

                                        university = universityController.text;

                                        bio = bioController.text;
                                      });

                                      Navigator.pop(context);
                                    },
                                    child: const Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );
                        },

                        icon: const Icon(Icons.edit, size: 12),

                        label: const Text(
                          "Edit",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),

                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff0a3157),
                            border: Border.all(color: Colors.lightBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "OH",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      university,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        profileTag(Icons.person, "Creator"),

                        profileTag(Icons.emoji_events, "Top Project #24"),

                        profileTag(Icons.verified, "Verified"),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12),

              /// BIO
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bio",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "OVERVIEW",
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    Text(
                      bio,
                      style: const TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12),

              /// SKILLS
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Skills & Stack",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Spacer(),

                        Text(
                          "4 Verified",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        skillChip("Flutter"),
                        skillChip("Firebase"),
                        skillChip("UI/UX"),
                        skillChip("Python"),
                      ],
                    ),
                    
                  ],
                  
                ),
              ),
            const Divider(
  color: Colors.white12,
),

Padding(
  padding: const EdgeInsets.all(12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Row(
        children: [

          Icon(
            Icons.settings_outlined,
            color: Colors.white70,
            size: 16,
          ),

          SizedBox(width: 6),

          Text(
            "Preferences",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 15),

      /// LANGUAGE
      Row(
        children: [

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Language",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  "Interface language",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
              ),
              borderRadius:
                  BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  "English",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),

                SizedBox(width: 6),

                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),

      const SizedBox(height: 15),

      /// APPEARANCE
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Text(
            "Appearance",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            "Color scheme",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [

              _themeChip("Light"),

              const SizedBox(width: 6),

              _themeChip(
                "Dark",
                selected: true,
              ),

              const SizedBox(width: 6),

              _themeChip("Auto"),
            ],
          ),
        ],
      ),

      const SizedBox(height: 20),

      const Divider(
        color: Colors.white12,
      ),

      /// VERIFICATION DETAILS
      // ListTile(
      //   contentPadding:
      //       EdgeInsets.zero,
      //   leading: const Icon(
      //     Icons.verified_user_outlined,
      //     color: Colors.white70,
      //     size: 18,
      //   ),
      //   // title: const Text(
      //   //   "Verification Details",
      //   //   style: TextStyle(
      //   //     color: Colors.white,
      //   //     fontSize: 13,
      //   //   ),
      //   // ),
      //   trailing: const Icon(
      //     Icons.arrow_forward_ios,
      //     color: Colors.white54,
      //     size: 14,
      //   ),
      //   onTap: () {

      //     ScaffoldMessenger.of(context)
      //         .showSnackBar(
      //       const SnackBar(
      //         content: Text(
      //           "Opening Verification Details",
      //         ),
      //       ),
      //     );
      //   },
      // ),

      // const Divider(
      //   color: Colors.white12,
      // ),

      /// LOGOUT
            SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(
            Icons.logout,
            color: Colors.red,
            size: 18,
          ),
          label: const Text(
            "Log Out",
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ],
  ),
),
            ],
            
          ),
        ),
      ),
    );
  }

  Widget profileTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blueAccent),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  Widget skillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff0b1c2f),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
Widget _themeChip(
  String title, {
  bool selected = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: selected
          ? Colors.blue
          : Colors.transparent,
      border: Border.all(
        color: selected
            ? Colors.blue
            : Colors.white24,
      ),
      borderRadius:
          BorderRadius.circular(4),
    ),
    child: Text(
      title,
      style: TextStyle(
        color: selected
            ? Colors.white
            : Colors.white70,
        fontSize: 11,
      ),
    ),
  );
}