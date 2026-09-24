import 'poi_response.dart';

class Confirmation implements PoiResponse {
  final bool success;

  Confirmation(this.success);
}
