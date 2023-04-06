import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';

class ImageSelect extends StatefulWidget {
  const ImageSelect({Key? key}) : super(key: key);
  @override
  State<ImageSelect> createState() => ImageState();
}

class ImageState extends State<ImageSelect> {
  File? _image;
  String? _type;
  List<dynamic>? _urls;

final dio = Dio();

  Future<void> getImage(ImageSource source) async {
    try {
      final img = await ImagePicker().pickImage(source: source);
      if (img == null) return;
      final imgTemp = File(img.path);
      setState(() {
        _type = null;
        _urls = null;
        _image = imgTemp;
      });
      final filename = _image!.path.split('/').last;
      await uploadImage(filename);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> uploadImage(String filename) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'imagen': await MultipartFile.fromFile(_image!.path,
            filename: filename, contentType: MediaType('image', 'jpg')),
      });
      final response = await dio
          .post(
            //Link Ngrok :D
            'https://540e-2806-2f0-81a0-976-7e0d-218-ed39-b63f.ngrok.io/mangos/resultado',
            data: formData,
          )
          .timeout(const Duration(seconds: 35));
      if (response.statusCode == 200) {
        setState(() {
          _type = response.data;
        });
      } else {
        if (kDebugMode) {
          print("Error");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Color.fromARGB(78, 206, 206, 206),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.asset(
                    'assets/img/logo.png',
                    height: 40,
                  ),
                ),
                const Text(
                  'F.L.D.S.M.D.F.R.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 73, 73, 73),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 440,
            child: _image != null
                ? Image.file(_image!,
                    width: double.infinity, height: 120, fit: BoxFit.cover)
                : const ImageIcon(
                    AssetImage("assets/img/camera.png"),
                    size: 45,
                    color: Colors.black38,
                  ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(78, 206, 206, 206),
              ),
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: RichText(
                        text: TextSpan(
                          text: _type != null ? "Estado: " : "Sin imagen",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 73, 73, 73),
                              fontSize: 30,
                              fontWeight: FontWeight.w700),
                          children: <TextSpan>[
                            TextSpan(
                              text: _type ?? "",
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 73, 73, 73),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_urls != null)
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListView.builder(
                          itemCount: _urls!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(_urls![index],
                                  height: 30, fit: BoxFit.cover),
                            );
                          },
                        ),
                      )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            getImage(ImageSource.camera);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 252, 205, 27),
                            minimumSize: const Size(80, 65),
                          ),
                          child: const Text('Tomar fotografia'),
                        ),
                        const SizedBox(
                          height: 90,
                          width: 45,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 252, 205, 27),
                            minimumSize: const Size(80, 65),
                          ),
                          child: const Text('Seleccionar fotografia'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_image != null) {
                          String filename = _image!.path.split("/").last;
                          uploadImage(filename);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(192, 108, 156, 20),
                        minimumSize: const Size(220, 45),
                      ),
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
