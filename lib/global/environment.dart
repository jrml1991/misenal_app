import 'dart:io';

class Environment {
  static String apiURL = Platform.isAndroid
      //    ? 'http://192.168.17.226/apiboc/misenal'
      //    : 'http://192.168.17.226/apiboc/misenal';
      ? 'https://gpsboc.tigo.com.hn/apiboc/misenal'
      : 'https://gpsboc.tigo.com.hn/apiboc/misenal';
}
