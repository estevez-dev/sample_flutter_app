import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart' as workManager;
import 'package:geolocator/geolocator.dart';
import 'package:battery/battery.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(SampleApp());

class SampleApp extends StatefulWidget {
  @override
  _SampleAppState createState() => new _SampleAppState();
  
}

class _SampleAppState extends State<SampleApp> {

  @override
  void initState() {
    workManager.Workmanager.initialize(
      updateDeviceLocation,
      isInDebugMode: false
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _msg = 'Background task not started yet';

  void _startBackgroudTask() async {
    await workManager.Workmanager.registerPeriodicTask(
          "sampleBackgroundTask",
          "sampleBackgroundTask-01",
          inputData: {
            "webhookId": 'jsgiuerngierjg',
            "httpWebHost": 'example.com'
          },
          frequency: Duration(minutes: 20),
          existingWorkPolicy: workManager.ExistingWorkPolicy.replace,
          backoffPolicy: workManager.BackoffPolicy.linear,
          backoffPolicyDelay: Duration(minutes: 20),
          constraints: workManager.Constraints(
            networkType: workManager.NetworkType.connected,
          ),
        );
    setState(() {
      _msg = 'Background task started. Tap the button.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This is the message:',
            ),
            Text(
              '$_msg',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startBackgroudTask,
        tooltip: 'Start',
        child: Icon(Icons.launch),
      ),
    );
  }
}

void updateDeviceLocation() {
  workManager.Workmanager.executeTask((backgroundTask, data) async {
    print("[Background $backgroundTask] Started");
    Geolocator geolocator = Geolocator();
    var battery = Battery();
    String webhookId = data["webhookId"];
    String httpWebHost = data["httpWebHost"];
    String logData = '==> ${DateTime.now()} [Background $backgroundTask]:';
    print("[Background $backgroundTask] Getting path for log file...");
    final logFileDirectory = await getExternalStorageDirectory();
    print("[Background $backgroundTask] Opening log file...");
    File logFile = File('${logFileDirectory.path}/sample-background-log.txt');
    print("[Background $backgroundTask] Log file path: ${logFile.path}");
    if (webhookId != null && webhookId.isNotEmpty) {
      String url = "$httpWebHost/api/webhook/$webhookId";
      Map<String, String> headers = {};
      headers["Content-Type"] = "application/json";
      Map data = {
        "type": "update_location",
        "data": {
          "gps": [],
          "gps_accuracy": 0,
          "battery": 100
        }
      };
      print("[Background $backgroundTask] Getting battery level...");
      int batteryLevel;
      try {
        batteryLevel = await battery.batteryLevel;
        print("[Background $backgroundTask] Got battery level: $batteryLevel");
      } catch(e) {
        print("[Background $backgroundTask] Error getting battery level: $e. Setting zero");
        batteryLevel = 0;
        logData += 'Battery: error, $e';
      }
      if (batteryLevel != null) {
        data["data"]["battery"] = batteryLevel;
        logData += 'Battery: success, $batteryLevel';
      } else {
        logData += 'Battery: error, level is null';
      }
      Position location;
      try {
        location = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, locationPermissionLevel: GeolocationPermission.locationAlways);
        if (location != null && location.latitude != null) {
          logData += ' || Location: success, ${location.latitude} ${location.longitude} (${location.timestamp})';
          data["data"]["gps"] = [location.latitude, location.longitude];
          data["data"]["gps_accuracy"] = location.accuracy;
          try {
            http.Response response = await http.post(
                url,
                headers: headers,
                body: json.encode(data)
            );
            if (response.statusCode >= 200 && response.statusCode < 300) {
              logData += ' || Post: success, ${response.statusCode}';
            } else {
              logData += ' || Post: error, ${response.statusCode}';
            }
          } catch(e) {
            logData += ' || Post: error, $e';
          }
        } else {
          logData += ' || Location: error, location is null';
        }
      } catch (e) {
        print("[Background $backgroundTask] Location error: $e");
        logData += ' || Location: error, $e';
      }
    } else {
      logData += 'Not configured';
    }
    print("[Background $backgroundTask] Writing log data...");
    try {
      var fileMode;
      if (logFile.existsSync() && logFile.lengthSync() < 5000000) {
        fileMode = FileMode.append;
      } else {
        fileMode = FileMode.write;
      }
      await logFile.writeAsString('$logData\n', mode: fileMode);
    } catch (e) {
      print("[Background $backgroundTask] Error writing log: $e");
    }
    print("[Background $backgroundTask] Finished.");
    return true;
  });
}
