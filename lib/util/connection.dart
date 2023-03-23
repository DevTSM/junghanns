import 'dart:developer';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:speed_test_dart/classes/server.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

class Connection{
  SpeedTestDart tester = SpeedTestDart();
  final speedTest = FlutterInternetSpeedTest();
  double _latency = 0;
  List<Server> _bestServersList=[];

  Future<double>init() async {
    try{
    final settings = await tester.getSettings();
      final servers = settings.servers;
      log(' =======>Consultando conexion<===============');
    _bestServersList=await tester.getBestServers(
        servers: servers,
      );
      _bestServersList.sort((a, b) => (a.latency.compareTo(b.latency)));
      _latency= await tester.testDownloadSpeed(servers:  _bestServersList);
      return _latency;
    }catch(e){
      log("se perdio la conexion");
      _latency=1000;
      return _latency;
    }
  }
  double init2(){
    log(' =======>Consultando conexion<===============2');
    speedTest.startTesting(
        useFastApi: true, //true(default)
        onStarted: () {
          // TODO
        },
        onCompleted: (TestResult download, TestResult upload) {
          log("${download.transferRate} ===>");
          log("${upload.transferRate} <=====");
          // TODO
        },
        onProgress: (double percent, TestResult data) {
          // TODO
        },
        onError: (String errorMessage, String speedTestError) {
          log("XXXXXXXXXX $errorMessage");
          // TODO
        },
        onDefaultServerSelectionInProgress: () {
          // TODO
          //Only when you use useFastApi parameter as true(default)
        },
        onDefaultServerSelectionDone: (Client? client) {
          // TODO
          //Only when you use useFastApi parameter as true(default)
        },
        onDownloadComplete: (TestResult data) {
          // TODO
        },
        onUploadComplete: (TestResult data) {
          // TODO
        },
    );
  return 0;
  }
  double get latency => _latency;

  bool get stableConnection => _latency<14;
}