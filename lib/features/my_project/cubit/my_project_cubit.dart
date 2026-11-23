import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_project_state.dart';

class MyProjectCubit extends Cubit<MyProjectState> {
  MyProjectCubit() : super(MyProjectInitial());

  int selectedIndex = 0;

  List projects = [
    {
      'id': '1',
      'title': 'ClinicFlow Pro',
      'category': 'HealthCare',
      'price': '8,500 EGP',
      'status': 'Pending',
      'subText': 'Nov 12, 2024',
    },
    {
      'id': '2',
      'title': 'ShopLite Mobile',
      'category': 'E-Commerce',
      'price': '6,000 EGP',
      'status': 'Pending',
      'subText': 'Nov 10, 2024',
    },
    {
      'id': '3',
      'title': 'SupportBot AI',
      'category': 'AI & Automation',
      'price': '7,800 EGP',
      'status': 'Approved',
      'subText': 'Oct 27, 2024',
    },
    {
      'id': '4',
      'title': 'Habitify',
      'category': 'Habit tracker',
      'price': '4,500 EGP',
      'status': 'Rejected',
      'subText': 'Mar 25, 2024',
      'reason': 'Please add a working demo link.',
    },
  ];

    void changeFilter(int index) {
      selectedIndex = index;
      emit(MyProjectSuccess());
    }

    void deleteProject(String projectId) {
      projects.removeWhere((project) => project['id'] == projectId);
      emit(MyProjectSuccess());
    }
  
  }