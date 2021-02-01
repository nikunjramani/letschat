import 'package:permission_handler/permission_handler.dart';

class PermissionHandler{
  void getAllRequirePermission() async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
        Permission.contacts,
        Permission.phone,
        Permission.location,
      ].request();
  }

  Future<bool> getStroragePermission(Permission permission) async {
    permission.request();
    if(await permission.status.isGranted){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> checkStoragePermission(Permission permission) async {
    if(await permission.status.isGranted){
      return true;
    }else{
      return false;
    }
  }
}