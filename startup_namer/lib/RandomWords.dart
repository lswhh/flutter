import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class RandomWords extends StatefulWidget{
  RandomWordState createState() //=> RandomWordState();
  {
    return RandomWordState();
  }
}
class RandomWordState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
   var _saved = <WordPair>{};
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //final wordPair = WordPair.random();
    //return Text(wordPair.asPascalCase);
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: _buildSuggestions(),
    );
  }
  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon( alreadySaved ? Icons.favorite : Icons.favorite_border,
      color: alreadySaved ? Colors.red : null,
      ),
    );
  }
  Widget listBuilder(context, i) {
    if (i.isOdd) return Divider(); /*2*/
    final index = i ~/ 2; /*3*/
    if (index >= _suggestions.length) {
      _suggestions.addAll(generateWordPairs().take(10)); /*4*/
    }
    return _buildRow(_suggestions[index]);
  }
  Widget _buildSuggestions() {
    ListView listView =
    ListView.builder( padding: const EdgeInsets.all(16.0),
        itemBuilder:/*1*/ this.listBuilder);
    return listView;
  }


}