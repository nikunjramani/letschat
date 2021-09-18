import 'package:letschat/utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference{

  static Future<void> setString(String key, String value) async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return await preferences.setString(key, value);
  }
  static Future<void> setBoolean( String key,bool value) async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return await preferences.setBool(key, value);
  }
  static Future<void> setInteger(String key, int value) async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return await preferences.setInt(key, value);
  }

  static Future<String> getString(String key) async {
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return preferences.getString(key);
  }
  static Future<bool> getBool(String key) async {
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return preferences.getBool(key);
  }
  static Future<int> getInt(String key) async {
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return preferences.getInt(key);
  }


  // static Future<void> saveUserLoginSharedPreference( bool isUserLogIn) async{
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return await preferences.setBool(sharedPreferenceUserLogInKey, isUserLogIn);
  // }
  // static Future<void> saveUserNameSharedPreference(String name) async{
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   Constants.MyName=name;
  //   return await preferences.setString(sharedPreferenceUserName, name);
  // }
  //
  // static Future<void> saveUserDobSharedPreference(String dob) async{
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   Constants.MyDob=dob;
  //   return await preferences.setString(sharedPreferenceUserDob, dob);
  // }
  // static Future<void> saveUserNumberSharedPreference(String number) async{
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   Constants.MyNumber=number;
  //   return await preferences.setString(sharedPreferenceUserNumber, number);
  // }
  // static Future<void> saveUserAboutSharedPreference(String about) async{
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   Constants.MyAvoutMe=about;
  //   return await preferences.setString(sharedPreferenceUserAbout, about);
  // }
  // static Future<void> saveUserImageSharedPreference(String image) async{
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   Constants.MyImage=image;
  //   return await preferences.setString(sharedPreferenceUserImage, image);
  // }
  //
  // static Future<void> saveUserTokenSharedPreference(String token) async{
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   Constants.Token=token;
  //   return await preferences.setString(sharedPreferenceUserToken, token);
  // }
  //
  // static Future<bool> getUserLoginSharedPreference() async {
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return preferences.getBool(sharedPreferenceUserLogInKey);
  // }
  //
  // static Future<String> getUserNameSharedPreference() async {
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return preferences.getString(sharedPreferenceUserName);
  // }
  //
  // static Future<String> getUserNumberSharedPreference() async {
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return preferences.getString(sharedPreferenceUserNumber);
  // }
  // static Future<String> getUserAboutSharedPreference() async {
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return preferences.getString(sharedPreferenceUserAbout);
  // }
  // static Future<String> getUserImageSharedPreference() async {
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return preferences.getString(sharedPreferenceUserImage);
  // }
  // static Future<String> getUserDobSharedPreference() async {
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return preferences.getString(sharedPreferenceUserDob);
  // }
  //
  // static Future<String> getUserTokenSharedPreference() async {
  //   SharedPreferences preferences=await SharedPreferences.getInstance();
  //   return preferences.getString(sharedPreferenceUserToken);
  // }
}