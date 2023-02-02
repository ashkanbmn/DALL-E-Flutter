import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DallEGenerateScreen extends StatefulWidget {
  const DallEGenerateScreen({super.key});

  @override
  State<DallEGenerateScreen> createState() => _DallEGenerateScreenState();
}

class _DallEGenerateScreenState extends State<DallEGenerateScreen> {
  TextEditingController input = TextEditingController();
  String apiKey = "YourApiKey";
  String url = "https://api.openai.com/v1/images/generations";
  String? image;
  String errorReason = "";
  String inputWarning = "";

  void generateImage() async {
    if (input.text.isNotEmpty) {
      try {
        var data = {
          "prompt": input.text,
          "n": 1,
          "size": "256x256",
        };
        var res = await http.post(Uri.parse(url),
            headers: {
              "Authorization": "Bearer $apiKey",
              "Content-Type": "application/json"
            },
            body: jsonEncode(data));
        var jsonResponse = jsonDecode(res.body);
        if (res.statusCode != 200) {
          setState(() {
            errorReason = jsonResponse["error"]["message"];
          });
          return;
        }
        if (kDebugMode) {
          print(res.statusCode);
          print(res.body);
        }

        image = jsonResponse["data"][0]["url"];
        setState(() {});
      } on Exception catch (e) {
        setState(() {
          errorReason = e.toString();
        });
      }
    }
    else {
      inputWarning = "enter input";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DALLE"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image != null
                ? Expanded(
                    child: Image.asset(
                    image!,
                    width: 256,
                    height: 256,
                  ))
                : Expanded(
                    child: Center(
                      child: Text(
                        errorReason.isNotEmpty ? errorReason : inputWarning,
                      ),
                    ),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: _buildTextInput(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: TextField(
                controller: input,
                onSubmitted: (value) => generateImage(),
                decoration:
                    const InputDecoration.collapsed(hintText: "type ..."),
              ),
            ),
          ),
          ButtonBar(
            children: [
              Card(
                elevation: 8,
                shape: const StadiumBorder(),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    generateImage();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
