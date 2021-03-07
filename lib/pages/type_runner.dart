import 'package:flutter/material.dart';
import 'package:sermsuk/pages/detail_type_runner.dart';

class TypeRunner extends StatefulWidget {
  @override
  _TypeRunnerState createState() => _TypeRunnerState();
}

class _TypeRunnerState extends State<TypeRunner> {
  List<String> images = [
    'images/3k.png',
    'images/5k.png',
    'images/10k.png',
  ];

  List<String> titles = [
    '3K',
    '5K',
    '10K',
  ];

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailTypeRunner(
                  imagePath: images[index],
                  title: titles[index],
                  index: index,
                ),
              )),
          child: Image.asset(images[index]),
        ),
      ),
    );
  }
}
