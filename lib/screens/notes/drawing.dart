
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_drawing_board/paint_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../bloc/notes/notes_event.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import 'package:image/image.dart' as img;
import '../../src/generated/i18n/app_localizations.dart';


class Triangle extends PaintContent {
  Triangle();

  Triangle.data({
    required this.startPoint,
    required this.A,
    required this.B,
    required this.C,
    required Paint paint,
  }) : super.paint(paint);

  factory Triangle.fromJson(Map<String, dynamic> data) {
    return Triangle.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      A: jsonToOffset(data['A'] as Map<String, dynamic>),
      B: jsonToOffset(data['B'] as Map<String, dynamic>),
      C: jsonToOffset(data['C'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  Offset startPoint = Offset.zero;
  Offset A = Offset.zero;
  Offset B = Offset.zero;
  Offset C = Offset.zero;

  String get contentType => 'Triangle';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) {
    A = Offset(
        startPoint.dx + (nowPoint.dx - startPoint.dx) / 2, startPoint.dy);
    B = Offset(startPoint.dx, nowPoint.dy);
    C = nowPoint;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final Path path = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  Triangle copy() => Triangle();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'A': A.toJson(),
      'B': B.toJson(),
      'C': C.toJson(),
      'paint': paint.toJson(),
    };
  }
}

class DrawingScreen extends StatefulWidget {
  final String drawing;
  final bool isCreated;
  const DrawingScreen(
      {super.key, required this.drawing, required this.isCreated});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late DrawingController _drawingController = DrawingController();
  final TransformationController _transformationController =
      TransformationController();
  double _colorOpacity = 1;
  Uint8List? data;
  bool isRtl = false;

  @override
  void initState() {
    super.initState();
    _checkRtlLanguage();
    convertSvgIntoImage();
  }

  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    setState(() {
      isRtl =
          LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);
    });
  }

  Future<void> convertSvgIntoImage() async {
    String rawSvg = widget.drawing;

    try {
      final PictureInfo pictureInfo =
          await vg.loadPicture(SvgStringLoader(rawSvg), null);

      final ui.Image image = await pictureInfo.picture.toImage(500, 500);

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List imageData = byteData.buffer.asUint8List();

        setState(() {
          data = imageData;
        });

        // Set the image as the background of the drawing board
        // _drawingController.cachedImage = image;
      }
    } catch (e) {
      debugPrint("Error converting SVG: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkRtlLanguage();
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  Future<String> convertImageToSvgBase64(Uint8List imageData) async {
    final decoded = img.decodePng(imageData); // 👈 use decodePng here
    if (decoded == null) {
      throw Exception("Failed to decode image");
    }

    final resized = img.copyResize(decoded, width: 300); // optional
    final compressed = img.encodePng(resized, level: 9); // compress
    String base64Png = base64Encode(compressed);
    String svgString =
        '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500"><image href="data:image/png;base64,$base64Png" height="100%" width="100%"/></svg>';
    String encoded = encodeDrawingData(svgString);

    context.read<NotesBloc>().add(DrawingNote(drawing: encoded));
    return svgString;
  }

  String encodeDrawingData(String drawingData) {
    final bytes = utf8.encode(drawingData);
    return base64.encode(bytes);
  }
  Future<void> _getImageData() async {
    data = (await _drawingController.getImageData())?.buffer.asUint8List();
    debugPrint('获取图片数据失败 $data');
    convertImageToSvgBase64(data!);
    if (data == null) {
      debugPrint('获取图片数据失败 $data');
      return;
    }

    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext c) {
          return Dialog(
            backgroundColor: AppColors.pureWhiteColor,
            insetPadding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AppBar-style header with back arrow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 18),
                  child: Row(
                    children: [
                      isRtl
                          ? InkWell(
                              onTap: () {
                                router.pop();
                              },
                              child: HeroIcon(
                                HeroIcons.chevronRight,
                                style: HeroIconStyle.outline,
                                color: AppColors.greyColor,
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                router.pop();
                              },
                              child: HeroIcon(
                                HeroIcons.chevronLeft,
                                style: HeroIconStyle.outline,
                                color: AppColors.greyColor,
                              ),
                            ),
                      const Spacer(),
                    ],
                  ),
                ),
                // Image content
                if (data != null)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.memory(data!),
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  void _resetBoard() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    print("bhjn $isRtl");
    return Scaffold(
      backgroundColor: AppColors.pureWhiteColor,
      appBar: AppBar(
          leading: isRtl
              ? InkWell(
                  onTap: () {
                    router.pop();
                  },
                  child: HeroIcon(
                    HeroIcons.chevronRight,
                    style: HeroIconStyle.outline,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                )
              : InkWell(
                  onTap: () {
                    router.pop();
                  },
                  child: HeroIcon(
                    HeroIcons.chevronLeft,
                    style: HeroIconStyle.outline,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                ),
          title: Row(
            children: [
              PopupMenuButton<Color>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.color_lens),
                onSelected: (ui.Color value) => _drawingController.setStyle(
                    color: value.withValues(alpha: _colorOpacity)),
                itemBuilder: (_) {
                  return <PopupMenuEntry<ui.Color>>[
                    PopupMenuItem<Color>(
                      child: StatefulBuilder(
                        builder: (BuildContext context,
                            Function(void Function()) setState) {
                          return Slider(
                            value: _colorOpacity,
                            onChanged: (double v) {
                              setState(() => _colorOpacity = v);
                              _drawingController.setStyle(
                                color: _drawingController.drawConfig.value.color
                                    .withValues(alpha: _colorOpacity),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ...Colors.accents.map((ui.Color color) {
                      return PopupMenuItem<ui.Color>(
                          value: color,
                          child:
                              Container(width: 100, height: 50, color: color));
                    }),
                  ];
                },
              ),
              CustomText(
                text: AppLocalizations.of(context)!.drawingnotes,
                color: Theme.of(context).colorScheme.textClrChange,
                fontWeight: FontWeight.w700,
                size: 17,
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.check), onPressed: _getImageData),
            IconButton(
                icon: const Icon(Icons.restore_page_rounded),
                onPressed: _resetBoard),
          ]),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Stack(
                    children: [
                      DrawingBoard(
                        transformationController: _transformationController,
                        controller: _drawingController,
                        background: Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          decoration: data != null
                              ? BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(data!),
                                    fit: BoxFit
                                        .contain, // Ensure it covers properly
                                  ),
                                  color: Colors.transparent)
                              : const BoxDecoration(color: Colors.transparent),
                        ),
                        showDefaultActions: true,
                        showDefaultTools: true,
                        defaultToolsBuilder: (Type t, _) {
                          return DrawingBoard.defaultTools(
                              t, _drawingController)
                            ..insert(
                                1,
                                DefToolItem(
                                  icon: Icons.change_history_rounded,
                                  isActive: t == Triangle,
                                  onTap: () {
                                    _drawingController
                                        .setPaintContent(Triangle());
                                  },
                                ))
                            ..insert(
                                1,
                                DefToolItem(
                                  icon: Icons.delete,
                                  isActive: t == Triangle,
                                  onTap: () {
                                    setState(() {
                                      _drawingController.clear();
                                      data = null; // Clear the image data
                                    });
                                  },
                                ));
                        },
                      ),

                      // 🎨 Drawing Board Overlay
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
