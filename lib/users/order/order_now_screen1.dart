//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
//
// import '../../api_connection/api_connection.dart';
// import '../controllers/order_now_controller.dart';
// import '../fragments/dashboard_of_fragments.dart';
// import '../model/order.dart';
// import '../userPreferences/current_user.dart';
// import 'OrderConfirmationScreen1.dart';
// import 'order_confirmation.dart';
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;
//
//
// class OrderNowScreen1 extends StatelessWidget
// {
//   final List<Map<String, dynamic>>? selectedCartListItemsInfo;
//   final double? totalAmount;
//   final List<int>? selectedCartIDs;
//
//   OrderNowController orderNowController = Get.put(OrderNowController());
//   // List<String> deliverySystemNamesList = ["Standard Shipping\n(Next Day- 2pm to 6pm)", "Priority Shipping (WEFAST)\nNext Day before 2PM"];
//   List<String> paymentSystemNamesList = ["Razorpay\n(Credit/ Debit Card/ UPI/Net Banking)","Cash On Delivery"];
//
//   TextEditingController phoneNumberController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController shipmentAddressController = TextEditingController();
//   TextEditingController noteToSellerController = TextEditingController();
//
//   CurrentUser currentUser = Get.put(CurrentUser());
//
//
//   OrderNowScreen1({
//     this.selectedCartListItemsInfo,
//     this.totalAmount,
//     this.selectedCartIDs,
//   });
//   //
//   // saveNewOrderInfo() async
//   // {
//   //   String selectedItemsString = selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
//   //
//   //   Order order = Order(
//   //     order_id: 1,
//   //     user_id: currentUser.user.user_id,
//   //     selectedItems: selectedItemsString,
//   //     // deliverySystem: deliverySystem,
//   //     paymentSystem: orderNowController.paymentSys,
//   //     note: noteToSellerController.text,
//   //     totalAmount: totalAmount,
//   //     // image: DateTime.now().millisecondsSinceEpoch.toString() + "-" + imageSelectedName,
//   //     status: "new",
//   //     dateTime: DateTime.now(),
//   //     shipmentAddress: shipmentAddressController.text,
//   //     phoneNumber: phoneNumberController.text,
//   //   );
//   //
//   //   try
//   //   {
//   //     var res = await http.post(
//   //       Uri.parse(API.addOrder),
//   //       // body: order.toJson(base64Encode(imageSelectedByte)),
//   //     );
//   //
//   //     if (res.statusCode == 200)
//   //     {
//   //       var responseBodyOfAddNewOrder = jsonDecode(res.body);
//   //
//   //       if(responseBodyOfAddNewOrder["success"] == true)
//   //       {
//   //         //delete selected items from user cart
//   //         selectedCartIDs!.forEach((eachSelectedItemCartID)
//   //         {
//   //           deleteSelectedItemsFromUserCartList(eachSelectedItemCartID);
//   //         });
//   //       }
//   //       else
//   //       {
//   //         Fluttertoast.showToast(msg: "Error:: \nyour new order do NOT placed.");
//   //       }
//   //     }
//   //   }
//   //   catch(erroeMsg)
//   //   {
//   //     Fluttertoast.showToast(msg: "Error: " + erroeMsg.toString());
//   //   }
//   // }
//   //
//   // deleteSelectedItemsFromUserCartList(int cartID) async
//   // {
//   //   try
//   //   {
//   //     var res = await http.post(
//   //         Uri.parse(API.deleteSelectedItemsFromCartList),
//   //         body:
//   //         {
//   //           "cart_id": cartID.toString(),
//   //         }
//   //     );
//   //
//   //     if(res.statusCode == 200)
//   //     {
//   //       var responseBodyFromDeleteCart = jsonDecode(res.body);
//   //
//   //       if(responseBodyFromDeleteCart["success"] == true)
//   //       {
//   //         Fluttertoast.showToast(msg: "your new order has been placed Successfully.");
//   //
//   //         Get.to(DashboardOfFragments());
//   //       }
//   //     }
//   //     else
//   //     {
//   //       Fluttertoast.showToast(msg: "Error, Status Code is not 200");
//   //     }
//   //   }
//   //   catch(errorMessage)
//   //   {
//   //     print("Error: " + errorMessage.toString());
//   //
//   //     Fluttertoast.showToast(msg: "Error: " + errorMessage.toString());
//   //   }
//   // }
//
//
//   saveNewOrderInfo() async
//   {
//     String selectedItemsString = selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
//     print(("error:"+selectedItemsString));
//
//     Order order = Order(
//       order_id: 1,
//       user_id: currentUser.user.user_id,
//       user_name: nameController.text,
//       user_email: emailController.text,
//       selectedItems: selectedItemsString,
//       // deliverySystem: deliverySystem,
//       paymentSystem: orderNowController.paymentSys,
//       note: noteToSellerController.text,
//       totalAmount: totalAmount,
//       // image: DateTime.now().millisecondsSinceEpoch.toString() + "-" + imageSelectedName,
//       status: "new",
//       dateTime: DateTime.now(),
//       shipmentAddress: shipmentAddressController.text,
//       phoneNumber: phoneNumberController.text,
//     );
//
//     try
//     {
//       var res = await http.post(
//         Uri.parse(API.addOrder),
//         body: order.toJson(),
//       );
//
//       if (res.statusCode == 200)
//       {
//         var responseBodyOfAddNewOrder = jsonDecode(res.body);
//
//         if(responseBodyOfAddNewOrder["success"] == true)
//         {
//           //delete selected items from user cart
//           selectedCartIDs!.forEach((eachSelectedItemCartID)
//           {
//             deleteSelectedItemsFromUserCartList(eachSelectedItemCartID);
//           });
//         }
//         else
//         {
//           Fluttertoast.showToast(msg: "Error:: \nyour new order do NOT placed.");
//         }
//       }
//     }
//     catch(erroeMsg)
//     {
//       Fluttertoast.showToast(msg: "Error1: " + erroeMsg.toString());
//     }
//   }
//
//   deleteSelectedItemsFromUserCartList(int cartID) async
//   {
//     try
//     {
//       var res = await http.post(
//           Uri.parse(API.deleteSelectedItemsFromCartList),
//           body:
//           {
//             "cart_id": cartID.toString(),
//           }
//       );
//
//       if(res.statusCode == 200)
//       {
//         var responseBodyFromDeleteCart = jsonDecode(res.body);
//
//         if(responseBodyFromDeleteCart["success"] == true)
//         {
//           Fluttertoast.showToast(msg: "your new order has been placed Successfully.");
//
//           Get.to(DashboardOfFragments());
//         }
//       }
//       else
//       {
//         Fluttertoast.showToast(msg: "Error, Status Code is not 200");
//       }
//     }
//     catch(errorMessage)
//     {
//       print("Error2: " + errorMessage.toString());
//
//       Fluttertoast.showToast(msg: "Error3: " + errorMessage.toString());
//     }
//   }
//
//
//   showDialogBoxForImagePickingAndCapturing(context)
//   {
//     return showDialog(
//         context: context,
//         builder: (context)
//         {
//           return SimpleDialog(
//             backgroundColor: Colors.black,
//
//             title: const Text(
//               "Please Select Payment Mode",
//               style: TextStyle(
//                 color: Colors.deepOrange,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             children: [
//               SimpleDialogOption(
//                 onPressed: ()
//                 {
//                   orderNowController.setPaymentSystem("RazorPay");
//                   // captureImageWithPhoneCamera();
//                   Get.to(OrderConfirmationScreen(
//                     selectedCartIDs: selectedCartIDs,
//                     selectedCartListItemsInfo: selectedCartListItemsInfo,
//                     totalAmount: totalAmount,
//                     // deliverySystem: orderNowController.deliverySys,
//                     paymentSystem: orderNowController.paymentSys,
//                     phoneNumber: phoneNumberController.text,
//                     shipmentAddress: shipmentAddressController.text,
//                     note: noteToSellerController.text,
//                   ));
//                 },
//                 child: const Text(
//                   "Razorpay\n(Credit/ Debit Card/ UPI/ Net Banking)",
//                   style: TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//               SimpleDialogOption(
//                 onPressed: ()
//                 {
//                   orderNowController.setPaymentSystem("Cash_On_Delivery");
//                   // pickImageFromPhoneGallery();
//                   // Get.to(OrderConfirmationScreen1(
//                   //       selectedCartIDs: selectedCartIDs,
//                   //       selectedCartListItemsInfo: selectedCartListItemsInfo,
//                   //       totalAmount: totalAmount,
//                   //       // deliverySystem: orderNowController.deliverySys,
//                   //       paymentSystem: orderNowController.paymentSys,
//                   //       phoneNumber: phoneNumberController.text,
//                   //       shipmentAddress: shipmentAddressController.text,
//                   //       note: noteToSellerController.text,
//                   //     ));
//
//                   saveNewOrderInfo();
//
//
//
//                 },
//                 child: const Text(
//                   "Cash On Delivery",
//                   style: TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//               SimpleDialogOption(
//                 onPressed: ()
//                 {
//                   Get.back();
//                 },
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     color: Colors.red,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context)
//   {
//     nameController=TextEditingController(text:currentUser.user.user_name);
//     emailController=TextEditingController(text:currentUser.user.user_email);
//     // nameController.text=currentUser.user.user_name;
//     // emailController.text=currentUser.user.user_email;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text(
//             "Order Now"
//         ),
//         titleSpacing: 0,
//       ),
//       body: ListView(
//         children: [
//
//           //display selected items from cart list
//           displaySelectedItemsFromUserCart(),
//
//           const SizedBox(height: 30),
//
//           // //delivery system
//           // const Padding(
//           //   padding: EdgeInsets.symmetric(horizontal: 16.0),
//           //   child: Text(
//           //     'Delivery System:',
//           //     style: TextStyle(
//           //       fontSize: 18,
//           //       color: Colors.white70,
//           //       fontWeight: FontWeight.bold,
//           //     ),
//           //   ),
//           // ),
//
//           //Delivery system
//
//           // Padding(
//           //   padding: const EdgeInsets.all(18.0),
//           //   child: Column(
//           //     children: deliverySystemNamesList.map((deliverySystemName)
//           //     {
//           //       return Obx(()=>
//           //           RadioListTile<String>(
//           //             tileColor: Colors.white24,
//           //             dense: true,
//           //             activeColor: Colors.orangeAccent,
//           //             title: Text(
//           //               deliverySystemName,
//           //               style: const TextStyle(fontSize: 16, color: Colors.white38),
//           //             ),
//           //             value: deliverySystemName,
//           //             groupValue: orderNowController.deliverySys,
//           //             onChanged: (newDeliverySystemValue)
//           //             {
//           //               orderNowController.setDeliverySystem(newDeliverySystemValue!);
//           //             },
//           //           )
//           //       );
//           //     }).toList(),
//           //   ),
//           // ),
//
//           //payment system
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           //   child: Column(
//           //     crossAxisAlignment: CrossAxisAlignment.start,
//           //     children: const [
//           //       Text(
//           //         'Payment System:',
//           //         style: TextStyle(
//           //           fontSize: 18,
//           //           color: Colors.white70,
//           //           fontWeight: FontWeight.bold,
//           //         ),
//           //       ),
//           //
//           //       SizedBox(height: 2),
//
//                 // Text(
//                 //   'Company Account Number / ID: \nY87Y-HJF9-CVBN-4321',
//                 //   style: TextStyle(
//                 //     fontSize: 14,
//                 //     color: Colors.white38,
//                 //     fontWeight: FontWeight.bold,
//                 //   ),
//                 // ),
//           //     ],
//           //   ),
//           // ),
//
//           //payment system backup
//
//           // Padding(
//           //   padding: const EdgeInsets.all(18.0),
//           //   child: Column(
//           //     children: paymentSystemNamesList.map((paymentSystemName)
//           //     {
//           //       return Obx(()=>
//           //           RadioListTile<String>(
//           //             tileColor: Colors.white24,
//           //             dense: true,
//           //             activeColor: Colors.orangeAccent,
//           //             title: Text(
//           //               paymentSystemName,
//           //               style: const TextStyle(fontSize: 16, color: Colors.white38),
//           //             ),
//           //             value: paymentSystemName,
//           //             groupValue: orderNowController.paymentSys,
//           //             onChanged: (newPaymentSystemValue)
//           //             {
//           //               orderNowController.setPaymentSystem(newPaymentSystemValue!);
//           //             },
//           //           )
//           //       );
//           //     }).toList(),
//           //   ),
//           // ),
//
//           const SizedBox(height: 16),
//
//           //Full Name
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               'Full Name:',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white70,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.white54
//               ),
//               controller: nameController,
//               decoration: InputDecoration(
//                 hintText: 'Full Name..',
//                 hintStyle: const TextStyle(
//                   color: Colors.white24,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.grey,
//                     width: 2,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.white24,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           //Email
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               'Email:',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white70,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.white54
//               ),
//               controller: emailController,
//               decoration: InputDecoration(
//                 hintText: 'Email..',
//                 hintStyle: const TextStyle(
//                   color: Colors.white24,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.grey,
//                     width: 2,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.white24,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           //phone number
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               'Phone Number:',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white70,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.white54
//               ),
//               controller: phoneNumberController,
//               decoration: InputDecoration(
//                 hintText: 'Contact Number..',
//                 hintStyle: const TextStyle(
//                   color: Colors.white24,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.grey,
//                     width: 2,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.white24,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           //shipment address
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               'Shipping Address:',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white70,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.white54
//               ),
//               controller: shipmentAddressController,
//               decoration: InputDecoration(
//                 hintText: 'your Shipping Address..',
//                 hintStyle: const TextStyle(
//                   color: Colors.white24,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.grey,
//                     width: 2,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.white24,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           //note to seller
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               'Note to Seller:',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white70,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.white54
//               ),
//               controller: noteToSellerController,
//               decoration: InputDecoration(
//                 hintText: 'Any note you want to write to seller..',
//                 hintStyle: const TextStyle(
//                   color: Colors.white24,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.grey,
//                     width: 2,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Colors.white24,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 30),
//
//           //pay amount now btn
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Material(
//               color: Colors.orangeAccent,
//               borderRadius: BorderRadius.circular(30),
//               child: InkWell(
//                 onTap: ()
//                 {
//                   if(phoneNumberController.text.isNotEmpty && shipmentAddressController.text.isNotEmpty)
//                   {
//
//                     showDialogBoxForImagePickingAndCapturing(context);
//
//                     // Get.to(OrderConfirmationScreen(
//                     //   selectedCartIDs: selectedCartIDs,
//                     //   selectedCartListItemsInfo: selectedCartListItemsInfo,
//                     //   totalAmount: totalAmount,
//                     //   // deliverySystem: orderNowController.deliverySys,
//                     //   paymentSystem: orderNowController.paymentSys,
//                     //   phoneNumber: phoneNumberController.text,
//                     //   shipmentAddress: shipmentAddressController.text,
//                     //   note: noteToSellerController.text,
//                     // ));
//
//                   }
//                   else
//                   {
//                     Fluttertoast.showToast(msg: "Please complete the form.");
//                   }
//                 },
//                 borderRadius: BorderRadius.circular(30),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//
//                       Text(
//                         "\₹" + totalAmount!.toStringAsFixed(2),
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//
//                       Spacer(),
//
//                       const Text(
//                         "Pay Amount Now",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 30),
//
//         ],
//       ),
//     );
//   }
//
//   //display added item to cart
//   displaySelectedItemsFromUserCart()
//   {
//     return Column(
//       children: List.generate(selectedCartListItemsInfo!.length, (index)
//       {
//         Map<String, dynamic> eachSelectedItem = selectedCartListItemsInfo![index];
//
//         return Container(
//           margin: EdgeInsets.fromLTRB(
//             16,
//             index == 0 ? 16 : 8,
//             16,
//             index == selectedCartListItemsInfo!.length - 1 ? 16 : 8,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.white24,
//             boxShadow:
//             const [
//               BoxShadow(
//                 offset: Offset(0, 0),
//                 blurRadius: 6,
//                 color: Colors.black26,
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//
//               //image
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   bottomLeft: Radius.circular(20),
//                 ),
//                 child: FadeInImage(
//                   height: 150,
//                   width: 130,
//                   fit: BoxFit.cover,
//                   placeholder: const AssetImage("images/place_holder.png"),
//                   image: NetworkImage(
//                     eachSelectedItem["image"],
//                   ),
//                   imageErrorBuilder: (context, error, stackTraceError)
//                   {
//                     return const Center(
//                       child: Icon(
//                         Icons.broken_image_outlined,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               //name
//               //size
//               //price
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       //name
//                       Text(
//                         eachSelectedItem["name"],
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.white70,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       //size + color
//                       Text(
//                         eachSelectedItem["size"].replaceAll("[", "").replaceAll("]", "") + "\n" + eachSelectedItem["color"].replaceAll("[", "").replaceAll("]", ""),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white54,
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       //price
//                       Text(
//                         "\₹ " + eachSelectedItem["totalAmount"].toString(),
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.orangeAccent,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//
//                       Text(
//                         eachSelectedItem["price"].toString() + " x "
//                             + eachSelectedItem["quantity"].toString()
//                             + " = " + eachSelectedItem["totalAmount"].toString(),
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 12,
//                         ),
//                       ),
//
//
//                     ],
//                   ),
//                 ),
//               ),
//
//               //quantity
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "Q: " + eachSelectedItem["quantity"].toString(),
//                   style: const TextStyle(
//                     fontSize: 24,
//                     color: Colors.orangeAccent,
//                   ),
//                 ),
//               ),
//
//
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }
