import 'dart:ui';

import 'package:flutter/material.dart';

String getImageForTitle(String title) {
  switch (title.toLowerCase().trim()) {
    case 'brushing teeth':
      return 'lib/assets/brushingteeth.png';
    case 'bathing':
      return 'lib/assets/bathing.png';
    case 'eating food':
      return 'lib/assets/food.png';
    case 'going to bed':
      return 'lib/assets/sleeping.png';
    case 'time to wake up':
      return 'lib/assets/alarm.png';
      case 'abc letters':
      return 'lib/assets/abcletters.png';

        case 'catch the stars game':
      return 'lib/assets/star_game.png';

       case 'birds':
      return 'lib/assets/birdsanimal.png';
         case 'home animals':
      return 'lib/assets/homepets.png';
           case 'count the things':
      return 'lib/assets/countthings.png'; 
        case 'addition and subtraction':
      return 'lib/assets/plusminus.png';
    default:
      return 'assets/images/default.png';
  }
}
String getCategoryImage(String category) {
  switch (category.toLowerCase().trim()) {
    case 'animals':
      return 'lib/assets/animalcategory.png';
    case 'science':
      return 'lib/assets/sciencecategory.jpg';
    case 'games':
      return 'lib/assets/gamescategory.png';
    case 'numbers':
      return 'lib/assets/numberscategory.png';
    case 'alphabets':
      return 'lib/assets/alphabetcategory.png';
    case 'emotions':
      return 'lib/assets/emotionscategory.jpg';
    case 'fruit':
      return 'lib/assets/fruitscategory.png';
     case 'daily life':
      return 'lib/assets/dailycategory.png';
    default:
      return 'assets/lib/default.png';
  }
}


final List<Color> containerColors = [
  const Color(0xFFC8E6C9),
  const Color(0xFFBBDEFB),
  const Color(0xFFFFE0B2),
  const Color(0xFFE1BEE7),
  const Color(0xFFB2DFDB),
  const Color(0xFFFCF8DD),
  const Color(0xFFFFF9C4),
  const Color(0xFFF8BBD0),
  const Color(0xFFB2EBF2),
  const Color(0xFFF0F4C3),
];