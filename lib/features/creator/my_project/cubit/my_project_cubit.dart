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

    //Edit the project Data and update it
    void updateProject({
      required  String projectId,
      required  String newTitle,
      required  String newCategory,
      required  String newPrice,
    })
    { for (var project in projects){
      if (project['id']== projectId){
        project['title'] == newTitle;
        project['category'] == newCategory;
        project['price'] == newPrice;

        if (project['status'] == 'Rejected'){
          project['status'] == 'Pending';
          project.remove('reason');
        }
        break;
      }
    }
    emit(MyProjectSuccess());

    }
  // To resend the rejected project again 
    void resubmitProject(String projectId){
      for(var project in projects){
        if(project['id'] == projectId){
          project['status'] == 'Pending';
          project.remove('reason');
          break;
        }
      }
      emit(MyProjectSuccess());
    }
  
  }