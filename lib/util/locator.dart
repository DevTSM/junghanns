import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  SharedPreferences prefs1 = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => prefs1);
}