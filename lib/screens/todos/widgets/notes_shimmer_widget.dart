// class NotesShimmer extends StatelessWidget {
//   const NotesShimmer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child:ListView.builder(
//           padding: EdgeInsets.only(bottom: 30.h),
//           shrinkWrap: true,
//           itemCount: 10,
//           itemBuilder: (context, index) {
//             return Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 18.w),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: AppColors.pureWhiteColor,
//                       borderRadius: BorderRadius.circular(12)),
//                   height: 100.h,
//
//                 ));
//           }),);
//   }
// }
