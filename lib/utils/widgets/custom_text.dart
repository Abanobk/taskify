import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final double? letterspace;
  final double? wordpace;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? softwrap;
  final double? height;
  final TextOverflow? overflow;
  final TextDecoration? textDecoration; // Added textDecoration

  // final Function onTapPress;

  const CustomText({
    super.key,
    required this.text,
    this.size = 16.0,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.softwrap,
    this.maxLines,
    this.letterspace,
    this.wordpace,
    this.height,
    this.overflow,
    this.textDecoration,
    // required this.onTapPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      // onTap: onTapPress(),
      child: Container(
        // Set constraints as needed
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width, // or any specific width
        ),
        child: Text(
          text,
          softWrap: softwrap??false,
          style: TextStyle(
              fontFamily: 'Quicksand',
              wordSpacing: wordpace,
              letterSpacing: letterspace,
              fontSize: size,
              color: color,
              fontWeight: fontWeight,
              height: height,
              decoration:   textDecoration
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
      ),
    );
  }
}
