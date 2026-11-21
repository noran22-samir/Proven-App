import 'package:flutter_bloc/flutter_bloc.dart';
import 'purchase_request_state.dart';

class PurchaseRequestCubit extends Cubit<PurchaseRequestState> {
  PurchaseRequestCubit() : super(PurchaseRequestInitial());

  String totalEarnings = '21,450';
  String totalRequests = '6';

  List contracts = [
    {
      'id': '1',
      'initials': 'NH',
      'companyName': 'Nile Health Group',
      'companySubtitle': 'Enterprise Healthcare',
      'status': 'Paid',
      'date': 'Oct 24, 2024',
      'projectTitle': 'ClinicFlow - Healthcare Suite',
      'purchasePrice': '8,500 EGP',
      'netReceive': '7,650 EGP',
    },
    {
      'id': '2',
      'initials': 'DR',
      'companyName': 'Delta Retail Tech',
      'companySubtitle': 'Commercial POS Solutions',
      'status': 'Completed',
      'date': 'Oct 19, 2024',
      'projectTitle': 'RetailFlow - POS Terminal',
      'purchasePrice': '6,200 EGP',
      'netReceive': '5,580 EGP',
    },
  ];

  List historyItems = [
    {
      'initials': 'EG',
      'title': 'Eagle Games - Game Development Studio',
      'subtitle': 'Mar 25, 2025 • Completed',
      'amount': '5,400 EGP',
    },
  ];

  void selectContract(int index) {
    emit(PurchaseRequestSuccess());
  }
}