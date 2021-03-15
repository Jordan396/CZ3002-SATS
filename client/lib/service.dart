import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:async';


class Service{

  Future<int> submitSubscription({File file,String filename,String token})async{
    ///MultiPart request
    var request = http.MultipartRequest('POST', Uri.parse('https://www.getpostman.com/collections/a7e056f742d1c2da8540'));



    Map<String,String> headers={
      //"Authorization":"Bearer $token",
      "Content-type": "multipart/form-data"
    };
    /*request.files.add(
      http.MultipartFile(
        'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: filename,
        contentType: MediaType('image','jpeg'),
      ),
    );*/
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    request.headers.addAll(headers);
    request.fields.addAll({
      "class":"test",
      //"email":"test@gmail.com",
      //"id":"12345"
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);

    }

    //print("request: "+request.toString());
    /*var res = await request.send();
    print("This is response:"+res.toString());
    return res.statusCode;*/


  }
}