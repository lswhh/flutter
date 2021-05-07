import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ScoreSelector extends StatefulWidget{
  ScoreSelectorState createState() //=> RandomWordState();
  {
    return ScoreSelectorState();
  }
}

class ScoreSelectorState extends State<ScoreSelector> {
  final _suggestions = <int>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  var _saved = <int>{};
  var average = 150;
  var initData = 150;
  void _pushSaved(){
    Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            final tiles = _saved.map(
                (var score) {
                  return ListTile(
                    title: Text(
                      score.toString(),
                      style: _biggerFont,
                    ),
                  );
                },
            );
            final divided = ListTile.divideTiles(
                context: context,
                tiles: tiles,
            ).toList();
            return Scaffold(
              appBar: AppBar(
                title: Text('Saved Scores'),
              ),
              body: ListView(children: divided),
              );
          },
        )
      );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //final wordPair = WordPair.random();
    //return Text(wordPair.asPascalCase);
    return Scaffold(
      appBar: AppBar(
        title: Text('Average Selector'),
        actions: [IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)]
      ),
      body: _buildSuggestions(),
      bottomNavigationBar: IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
    );
  }

  Widget _buildRow(int score) {
    final alreadySaved = _saved.contains(score);
    return ListTile(
      title: Text(
        score.toString(),
        style: _biggerFont,
      ),
      trailing: Icon( alreadySaved ? Icons.check_circle : Icons.check_circle_outline,
      color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if(alreadySaved == true) {
              _saved.remove(score);
          } else {
            _saved.add(score);
          }
        });
      },
    );
  }
  Widget listBuilder(context, i) {
    if (i.isOdd) return Divider(); /*2*/
    final index = i ~/ 2; /*3*/
    if (index >= _suggestions.length) {
      _suggestions.addAll(scoreGen(10)); /*4*/
    }
    if (index > 300)
      return null;
    else
      return _buildRow(_suggestions[index]);
  }
  Iterable<int> scoreGen(int count) sync* {
    int i = 0;
    while (i < count && initData < 301) {
      i++;
      yield initData++;
    }
  }
  Widget _buildSuggestions() {
    ListView listView =
    ListView.builder( padding: const EdgeInsets.all(16.0),
        reverse: false,
        itemBuilder:/*1*/ this.listBuilder,
        itemCount: 601,
        dragStartBehavior: DragStartBehavior.down );
    return listView;
  }
}