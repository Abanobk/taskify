import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:taskify/config/colors.dart';

class NotesDescription extends StatefulWidget {
  final String title;
  final String? description;
  final Function(String) onNoteSaved;

  const NotesDescription({
    Key? key,
    required this.title,
    this.description,
  required  this.onNoteSaved,
  }) : super(key: key);

  @override
  State<NotesDescription> createState() => _NotesDescriptionState();
}

class _NotesDescriptionState extends State<NotesDescription> {
  final HtmlEditorController controller = HtmlEditorController();

  @override
  void initState() {
    super.initState();
    print("DESCRIPTION OF NOTES ${widget.description}");
  }

  void _setInitialContent() async {
    // Try multiple times with increasing delays
    for (int i = 0; i < 3; i++) {
      await Future.delayed(Duration(milliseconds: 300 * (i + 1)));

      try {
        final content = widget.description?.isNotEmpty == true
            ? widget.description!
            : "";

        print("Attempt ${i + 1}: Setting content: $content");
        controller.setText(content); // Remove await since it returns void

        // Wait a bit for the content to be set
        await Future.delayed(Duration(milliseconds: 100));

        // Verify the content was set
        final currentText = await controller.getText();
        print("Current text after setting: $currentText");

        if (currentText.isNotEmpty && currentText != "<p><br></p>") {
          print("Content successfully set on attempt ${i + 1}");
          break;
        }
      } catch (e) {
        print("Error setting content on attempt ${i + 1}: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // elevation:0.5,
        backgroundColor:Theme.of(context).colorScheme.backGroundColor,
        title: Text(widget.title),

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: HtmlEditor(
                  controller: controller,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: 'Please enter product description...',
                    autoAdjustHeight: false, // ensure height can expand
                    // Set initial text here as well
                    initialText: widget.description?.isNotEmpty == true
                        ? widget.description!
                        : "<h2>${widget.title}</h2><p>Please enter product description...</p>",
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    toolbarPosition: ToolbarPosition.aboveEditor,
                    toolbarType: ToolbarType.nativeGrid,
                    defaultToolbarButtons: [
                      StyleButtons(),
                      FontSettingButtons(fontSizeUnit: false),
                      FontButtons(clearAll: false),
                      ColorButtons(),
                      ListButtons(listStyles: false),
                      ParagraphButtons(textDirection: false, lineHeight: false, caseConverter: false),
                      // Removed InsertButtons() which contains image and link options
                      OtherButtons(
                        copy: false,
                        paste: false,
                        help: false,
                        fullscreen: false,
                        codeview: false
                      ),
                    ],
                  ),
                  otherOptions: OtherOptions(
                    height: MediaQuery.of(context).size.height * 0.6, // ensure visible
                    decoration: BoxDecoration(
                      color:  Theme.of(context).colorScheme.backGroundColor,
                      // borderRadius: BorderRadius.circular(12),
                      // border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  callbacks: Callbacks(
                    onInit: () {
                      print("HTML Editor initialized");
                      // Set content after editor is initialized
                      _setInitialContent();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => controller.setText(""),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Clear"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final text = await controller.getText();

              debugPrint("Saved: $text");
              widget.onNoteSaved(text);
              Navigator.pop(context);
              // You might want to return this value to the previous screen
              // Navigator.pop(context, text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}