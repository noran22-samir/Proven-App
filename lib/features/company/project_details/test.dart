import 'package:flutter/material.dart';

class ProjectDetailsPage extends StatelessWidget {
  final Map project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff081726),
      appBar: AppBar(
        backgroundColor: const Color(0xff081726),
        elevation: 0,
        title: const Text("Project Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// COVER IMAGE
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.network(
                          "https://picsum.photos/800/400",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            "Pending Review",
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    color: const Color(0xff112236),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Tablet & ECG Interface View",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          "1920 x 1080px",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// META DATA
            Row(
              children: const [
                Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.white54,
                  size: 14,
                ),

                SizedBox(width: 5),

                Text("--", style: TextStyle(color: Colors.white54)),

                Spacer(),

                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white54,
                  size: 14,
                ),

                SizedBox(width: 5),

                Text(
                  "Submitted on 13 Oct 2026",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// CATEGORY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                project['category'],
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),

            const SizedBox(height: 12),

            /// PROJECT NAME
            Text(
              project['title'] ?? 'No Title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Healthcare Management Suite • Version 2.4",
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),

            const SizedBox(height: 16),

            /// PRICE CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff112236),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PROPOSED LISTING PRICE",
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          project['price'] ?? "\$0.00",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(width: 1, height: 45, color: Colors.white12),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Standard License",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Royalty split: 85% creator",
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// CREATOR DETAILS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff112236),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        "CREATOR DETAILS",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Admin Verified",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          "OH",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Text(
                                  "Omar Hassan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.green,
                                ),
                              ],
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Owner: masan@provenplus.com",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),

                            SizedBox(height: 2),

                            Text(
                              "Verified Student - Ain Shams University",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      skillTag("Flutter"),
                      skillTag("Dart"),
                      skillTag("Firebase Auth"),
                      skillTag("SQLite Offline"),
                      skillTag("UI/UX Clinical"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff112236),
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "DESCRIPTION",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Text(
                    project['desc'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Architecture",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                "Clean / BLoC",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Compliance",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                "HIPAA Ready\n(AES-256)",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff112236),
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),

                      const SizedBox(width: 6),

                      const Text(
                        "VERIFICATION LINKS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Review Sandbox",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_circle_outline, size: 16),
                          label: const Text("Live Demo"),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.code, size: 16),
                          label: const Text("Source Code"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Colors.green,
                        size: 16,
                      ),

                      const SizedBox(width: 6),

                      const Expanded(
                        child: Text(
                          "Static analysis: 0 Critical, 0 Vulnerabilities",
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "ScanQueue: Pass",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    bottomNavigationBar: Container(
  padding: const EdgeInsets.all(12),
  decoration: const BoxDecoration(
    color: Color(0xff081726),
    border: Border(
      top: BorderSide(
        color: Colors.white12,
      ),
    ),
  ),
  child: Row(
    children: [

      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            size: 16,
          ),
          label: const Text("Reject"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(
              color: Colors.white24,
            ),
            minimumSize: const Size(
              double.infinity,
              50,
            ),
          ),
        ),
      ),

      const SizedBox(width: 10),

      Expanded(
        child: ElevatedButton.icon(
          onPressed: () {

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  "Project Approved ✅",
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.check_circle_outline,
            size: 16,
          ),
          label: const Text("Approve"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A4D7A),
            foregroundColor: Colors.white,
            minimumSize: const Size(
              double.infinity,
              50,
            ),
          ),
        ),
      ),
    ],
  ),
),
    );
  }

  Widget skillTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}