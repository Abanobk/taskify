import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

import '../../config/colors.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {



    // Gradient colors for shimmer
    final shimmerGradient = LinearGradient(
     colors: AppColors.chatBackgroundColor,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );




    return ListView.builder(
      itemCount: 12, // Number of shimmer bubbles
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      itemBuilder: (context, index) {
        bool isSender = index % 2 == 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  isSender
                      ? CircleAvatar(radius: 18, backgroundColor:  AppColors.purple,)
                      : Padding(
                    padding: const EdgeInsets.only(left: 58.0),
                    child: CircleAvatar(radius: 18, backgroundColor:   AppColors.purple,),
                  ),
                  const SizedBox(width: 8),
                  Shimmer(
                    gradient: shimmerGradient,
                    child: Container(
                      height: 50,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              if (!isSender)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          isSender
                              ? CircleAvatar(radius: 18, backgroundColor:   AppColors.purple,)
                              : Padding(
                            padding: const EdgeInsets.only(left: 58.0),
                            child: CircleAvatar(radius: 18, backgroundColor:   AppColors.purple,),
                          ),
                          const SizedBox(width: 8),
                          Shimmer(
                            gradient: shimmerGradient,
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Shimmer(
                        gradient: shimmerGradient,
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                )]));



      },
    );
  }

}



