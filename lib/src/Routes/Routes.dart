
import 'package:entregas_app/src/Routes/delivery_page.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

Map<String, WidgetBuilder> getApplicationsRoutes() {
  return <String, WidgetBuilder>{
    'login': (BuildContext context) => LoginPage(),
    'entregas': (BuildContext context) => DeliveryPage(),
  };
}
