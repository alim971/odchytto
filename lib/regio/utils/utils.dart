import 'package:watcher/common/utils/utils.dart';

launchShop(String routeId, String fromStationId, String toStationId,
    Iterable<String> tariffs,
    {String seatClass = ""}) async {
  launchUrlApp(getRegioShopUrl(routeId, fromStationId, toStationId, tariffs,
      seatClass: seatClass));
}

String getRegioShopUrl(String routeId, String fromStationId, String toStationId,
    Iterable<String> tariffs,
    {String seatClass = ""}) {
  String tariffsQuery = "";
  for (String tariff in tariffs) {
    tariffsQuery += 'tariffs=$tariff&';
  }
  const String baseUrl = "https://novy.regiojet.cz/reservation/seating/";
  String query =
      "there?routeId=$routeId&fromStationId=$fromStationId&toStationId=$toStationId&$tariffsQuery";
  String url;
  if (seatClass != "") {
    url = baseUrl + query + "seatClassKey=$seatClass";
  } else {
    url = baseUrl.replaceFirst('seating', 'fare') + query;
  }
  return url;
}
