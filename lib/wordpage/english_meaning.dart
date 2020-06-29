import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:toast/toast.dart';

class EnglishMeaning extends StatefulWidget {
  EnglishMeaning({Key key, this.unit}) : super(key: key);

  final Map unit;

  @override
  _EnglishMeaningState createState() => _EnglishMeaningState();
}

class _EnglishMeaningState extends State<EnglishMeaning>
    with SingleTickerProviderStateMixin {
  final databaseReference = Firestore.instance;

  DateTime _backbuttonpressedTime;

  final SwiperController _swiperController = new SwiperController();
  final TextEditingController _textEditingController =
      new TextEditingController();

  // Animation<double> _animation;
  // AnimationController _animationController;
  Map _word;

  List _wordKey;
  List _wordValue;

  var _score = <bool>[];
  var _cardList = <Widget>[];

  var _valueIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // _animationController = new AnimationController(
    //   vsync: this,
    //   duration: Duration(
    //     seconds: 3
    //   )
    // );

    _getData();
  }

  void _getData() {
    databaseReference.collection('word').document('Unit 12').get().then((f) {
      setState(() {
        this._word = f.data;

        this._wordKey = _word.keys.toList();
        this._wordValue = _word.values.toList();
        for (int i = 0; i < _wordKey.length; i++) {
          this._cardList.add(_swiperCardChildren(i));
        }
      });
    });
  }

  _swiperCardChildren(int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 40, 30, 25),
      child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side:
                BorderSide(width: 20.w, color: Theme.of(context).primaryColor),
          ),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 200.h,
                    ),
                    Text('${_wordKey[index]}',
                        style: TextStyle(fontSize: 135.sp)),
                    // SizedBox(
                    //   height: 150.h,
                    // ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text('${index + 1} / ${_wordKey.length}'),
                  ))
            ],
          )),
    );
  }

  _stackBody() {
    return Stack(
      children: <Widget>[
        Align(
            alignment: Alignment.center,
            child: IgnorePointer(
              child: Swiper.children(
                // layout: SwiperLayout.CUSTOM,
                customLayoutOption: new CustomLayoutOption(
                        startIndex: -1, stateCount: 3)
                    .addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate([
                  new Offset(-370.0, -40.0),
                  new Offset(0.0, 0.0),
                  new Offset(370.0, -40.0)
                ]),
                loop: false,
                control: SwiperControl(color: Colors.white),
                // pagination: SwiperPagination(),
                controller: _swiperController,
                children: _cardList,
              ),
            )),
        Align(
          child: Container(
              width: 600.w,
              padding: EdgeInsets.only(top: 60),
              child: TextField(
                controller: _textEditingController,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onSubmitted: (_) {
                  String temp = _textEditingController.text.trim();
                  bool hadCheck = false;
                  if (_wordValue[_valueIndex] is String) {
                    if (temp == _wordValue[_valueIndex]) {
                      hadCheck = true;
                      // print('O text: $temp, word: ${_wordValue[_valueIndex]}');
                    }
                  } else if (_wordValue[_valueIndex] is List) {
                    List valueList = _wordValue[_valueIndex];
                    for (int i = 0; i < valueList.length; i++) {
                      if (temp == _wordValue[_valueIndex][i]) {
                        hadCheck = true;
                        break;
                      }
                    }
                  }
                  if (hadCheck) {
                    print('O text: $temp, word: ${_wordValue[_valueIndex]}');
                    Toast.show('맞았습니다.', context, duration: 2);
                    _score.add(true);
                  } else {
                    print('X text: $temp, word: ${_wordValue[_valueIndex]}');
                    Toast.show('틀렸습니다.', context, duration: 2);
                    _score.add(false);
                  }

                  _swiperController.next();

                  _textEditingController.clear();
                  setState(() {
                    this._valueIndex++;
                  });
                },
              )),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.green
            : null,
        body: _wordKey == null && _wordValue == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _stackBody());
  }
}
