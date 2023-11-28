import 'dart:isolate';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Isolates Demo'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset('assets/gifs/bouncing.gif'),
            //Blocking UI
            ElevatedButton(
                onPressed: () {
                  var total = complexTask();
                  print('Result 1: $total');
                },
                child: const Text('Task 1')),
            //Isolate ensures our main thread or UI thread is still running during the complex computation
            //we use async await since spawning an isolate may take some time
            ElevatedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  //Creates a new instance of our isolate using the Isolate.spawn method
                  await Isolate.spawn(complexTask2, receivePort.sendPort);
                  receivePort.listen((total) {
                    print('Result 2: $total');
                  });
                },
                child: const Text('Task 2')),
          ],
        ),
      )),
    );
  }

  //Won't work even if we change our function to a future
  //We will need to spawn an isolate to overcome this behavior

  double complexTask() {
    var total = 0.0;
    for (var i = 0; i <= 1000000000; i++) {
      total += i;
    }
    return total;
  }
}

//Creating our isolate here
//Make sure that our isolate is out off any class; We are defining it outside our HomePage class
complexTask2(SendPort sendPort) {
  var total = 0.0;
  for (var i = 0; i <= 1000000000; i++) {
    total += i;
  }
  //in an issolate data cannot be sent directly we send data via a port where someone will be listening on the eother end
  sendPort.send(total);
}
