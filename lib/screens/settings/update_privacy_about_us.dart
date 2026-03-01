import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_bloc.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_event.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_state.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../src/generated/i18n/app_localizations.dart';
class UpdateAboutUs extends StatefulWidget {
  final String privacyPolicy;
  final String from;

  const UpdateAboutUs(
      {super.key, required this.privacyPolicy, required this.from});

  @override
  State<UpdateAboutUs> createState() => _UpdateAboutUsState();
}

class _UpdateAboutUsState extends State<UpdateAboutUs> {
  final HtmlEditorController controller = HtmlEditorController();
  final ValueNotifier<String> aboutUsText = ValueNotifier<String>("");
  bool hasPopped = false;

  final _toolbarColor = Colors.grey.shade600;

  final _toolbarIconColor = Colors.black87;


  Future<void> _updatePrivacyPolicy(String privacy) async {
    final settingBloc = BlocProvider.of<PrivacyAboutusTermsCondBloc>(context);
    settingBloc.add(PrivacyPolicy(privacyPolicyText: privacy));
    settingBloc.add(GetPrivacyPolicy());
  }

  Future<void> _updateTermsAndCondition(String terms) async {
    final settingBloc = BlocProvider.of<PrivacyAboutusTermsCondBloc>(context);
    settingBloc.add(TermsAndCondition(termsAndConditionText: terms));
    settingBloc.add(GetTermsAndCondition());
  }

  Future<void> _updateAboutUs(String privacy) async {
    final settingBloc = BlocProvider.of<PrivacyAboutusTermsCondBloc>(context);
    settingBloc.add(AbouUs(abouUsText: privacy));
    settingBloc.add(GetAboutUs());
  }

  @override
  void initState() {
    super.initState();

    aboutUsText.value = widget.privacyPolicy;
    debugPrint('Initial privacyPolicy: ${widget.privacyPolicy}');
  }

  @override
  void dispose() {
    aboutUsText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,  resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.textClrChange),
          onPressed: () => Navigator.pop(context),
        ),
        title: CustomText(
          text: widget.from == "privacy"
              ? AppLocalizations.of(context)!.privacypolicy
              : widget.from == "terms"
              ? AppLocalizations.of(context)!.termsandconditions
              : AppLocalizations.of(context)!.aboutus,
          color: Theme.of(context).colorScheme.textClrChange,
          fontWeight: FontWeight.w600,
          size: 18,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: HtmlEditor(
              controller: controller,
              htmlEditorOptions: HtmlEditorOptions(
                hint: 'Hint text goes here',
                initialText: widget.privacyPolicy,
                autoAdjustHeight: true,
                shouldEnsureVisible: true,
              ),
              htmlToolbarOptions: HtmlToolbarOptions(
                toolbarPosition: ToolbarPosition.aboveEditor,
                toolbarType: ToolbarType.nativeScrollable,
                defaultToolbarButtons: [
                  StyleButtons(),
                  FontSettingButtons(
                    fontSizeUnit: false,
                    fontName: true,
                  ),
                  FontButtons(
                    bold: true,
                    italic: true,
                    underline: true,
                    clearAll: true,
                  ),
                  ColorButtons(
                    foregroundColor: true,
                    highlightColor: true,
                  ),
                  ListButtons(
                    listStyles: true,
                  ),
                  ParagraphButtons(
                    alignLeft: true,
                    alignCenter: true,
                    alignRight: true,
                  ),
                ],
                toolbarItemHeight: 40,
                buttonColor: _toolbarIconColor,
                buttonSelectedColor: AppColors.primary,
                buttonFillColor: _toolbarColor,
                buttonBorderColor: Colors.black87,
              ),
              otherOptions: OtherOptions(
                height: 500,
              ),
              callbacks: Callbacks(
                onChangeContent: (String? text) {
                  if (text != null) {
                    aboutUsText.value = text;
                    debugPrint('Text changed: $text');
                  }
                },
                onInit: () {
                  debugPrint('Editor has been loaded');
                  controller.setText(widget.privacyPolicy);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocListener<PrivacyAboutusTermsCondBloc, PrivacyAboutusTermsCondState>(
        listener: (context, state) {
          if (state is PrivacyUpdatedSuccess ||
              state is TermsAndConditionsUpdatedSuccess ||
              state is AboutUsUpdatedSuccess) {
            if (!hasPopped) {
              hasPopped = true; // Set flag first to prevent multiple pops
              flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary,
              );
              // Optional: Add slight delay to ensure toast is visible before popping
              Future.delayed(const Duration(milliseconds: 500), () {
                router.pop();
              });
            }
          } else if (state is PrivacyUpdatedError) {
            flutterToastCustom(
              msg: state.errorMessage,
              color: AppColors.red, // Use error color for error state
            );
          }
        },
        child: SizedBox(
          height: 60, // Fixed height for bottom bar
          child: Container(
            color: Theme.of(context).colorScheme.backGroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  // Validate widget.from to avoid invalid cases
                  if (!['terms', 'privacy', 'about'].contains(widget.from)) {
                    flutterToastCustom(
                      msg: "Invalid Action",
                      color: AppColors.red,
                    );
                    return;
                  }

                  String updatedText = await controller.getText();
                  print("Updating for ${widget.from}: $updatedText");

                  switch (widget.from) {
                    case "terms":
                      _updateTermsAndCondition(updatedText);
                      break;
                    case "privacy":
                      _updatePrivacyPolicy(updatedText);
                      break;
                    case "about":
                      _updateAboutUs(updatedText);
                      break;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  child: CustomText(
                    text: AppLocalizations.of(context)!.done,
                    color: Colors.white,
                    size: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
