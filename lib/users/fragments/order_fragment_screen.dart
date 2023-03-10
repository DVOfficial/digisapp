import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import '../../api_connection/api_connection.dart';
import '../model/order.dart';
import '../order/history_screen.dart';
import '../order/order_details.dart';
import '../userPreferences/current_user.dart';


class OrderFragmentScreen extends StatelessWidget
{
  final currentOnlineUser = Get.put(CurrentUser());


  Future<List<Order>> getCurrentUserOrdersList() async
  {
    List<Order> ordersListOfCurrentUser = [];

    try
    {
      var res = await http.post(
          Uri.parse(API.readOrders),
          body:
          {
            "currentOnlineUserID": currentOnlineUser.user.user_id.toString(),
          }
      );

      if (res.statusCode == 200)
      {
        var responseBodyOfCurrentUserOrdersList = jsonDecode(res.body);

        if (responseBodyOfCurrentUserOrdersList['success'] == true)
        {
          (responseBodyOfCurrentUserOrdersList['currentUserOrdersData'] as List).forEach((eachCurrentUserOrderData)
          {
            ordersListOfCurrentUser.add(Order.fromJson(eachCurrentUserOrderData));
          });
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Status Code is not 200");
      }
    }
    catch(errorMsg)
    {
      Fluttertoast.showToast(msg: "Error:: " + errorMsg.toString());
    }

    return ordersListOfCurrentUser;
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //Order image       //history image
            //myOrder title     //history title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  //order icon image
                  // my orders
                  Column(
                    children: [
                      Image.asset(
                        "images/orders_icon.png",
                        width: 140,
                      ),
                      const Text(
                        "My Orders",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  //history icon image
                  // history
                  GestureDetector(
                    onTap: ()
                    {
                      //send user to orders history screen
                      Get.to(HistoryScreen());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.asset(
                            "images/history_icon.png",
                            width: 45,
                          ),
                          const Text(
                            "History",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),

            //some info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                "Here are your successfully placed orders.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            //displaying the user orderList
            Expanded(
              child: displayOrdersList(context),
            ),

          ],
        ),
      ),
    );
  }

  Widget displayOrdersList(context)
  {
    return FutureBuilder(
      future: getCurrentUserOrdersList(),
      builder: (context, AsyncSnapshot<List<Order>> dataSnapshot)
      {
        if(dataSnapshot.connectionState == ConnectionState.waiting)
        {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                  "Connection Waiting...",
                  style: TextStyle(color: Colors.black54,),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
        if(dataSnapshot.data == null)
        {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                    "No orders found yet...",
                  style: TextStyle(color: Colors.black54,),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
        if(dataSnapshot.data!.length > 0)
        {
          List<Order> orderList = dataSnapshot.data!;
          // return ListView.builder(
          //   itemCount: dataSnapshot.data!.length,
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   scrollDirection: Axis.vertical,
          //   itemBuilder: (context, index)
          //   {
          //     Order eachOrderData = orderList[index];
          //         DateTime tempDate = new DateFormat("dd MMMM, yyyy  hh:mm a").parse(eachOrderData.dateTime1!);
          //     //
          //     return GestureDetector(
          //       onTap: ()
          //       {
          //         Get.to(OrderDetailsScreen(
          //                           clickedOrderInfo: eachOrderData,
          //                         ));
          //       },
          //       child: Container(
          //         margin: EdgeInsets.fromLTRB(
          //           16,
          //           index == 0 ? 16 : 8,
          //           16,
          //           index == dataSnapshot.data!.length - 1 ? 16 : 8,
          //         ),
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(20),
          //           color: Colors.white70,
          //           boxShadow:
          //           const [
          //             BoxShadow(
          //               offset: Offset(0,0),
          //               blurRadius: 6,
          //               color: Colors.black12,
          //             ),
          //           ],
          //         ),
          //         child: Row(
          //           children: [
          //
          //             //name + price
          //             //tags
          //             Expanded(
          //               child: Padding(
          //                 padding: const EdgeInsets.only(left: 15),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //
          //                     //name and price
          //                     Row(
          //                       children: [
          //                         //name
          //                         Expanded(
          //                           child: Text(
          //                             eachCategoryItemRecord.category_name!,
          //                             maxLines: 2,
          //                             overflow: TextOverflow.ellipsis,
          //                             style: const TextStyle(
          //                               fontSize: 18,
          //                               color: Colors.black54,
          //                               fontWeight: FontWeight.bold,
          //                             ),
          //                           ),
          //                         ),
          //
          //                         // //price
          //                         // Padding(
          //                         //   padding: const EdgeInsets.only(left: 12, right: 12),
          //                         //   child: Text(
          //                         //     "\??? " + eachClothItemRecord.price.toString(),
          //                         //     maxLines: 2,
          //                         //     overflow: TextOverflow.ellipsis,
          //                         //     style: const TextStyle(
          //                         //       fontSize: 18,
          //                         //       color: Colors.purpleAccent,
          //                         //       fontWeight: FontWeight.bold,
          //                         //     ),
          //                         //   ),
          //                         // ),
          //
          //                       ],
          //                     ),
          //
          //                     const SizedBox(height: 16,),
          //
          //                     // //tags
          //                     // Text(
          //                     //   "Tags: \n" + eachClothItemRecord.tags.toString().replaceAll("[", "").replaceAll("]", ""),
          //                     //   maxLines: 2,
          //                     //   overflow: TextOverflow.ellipsis,
          //                     //   style: const TextStyle(
          //                     //     fontSize: 12,
          //                     //     color: Colors.black54,
          //                     //   ),
          //                     // ),
          //
          //                   ],
          //                 ),
          //               ),
          //             ),
          //
          //             //image clothes
          //             ClipRRect(
          //               borderRadius: const BorderRadius.only(
          //                 topRight: Radius.circular(20),
          //                 bottomRight: Radius.circular(20),
          //               ),
          //               child: FadeInImage(
          //                 height: 130,
          //                 width: 180,
          //                 fit: BoxFit.cover,
          //                 placeholder: const AssetImage("images/place_holder.png"),
          //                 image: NetworkImage(
          //                   eachCategoryItemRecord.category_imagelink!,
          //                 ),
          //                 imageErrorBuilder: (context, error, stackTraceError)
          //                 {
          //                   return const Center(
          //                     child: Icon(
          //                       Icons.broken_image_outlined,
          //                     ),
          //                   );
          //                 },
          //               ),
          //             ),
          //
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // );


          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index)
            {
              return const Divider(
                height: 1,
                thickness: 1,
              );
            },
            itemCount: orderList.length,
            itemBuilder: (context, index)
            {
              Order eachOrderData = orderList[index];
              DateTime tempDate = new DateFormat("dd MMMM, yyyy  hh:mm a").parse(eachOrderData.dateTime1!);

              return Card(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8,8,8,8),
                  child: ListTile(
                    onTap: ()
                    {
                      Get.to(OrderDetailsScreen(
                        clickedOrderInfo: eachOrderData,
                        orderStatus : "oldOrder",
                      ));
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID # " + eachOrderData.order_id.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4,),
                        Text(
                          "Amount: \??? " + eachOrderData.totalAmount.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4,),
                        Text(
                          DateFormat(
                              "dd MMMM, yyyy hh:mm a"
                          ).format(tempDate),
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),

                        // Text(
                        //   DateFormat(
                        //       "hh:mm a"
                        //   ).format(tempDate),
                        //   style: const TextStyle(
                        //     color: Colors.black54,
                        //   ),
                        // ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        //date
                        //time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //
                            // //date
                            // Text(
                            //   DateFormat(
                            //     "dd MMMM, yyyy"
                            //   ).format(eachOrderData.dateTime!),
                            //   style: const TextStyle(
                            //       color: Colors.black54,
                            //   ),
                            // ),
                            //
                            // const SizedBox(height: 4),
                            //
                            // //time
                            // Text(
                            //   DateFormat(
                            //       "hh:mm a"
                            //   ).format(eachOrderData.dateTime!),
                            //   style: const TextStyle(
                            //     color: Colors.black54,
                            //   ),
                            // ),
                            // //time

                            //date


                          ],
                        ),

                        // const SizedBox(width: 6),

                        const Icon(
                          Icons.navigate_next,
                          color: Colors.orangeAccent,
                        ),

                      ],
                    ),
              //       title: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             "Order ID # " + eachOrderData.order_id.toString(),
              //             style: const TextStyle(
              //               fontSize: 16,
              //               color: Colors.black54,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           const SizedBox(height: 6,),
              //           Text(
              //             "Amount: \??? " + eachOrderData.totalAmount.toString(),
              //             style: const TextStyle(
              //               fontSize: 16,
              //               color: Colors.orangeAccent,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ],
              //       ),
              //       trailing: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //
              //           //date
              //           //time
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.end,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               //
              //               // //date
              //               // Text(
              //               //   DateFormat(
              //               //     "dd MMMM, yyyy"
              //               //   ).format(eachOrderData.dateTime!),
              //               //   style: const TextStyle(
              //               //       color: Colors.black54,
              //               //   ),
              //               // ),
              //               //
              //               // const SizedBox(height: 4),
              //               //
              //               // //time
              //               // Text(
              //               //   DateFormat(
              //               //       "hh:mm a"
              //               //   ).format(eachOrderData.dateTime!),
              //               //   style: const TextStyle(
              //               //     color: Colors.black54,
              //               //   ),
              //               // ),
              //               // //time
              //
              //               //date
              //               Text(
              //                 DateFormat(
              //                     "dd MMMM, yyyy"
              //                 ).format(tempDate),
              //                 style: const TextStyle(
              //                   color: Colors.black54,
              //                 ),
              //               ),
              //
              //               Text(
              //     DateFormat(
              //     "hh:mm a"
              // ).format(tempDate),
              //                 style: const TextStyle(
              //                   color: Colors.black54,
              //                 ),
              //               ),
              //
              //             ],
              //           ),
              //
              //           const SizedBox(width: 6),
              //
              //           const Icon(
              //             Icons.navigate_next,
              //             color: Colors.orangeAccent,
              //           ),
              //
              //         ],
              //       ),
                  ),
                ),
              );
            },
          );


        }
        else
        {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                  "Nothing to show...No New Orders\n\nCheck history for previous orders",
                  style: TextStyle(color: Colors.black54,),
                ),
              ),
              // Center(
              //   child: CircularProgressIndicator(),
              // ),
            ],
          );
        }
      },
    );
  }
}
