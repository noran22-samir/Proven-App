abstract class PurchaseRequestState {}

class PurchaseRequestInitial extends PurchaseRequestState {}
class PurchaseRequestLoading extends PurchaseRequestState {}
class PurchaseRequestSuccess extends PurchaseRequestState {}
class PurchaseRequestError extends PurchaseRequestState {
  final String errorMessage;

  PurchaseRequestError(this.errorMessage);
}