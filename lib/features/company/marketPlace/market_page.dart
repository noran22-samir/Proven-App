import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proven/core/theme/colors.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int selectedCategoryIndex = 0;

  final List<String> categories = [
    'All (24)',
    'Healthcare',
    'E-Commerce',
    'EdTech',
    'Habit tracker',
    'Chat bots',
  ];

  final List projectsList = [
    {
      'title': 'ClinicFlow',
      'category': 'Healthcare',
      'desc': 'Comprehensive clinic operations suite with...',
      'price': '8,500 EGP',
      'tag': 'v2.4 Ready',
    },
    {
      'title': 'ShopLite',
      'category': 'E-Commerce',
      'desc': 'Lightweight multi-vendor commerce app with...',
      'price': '6,200 EGP',
      'tag': 'Mobile + Web',
    },
    {
      'title': 'EduMaster',
      'category': 'EdTech',
      'desc': 'Interactive learning management portal with...',
      'price': '7,000 EGP',
      'tag': 'v1.0 Ready',
    },
    {
      'title': 'Habitify',
      'category': 'Habit tracker',
      'desc': 'Daily goal setting and streak tracking tool...',
      'price': '4,500 EGP',
      'tag': 'Cross-platform',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Container(
                decoration: BoxDecoration(color: AppColors.primaryContainer),
                width: double.infinity,
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: 15),
                        Container(
                          width: 90,
                          height: 27,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.onPrimaryFixed,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: AppColors.borderOutline),
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
                        const Spacer(),
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
                    const SizedBox(height: 15),
                    Text(
                      "Find your next project",
                      style: GoogleFonts.ibmPlexSans(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: SearchBar(
                              backgroundColor: WidgetStatePropertyAll(
                                AppColors.onBackground,
                              ),
                              hintText: 'Search projects, e.g. booking system',
                              hintStyle: WidgetStatePropertyAll(
                                GoogleFonts.ibmPlexSans(
                                  color: AppColors.inversePrimary,
                                  fontSize: 12,
                                ),
                              ),
                              leading: Icon(
                                Icons.search,
                                color: AppColors.inversePrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            border: Border.all(color: AppColors.borderOutline),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                            icon: Icon(
                              Icons.filter_list,
                              size: 30,
                              color: AppColors.surfaceTint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderOutline),
                            color: isSelected
                                ? AppColors.onPrimaryFixedVariant
                                : AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: GoogleFonts.ibmPlexSans(
                                color: AppColors.onPrimary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderOutline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: AppColors.inversePrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "AI MATCHMAKER",
                                  style: GoogleFonts.ibmPlexSans(
                                    color: AppColors.inversePrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Not sure what you need? Ask our AI Matchmaker",
                              style: GoogleFonts.ibmPlexSans(
                                color: AppColors.onPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(color: AppColors.inverseSurface),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 30,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.borderOutline,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.primaryContainer,
                                    ),
                                                
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            "Try it",
                                            style: GoogleFonts.ibmPlexSans(
                                              color: AppColors.onPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 10,
                                          color: AppColors.tertiaryFixedDim,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Approved projects",
                          style: GoogleFonts.ibmPlexSans(
                            color: AppColors.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderOutline),
                          ),
                          child: Text(
                            "4 Available",
                            style: GoogleFonts.ibmPlexSans(
                              color: AppColors.inversePrimary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Verified IP",
                      style: GoogleFonts.ibmPlexSans(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projectsList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final project = projectsList[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderOutline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                project['category'],
                                style: GoogleFonts.ibmPlexSans(
                                  color: AppColors.inversePrimary,
                                  fontSize: 10,
                                ),
                              ),
                               Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.lightBlueAccent,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Center(
                            child: Icon(
                              Icons.lock_outline,
                              size: 28,
                              color: AppColors.inversePrimary,
                            ),
                          ),
                           SizedBox(height: 4),
                          Center(
                            child: Text(
                              project['tag'],
                              style: GoogleFonts.ibmPlexSans(
                                color: AppColors.inversePrimary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                           Spacer(),
                          Text(
                            project['title'],
                            style: GoogleFonts.ibmPlexSans(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            project['desc'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ibmPlexSans(
                              color: AppColors.inversePrimary,
                              fontSize: 10,
                            ),
                          ),
                           SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "PRICE",
                                    style: GoogleFonts.ibmPlexSans(
                                      color: AppColors.inversePrimary,
                                      fontSize: 8,
                                    ),
                                  ),
                                  Text(
                                    project['price'],
                                    style: GoogleFonts.ibmPlexSans(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.tertiary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
