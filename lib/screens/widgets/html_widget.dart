import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
 import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:taskify/config/colors.dart';


Widget htmlWidget(String text,BuildContext context, {double? width,double? height}) {
  print("fosejfseKLfj $height");

  return Padding(
    padding:  EdgeInsets.only(bottom: 2.h),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: height ?? double.infinity, // If height is null, take content height

        maxWidth: width ?? double.infinity, // Allow infinite width when null
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        child: HtmlWidget(
          text,
          textStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.textClrChange,

            overflow: TextOverflow.ellipsis, // Truncate text
            // Adjust line height
          ),
          customWidgetBuilder: (element) {
            if (element.localName == 'ul' || element.localName == 'li') {
              return Container(
                margin: EdgeInsets.zero, // Remove any extra left margin
                padding: EdgeInsets.zero, // Remove padding
                alignment: Alignment.centerLeft, // Force left alignment
                child: Text(
                  maxLines: 2,
                  element. text ,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            }
            return null;
          },
        ),
      ),
    ),
  );
}



class ExpandableHtmlWidget extends StatefulWidget {
  final String text;
  final double? width;
  final double? height;
  final BuildContext context;

  const ExpandableHtmlWidget({
    super.key,
    required this.text,
    required this.context,
    this.width,
    this.height,
  });

  @override
  _ExpandableHtmlWidgetState createState() => _ExpandableHtmlWidgetState();
}
class _ExpandableHtmlWidgetState extends State<ExpandableHtmlWidget> {
  bool isExpanded = false;
  bool isOverflowing = false;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("fgthjuk ${widget.text}");
      checkOverflow();
    });
  }
  String cleanHtml(String html) {
    return html
        .replaceAll('\u00A0', ' ') // replace non-breaking space with normal space
        .replaceAll('&nbsp;', ' ');
  }

  void checkOverflow() {
    final context = _contentKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      setState(() {
        isOverflowing = renderBox.size.height > getMaxHeightLimit();
      });
    }
  }

  double getMaxHeightLimit() {
    return MediaQuery.of(context).size.height * 0.12; // 12% of screen height
  }

  @override
  Widget build(BuildContext context) {
    print("fgthjuk3rw3  ${cleanHtml ( widget.text)}");

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: ConstrainedBox(
              key: _contentKey,
              constraints: isExpanded
                  ? const BoxConstraints()
                  : BoxConstraints(maxHeight: getMaxHeightLimit()), // Dynamic height
              child: SingleChildScrollView(
                physics: isExpanded ? null : const NeverScrollableScrollPhysics(),
                child: HtmlWidget(
                  cleanHtml ( widget.text),

                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          if (isOverflowing)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                  if (!isExpanded) {
                    // Re-check if text still overflows after collapsing
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      checkOverflow();
                    });
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      isExpanded ? "Show Less" : "Show More",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class ExpandableHtmlNoteWidget extends StatefulWidget {
  final String text;
  final double? width;
  final double? height;
  final BuildContext context;

  const ExpandableHtmlNoteWidget({
    super.key,
    required this.text,
    required this.context,
    this.width,
    this.height,
  });

  @override
  _ExpandableHtmlNoteWidgetState createState() => _ExpandableHtmlNoteWidgetState();
}
class _ExpandableHtmlNoteWidgetState extends State<ExpandableHtmlNoteWidget> {
  bool isExpanded = false;
  bool isOverflowing = false;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("fgthjuk ${widget.text}");
      checkOverflow();
    });
  }
  String cleanHtml(String html) {
    return html
        .replaceAll('\u00A0', ' ') // replace non-breaking space with normal space
        .replaceAll('&nbsp;', ' ');
  }

  void checkOverflow() {
    final context = _contentKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      setState(() {
        isOverflowing = renderBox.size.height > getMaxHeightLimit();
      });
    }
  }

  double getMaxHeightLimit() {
    return MediaQuery.of(context).size.height * 0.50; // 12% of screen height
  }

  @override
  Widget build(BuildContext context) {
    print("fgthjuk3rw3  ${cleanHtml ( widget.text)}");

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: ConstrainedBox(
              key: _contentKey,
              constraints: isExpanded
                  ? const BoxConstraints()
                  : BoxConstraints(maxHeight: getMaxHeightLimit()), // Dynamic height
              child: SingleChildScrollView(
                // physics: isExpanded ?  : const NeverScrollableScrollPhysics(),
                child: HtmlWidget(
                  cleanHtml ( widget.text),

                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          if (isOverflowing)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                  if (!isExpanded) {
                    // Re-check if text still overflows after collapsing
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      checkOverflow();
                    });
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      isExpanded ? "Show Less" : "Show More",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}






