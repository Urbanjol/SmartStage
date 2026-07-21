import 'package:flutter/material.dart';
import '../models/Booking_model.dart'; // Import enum and model

class AppStateProvider with ChangeNotifier{
  //create private variables
  //track the SmartStage current process
  BookingStatus _bookingStatus = BookingStatus.searching; //uses our enumaration
  String? _errorMessage;
  bool _isNavigating = false;
  BookingStatus get bookingStatus => _bookingStatus;
  String? get errorMessage => _errorMessage;
  bool get isNavigating => _isNavigating;
  //1.Update the app_state(The state Machine)
  void setBookingStatus(BookingStatus newStatus){
    _bookingStatus = newStatus;
    _errorMessage = null; //clear errors on success
    notifyListeners();
  }
  //2.Handle "No Taxi Found" (Graph Logic: No edges found)
void handleNoTaxisFound(){
    _errorMessage = "No empty taxis found on this route right now.Try again in a moment!";
    _bookingStatus = BookingStatus.cancelled;
    notifyListeners();
}
//3.Navigation state (Useful for switching userInterface views)
void toggleNavigation(bool value){
    _isNavigating = value;
    notifyListeners();
}
//4.reset for a new search
void resetApp(){
    _bookingStatus = BookingStatus.searching;
    _errorMessage = null;
    notifyListeners();
}
}