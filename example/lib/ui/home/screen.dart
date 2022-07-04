import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:page_turn/page_turn.dart';

import '../common/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = GlobalKey<PageTurnState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTurn(
        key: _controller,
        backgroundColor: Colors.white,
        showDragCutoff: false,
        lastPage: const Center(child: Text('Last Page!')),
        children: <Widget>[
          for (var i = 0; i < 20; i++) AlicePage(page: i),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () {
          _controller.currentState?.goToPage(2);
        },
      ),
    );
  }
}
