import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;


class _DeliveryProvider{

  List<dynamic> deliveries = [];
  List<dynamic> deliveried = [];



  Future<List<dynamic>> GetDeliveries() async {

    final resp = await rootBundle.loadString('lib/data/delivery_items.json');

    Map dataMap = json.decode(resp);

    deliveries = dataMap['delivery'];

    return deliveries;
  }

  Future<List<dynamic>> GetDeliveried() async {

    final resp = await rootBundle.loadString('lib/data/delivery_items.json');

    Map dataMap = json.decode(resp);
    deliveried = dataMap['delivery'];

    return deliveried;
  }

}

final deliveryProvider = new _DeliveryProvider();