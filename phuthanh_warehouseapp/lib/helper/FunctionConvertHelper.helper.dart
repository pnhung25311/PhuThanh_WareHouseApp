// import 'package:flutter/material.dart';

class FunctionConvertHelper {
  static String convertToPublicIP(String url) {
    const localIP = '192.168.1.11';
    const publicIP = '14.224.207.115';

    if (url.contains(localIP)) {
      return url.replaceAll(localIP, publicIP);
    }
    return url;
  }
}

