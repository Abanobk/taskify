import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../../data/model/candidate/candidate_id_interviews.dart';
import '../../../../data/model/candidate/candidate_model.dart';
import '../../../../data/repositories/candidate/candidate_repo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class InterviewDialog extends StatefulWidget {
  final CandidateModel candidate;

  const InterviewDialog(this.candidate, {super.key});

  @override
  State<InterviewDialog> createState() => _InterviewDialogState();
}

class _InterviewDialogState extends State<InterviewDialog> {
  List<Candidate> candidateList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCandidateInterviewList();
  }

  void getCandidateInterviewList() async {
    try {
      final result =
      await CandidatesRepo().getCandidateInterviewList(id: widget.candidate.id);

      /// Parse response assuming result['data']['candidate']
      final candidate = Candidate.fromJson(result['data']['candidate']);
      setState(() {
        candidateList = [candidate];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching interview list: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED":
        return Colors.greenAccent.shade100;
      case "SCHEDULED":
        return Colors.orange.shade100;
        case "CANCELLED":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Icon getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED":
        return Icon(Icons.check_circle, size: 16, color: Colors.green);
      case "SCHEDULED":
        return Icon(Icons.schedule, size: 16, color: Colors.orange.shade800);
        case "CANCELLED":
        return Icon(Icons.close, size: 16, color: Colors.red.shade800);
      default:
        return Icon(Icons.info, size: 16, color: Colors.grey);
    }
  }

  String formatDate(String dateStr) {
    try {
      return DateFormat('MMM dd, yyyy – hh:mm a')
          .format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = candidateList.isNotEmpty ? candidateList.first : null;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      child: Container(
        padding:  EdgeInsets.all(16.w),
        width: 500.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.backGroundColor,),

        child: isLoading
            ? const Center(child:  SpinKitFadingCircle(
          color: AppColors
              .primary,
          size: 40.0,
        ),)
            : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Interviews for \n${candidate?.name ?? '-'}",
                    style:  TextStyle(
                        color: Theme.of(context).colorScheme.textChange,
                        fontSize: 18, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// Name & Designation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.dividerClrChange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate?.name ?? "-",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate?.position ?? "-",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /// Interview List or NoData
              candidate?.interviews?.isEmpty ?? true
                  ? const NoData(  isImage: false,isNoInterview: true,) // Show NoData widget if interviews is empty
                  : Column(
                children: candidate!.interviews!.map((interview) {
                  final interviewer = interview.interviewer;
                  final fullName =
                  "${interviewer?.firstName ?? ''} ${interviewer?.lastName ?? ''}"
                      .trim();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title
                        Row(
                          children: const [
                            Icon(Icons.calendar_today,
                                color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              "Interview",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text(
                            formatDate(interview.scheduledAt ?? ''),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Divider(),

                        /// Interviewer + Status
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Chip(
                                avatar: const Icon(Icons.person,
                                    size: 16, color: Colors.blue),
                                label: Text(
                                  "INTERVIEWER: $fullName",
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black),
                                ),
                                backgroundColor:
                                Colors.lightBlue.shade100,
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                avatar: getStatusIcon(
                                    interview.status ?? ""),
                                label: Text(
                                  (interview.status ?? "")
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black),
                                ),
                                backgroundColor: getStatusColor(
                                    interview.status ?? ""),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              // SizedBox(height: 20.h,),
              // InkWell(
              //   onTap: (){
              //     Navigator.pop(context);
              //   },
              //   child: Align(
              //     alignment: Alignment.centerRight,
              //     child: Container(
              //       alignment: Alignment.center,
              //       decoration: BoxDecoration(
              //           color: AppColors.primary,
              //           borderRadius: BorderRadius.circular(6)),
              //       height: 30.h,
              //       width: 100.w,
              //       margin: EdgeInsets.symmetric(vertical: 4.h),
              //       child: CustomText(
              //         text: AppLocalizations.of(context)!.cancel
              //             ,
              //         size: 12.sp,
              //         fontWeight: FontWeight.w800,
              //         color: AppColors.pureWhiteColor,
              //       )),
              // )),
              /// Close Button
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: TextButton.icon(
              //     onPressed: () => Navigator.pop(context),
              //     icon: const Icon(Icons.close),
              //     label: const Text("Close"),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
