import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proven/core/theme/colors.dart';

class CompanyProfile extends StatelessWidget {
  const CompanyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: AppColors.primaryContainer),
                width: double.infinity,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Profile",
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        width: 470,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderOutline),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: AppColors.borderOutline,
                                  ),
                                ),
                                child: Icon(
                                  Icons.space_dashboard_rounded,
                                  color: AppColors.inversePrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Company Name",
                              style: GoogleFonts.ibmPlexSans(fontSize: 20),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.verified,
                              size: 12,
                              color: AppColors.inversePrimary,
                            ),
                            SizedBox(width: 155),
                            Container(
                              width: 75,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.onPrimaryFixed,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.borderOutline,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.5),
                                child: Text(
                                  "Company ",
                                  style: GoogleFonts.ibmPlexSans(
                                    color: AppColors.primaryFixedDim,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: 470,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderOutline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "ABOUT",
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Text about the company that using our application 'PROVEN'",
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 10,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:  AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color:AppColors.borderOutline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SETTINGS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
              
                      // Language Section
                      const Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1D354D)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3552),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF286C99),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'English',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'العربية',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Appearance',
                        style: TextStyle(
                          color: Color(0xFFD0DCE5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1520),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1D354D)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Light',
                                    style: TextStyle(
                                      color: Color(0xFF8A9BA8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3552),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF286C99),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Dark',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'System',
                                    style: TextStyle(
                                      color: Color(0xFF8A9BA8),
                                      fontWeight: FontWeight.w500,
                                    ),
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
                // Logout section soon
              // Row(
              //   children: [
              //     Container(child: IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: ));}, icon: Icon(Icons.logout,color: AppColors.error,)),),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
