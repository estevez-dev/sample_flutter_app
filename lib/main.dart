import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(length: 3, child: LightCard()),
    );
  }
}

class LightCard extends StatefulWidget {
  LightCard({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LightCardState();
  }
}

class _LightCardState extends State<LightCard> {
  int _value = 10;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.directions_car)),
            Tab(icon: Icon(Icons.directions_transit)),
            Tab(icon: Icon(Icons.directions_bike)),
          ],
        ),
        title: Text('Tabs Demo'),
      ),
      body: TabBarView(
        children: <Widget>[
          SingleChildScrollView(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ConstrainedBox(
                      constraints: BoxConstraints.loose(Size(200, 200)),
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                  onAxisTapped: (val) {
                                    print('gauge tapped');
                                  },
                                  maximum: 255,
                                  minimum: 0,
                                  showLabels: false,
                                  showTicks: false,
                                  axisLineStyle: AxisLineStyle(
                                      thickness: 0.05,
                                      thicknessUnit: GaugeSizeUnit.factor,
                                      color: Colors.grey),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: 30,
                                      sizeUnit: GaugeSizeUnit.factor,
                                      width: 0.05,
                                      color: Colors.yellow,
                                      enableAnimation: true,
                                      animationType: AnimationType.bounceOut,
                                    ),
                                    MarkerPointer(
                                        value: 30,
                                        markerType: MarkerType.circle,
                                        markerHeight: 20,
                                        markerWidth: 20,
                                        enableDragging: true,
                                        color: Colors.red
                                        //enableAnimation: true,
                                        //animationType: AnimationType.bounceOut,
                                        )
                                  ])
                            ],
                          ))),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.lightBlue,
                    ),
                  ),
                  Container(
                    height: 200,
                    child: Slider(
                        value: _value.toDouble(),
                        min: 1.0,
                        max: 10.0,
                        divisions: 10,
                        activeColor: Colors.red,
                        inactiveColor: Colors.black,
                        label: 'Set a value',
                        onChanged: (double newValue) {
                          setState(() {
                            _value = newValue.round();
                          });
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.lightBlue,
                    ),
                  ),
                  Container(
                    height: 200,
                    child: Slider(
                        value: _value.toDouble(),
                        min: 1.0,
                        max: 10.0,
                        divisions: 10,
                        activeColor: Colors.red,
                        inactiveColor: Colors.black,
                        label: 'Set a value',
                        onChanged: (double newValue) {
                          setState(() {
                            _value = newValue.round();
                          });
                        }),
                  )
                ],
              ),
            ),
          ),
          Container(
            color: Colors.yellow,
          ),
          Container(
            color: Colors.red,
          )
        ],
      ),
    );
  }
}
