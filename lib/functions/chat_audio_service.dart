import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/utils/my_logger.dart';
import 'package:image/image.dart' as img;

class ChatAudioService {
  Future<String> sendImageMessage(String pathImageFile) async {
    final dio = Dio();
    String result;

    try {
      // Cargar y comprimir la imagen
      final originalImage = File(pathImageFile).readAsBytesSync();
      final decodedImage = img.decodeImage(originalImage)!;

      // Ajustar el tamaño o calidad de la imagen según tus necesidades
      final compressedImage = img.encodeJpg(decodedImage, quality: 75); // Calidad 75%

      // Guardar la imagen comprimida en un archivo temporal
      final tempDir = Directory.systemTemp;
      final compressedFile = File('${tempDir.path}/compressed_image.jpg')
        ..writeAsBytesSync(Uint8List.fromList(compressedImage));

      // Preparar los datos para enviar
      final formData = FormData.fromMap({
        'user_id': userDetails['user_id'],
        'request_id': driverReq['id'],
        'imagen': await MultipartFile.fromFile(
          compressedFile.path,
          filename: compressedFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '${url}api/imagen/chat',
        data: formData,
      );

      if (response.statusCode == 200) {
        // getCurrentMessages();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        result = 'failed';
      }

      // Borrar el archivo temporal
      await compressedFile.delete();

      return result;
    } catch (e) {
      print('Error: $e');
      return 'failed';
    }
  }
  Future<String> sendAudioMessage(String pathAudioFile) async {
    final dio = Dio();
    String result;
    try {
      Mylogger.print('Driver ${driverReq['id']}');
      Mylogger.print('User ${userDetails['id']}');
      Mylogger.print('Path audio $pathAudioFile');
      final formData = FormData.fromMap({
        'user_id': userDetails['user_id'],
        'request_id': driverReq['id'],
        'audio': await MultipartFile.fromFile(
          pathAudioFile,
          filename: pathAudioFile.split('/').last,
        ),
      });
      final response = await dio.post(
        '${url}api/audio/chat',
        data: formData,
      );

      Mylogger.print('Response ${response.data}');

      if (response.statusCode == 200) {
        // getCurrentMessages();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        result = 'failed';
        Mylogger.print(response.data);
      }
      return result;
    } on DioException catch (e) {
      Mylogger.print('Error dio ${e.response?.data}');

      return 'failed';
    } catch (e) {
      Mylogger.print('Error $e');
      if (e is SocketException) {
        internet = false;
      }
      return 'failed';
    }
  }
}
