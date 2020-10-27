import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Helper/Constant.dart';

class OrderSuccess extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateSuccess();
  }
}

class StateSuccess extends State<OrderSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(ORDER_PLACED, context),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(ORD_PLC),
            ),
            Text(ORD_PLC_SUCC)
          ],
        ),
      ),
    );
  }
}
