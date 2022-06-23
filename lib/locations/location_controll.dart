import 'package:geocoding/geocoding.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class LocationController extends GetxController {
  Placemark _placemark = Placemark();
  Placemark get pickPlaceMark => _placemark;
}
