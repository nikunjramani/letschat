import 'dart:io';

class FileHelperFunction {
  void createFolders() async {
    String mainFolder = "LetsChat";
    final path = Directory("storage/emulated/0/$mainFolder");
    if (await path.exists()) {
    } else {
      await path.create();
      await Directory(path.path + '/Media').create();
      await Directory(path.path + "/Media/Image").create();
      await Directory(path.path + "/Media/Audio").create();
      await Directory(path.path + "/Media/Documents").create();
      await Directory(path.path + "/Media/ProfilePhotos").create();
      await Directory(path.path + "/Media/VoiceNote").create();
    }
  }
}
