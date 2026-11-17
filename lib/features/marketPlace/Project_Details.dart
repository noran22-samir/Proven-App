import 'package:flutter/material.dart';
import 'package:proven/features/marketPlace/market_page.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectDetails extends StatefulWidget {
  const ProjectDetails({super.key});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryContainer,AppColors.onBackground])),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.borderOutline,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.onPrimaryContainer,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      alignment: Alignment.center,
                      width: 140,
                      height: 35,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.borderOutline)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Verified IP & Code",
                          style: GoogleFonts.ibmPlexSans(),
                        ),
                      ),
                    ),
                
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderOutline)
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.share,
                            color: AppColors.onPrimaryContainer,
                            size: 20,
                          ),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.brandNavy,
        items: [
        BottomNavigationBarItem(icon: Icon(Icons.comment),label: "Contact Developer"),
        BottomNavigationBarItem(icon: Icon(Icons.lock_open_sharp),label: "Buy Project")
      ]),
    );
  }
}
