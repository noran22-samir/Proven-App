import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_project_state.dart';

class MyProjectCubit extends Cubit<MyProjectState> {
  MyProjectCubit() : super(MyProjectInitial());

  int selectedIndex = 0;

  List projects = [
    {
      'id': '1',
      'title': 'ClinicFlow',
      'category': 'Healthcare',
      'price': '8,500 EGP',
      'status': 'Pending',
      'subText': 'Submitted 2d ago',
    },
    {
      'id': '2',
      'title': 'ShopLite',
      'category': 'E-Commerce',
      'price': '6,200 EGP',
      'status': 'Approved',
      'subText': 'Live on Marketplace',
    },
    {
      'id': '3',
      'title': 'EduTrack',
      'category': 'EdTech',
      'price': '4,800 EGP',
      'status': 'Rejected',
      'subText': 'Needs Revision',
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