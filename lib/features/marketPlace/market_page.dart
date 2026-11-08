import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proven/core/theme/colors.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(color: AppColors.primaryContainer),
                width: double.infinity,
                height: 165,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "PROVEN",
                            style: GoogleFonts.ibmPlexSans(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 15),
                          Container(
                            width: 90,
                            height: 27,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.onPrimaryFixed,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.5),
                              child: Text(
                                "COMPANY MODE",
                                style: GoogleFonts.ibmPlexSans(
                                  color: AppColors.primaryFixedDim,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.onPrimaryFixed,
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_none_outlined,
                                color: AppColors.primaryFixedDim,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            "Find your next project",
                            style: GoogleFonts.ibmPlexSans(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 350,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                            child: SearchBar(
                              backgroundColor: WidgetStatePropertyAll(
                                AppColors.onBackground,
                              ),
                              leading: Icon(Icons.search,color: AppColors.inversePrimary,),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}