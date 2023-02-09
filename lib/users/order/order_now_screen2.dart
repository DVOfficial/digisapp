
import 'dart:convert';
import 'dart:io';

import 'package:digisapp/users/order/razorpay1.dart';
import 'package:digisapp/users/order/razorpay_order.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../api_connection/api_connection.dart';
import '../controllers/cart_list_controller.dart';
import '../controllers/order_now_controller.dart';
import '../fragments/dashboard_of_fragments.dart';
import '../model/order.dart';
import '../userPreferences/current_user.dart';
import 'OrderConfirmationScreen1.dart';
import 'order_confirmation.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'razor_credentials.dart' as razorCredentials;

import 'order_details.dart';


class OrderNowScreen2 extends StatefulWidget
{

  final List<Map<String, dynamic>>? selectedCartListItemsInfo;
  final double? totalAmount;
  final List<int>? selectedCartIDs;


  OrderNowScreen2({
    this.selectedCartListItemsInfo,
    this.totalAmount,
    this.selectedCartIDs,
  });

  @override
  State<OrderNowScreen2> createState() => _OrderNowScreen2State();
}

class _OrderNowScreen2State extends State<OrderNowScreen2> {

  var _razorpay = Razorpay();
  OrderNowController orderNowController = Get.put(OrderNowController());

  // List<String> deliverySystemNamesList = ["Standard Shipping\n(Next Day- 2pm to 6pm)", "Priority Shipping (WEFAST)\nNext Day before 2PM"];
  List<String> paymentSystemNamesList = ["Razorpay\n(Credit/ Debit Card/ UPI/Net Banking)","Cash On Delivery"];

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController shipmentAddressController = TextEditingController();
  TextEditingController noteToSellerController = TextEditingController();
  CurrentUser currentUser = Get.put(CurrentUser());



  // final _razorpay = Razorpay();
  // OrderNowController orderNowController = Get.put(OrderNowController());
  CartListController cartListController = Get.put(CartListController());
  int _counter = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    });
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print(response);
    verifySignature(
      signature: response.signature,
      paymentId: response.paymentId,
      orderId: response.orderId,
    );
    // Get.to(DashboardOfFragments());
    cartListController.setIs_PaymentSuccess();
    Fluttertoast.showToast(msg: "Payment Success"+response.toString());
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(response.toString()),
    //   ),
    // );
    // String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
    // Order order = Order(
    //         order_id: 1,
    //         user_id: widget.currentUser.user.user_id,
    //         user_name: widget.name,
    //         user_email: widget.email,
    //         selectedItems: selectedItemsString,
    //         // deliverySystem: deliverySystem,
    //         paymentSystem: widget.paymentSystem,
    //         note: widget.note,
    //         totalAmount: widget.totalAmount,
    //         // image: DateTime.now().millisecondsSinceEpoch.toString() + "-" + imageSelectedName,
    //         status: "new",
    //         dateTime: DateTime.now(),
    //         shipmentAddress: widget.shipmentAddress,
    //         phoneNumber:  widget.phoneNumber,
    //       );
    Get.to(Razorpay_Order(
      selectedCartIDs: widget.selectedCartIDs,
      selectedCartListItemsInfo: widget.selectedCartListItemsInfo,
      totalAmount: widget.totalAmount,
      // deliverySystem: orderNowController.deliverySys,
      paymentSystem: orderNowController.paymentSys,
      phoneNumber: phoneNumberController.text,
      email: emailController.text,
      shipmentAddress: shipmentAddressController.text,
      note: noteToSellerController.text,
      name:  nameController.text,
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(response);
    // Do something when payment fails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? ''),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(response);
    // Do something when an external wallet is selected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.walletName ?? ''),
      ),
    );
  }

// create order
  void createOrder() async {
    String username = razorCredentials.keyId;
    String password = razorCredentials.keySecret;
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Map<String, dynamic> body = {
      "amount": (widget.totalAmount)!*100,
      "currency": "INR",
      "receipt": "rcptid_11"
    };
    var res = await http.post(
      Uri.https(
          "api.razorpay.com", "v1/orders"), //https://api.razorpay.com/v1/orders
      headers: <String, String>{
        "Content-Type": "application/json",
        'authorization': basicAuth,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      openGateway(jsonDecode(res.body)['id']);
    }
    print(res.body);
  }

  openGateway(String orderId) {
    String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");

    var options = {
      'key': razorCredentials.keyId,
      'amount': (widget.totalAmount)!*100, //in the smallest currency sub-unit.
      'name': 'Vivers Express Pvt Ltd',
      'order_id': orderId, // Generate order_id using Orders API
      'description': selectedItemsString,
      'timeout': 60 * 5, // in seconds // 5 minutes
      'prefill': {
        'contact': phoneNumberController.text,
        'email': emailController.text,
      }
    };
    _razorpay.open(options);
  }

  verifySignature({
    String? signature,
    String? paymentId,
    String? orderId,
  }) async {
    Map<String, dynamic> body = {
      'razorpay_signature': signature,
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
    };

    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "10.0.2.2", // my ip address , localhost
        "razorpay_signature_verify.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    if (res.statusCode == 200) {
      // saveNewOrderInfo();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.body),
        ),
      );
    }
  }


  saveNewOrderInfo() async
  {
    String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
    print(("error:"+selectedItemsString));
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd MMMM, yyyy  hh:mm a').format(now);
    Order order = Order(
      order_id: 10,
      user_id: currentUser.user.user_id,
      user_name: nameController.text,
      user_email: emailController.text,
      selectedItems: selectedItemsString,
      // deliverySystem: deliverySystem,
      paymentSystem: orderNowController.paymentSys,
      note: noteToSellerController.text,
      totalAmount: widget.totalAmount,
      // image: DateTime.now().millisecondsSinceEpoch.toString() + "-" + imageSelectedName,
      status: "new",
      dateTime: DateTime.now(),
      shipmentAddress: shipmentAddressController.text,
      phoneNumber: phoneNumberController.text,
      dateTime1: formattedDate,
    );

    try
    {
      var res = await http.post(
        Uri.parse(API.addOrder),
        body: order.toJson(),
      );

      if (res.statusCode == 200)
      {
        var responseBodyOfAddNewOrder = jsonDecode(res.body);

        if(responseBodyOfAddNewOrder["success"] == true)
        {
          //delete selected items from user cart
          widget.selectedCartIDs!.forEach((eachSelectedItemCartID)
          {
            deleteSelectedItemsFromUserCartList(eachSelectedItemCartID);
            Get.to(OrderDetailsScreen(
              clickedOrderInfo: order,
            ));

          });
        }
        else
        {
          Fluttertoast.showToast(msg: "Error:: \nyour new order do NOT placed.");
        }
      }
    }
    catch(erroeMsg)
    {
      Fluttertoast.showToast(msg: "Error1: " + erroeMsg.toString());
    }
  }

  deleteSelectedItemsFromUserCartList(int cartID) async
  {
    try
    {
      var res = await http.post(
          Uri.parse(API.deleteSelectedItemsFromCartList),
          body:
          {
            "cart_id": cartID.toString(),
          }
      );

      if(res.statusCode == 200)
      {
        var responseBodyFromDeleteCart = jsonDecode(res.body);

        if(responseBodyFromDeleteCart["success"] == true)
        {
          Fluttertoast.showToast(msg: "your new order has been placed Successfully.");

          // Get.to(DashboardOfFragments());
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Error, Status Code is not 200");
      }
    }
    catch(errorMessage)
    {
      print("Error2: " + errorMessage.toString());

      Fluttertoast.showToast(msg: "Error3: " + errorMessage.toString());
    }
  }

  showDialogBoxForImagePickingAndCapturing(context)
  {
    return showDialog(
        context: context,
        builder: (context)
        {
          return SimpleDialog(
            backgroundColor: Colors.white,

            title: const Text(
              "Please Select Payment Mode",
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              SimpleDialogOption(
                onPressed: ()
                {
                  // String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
                  orderNowController.setPaymentSystem("RazorPay");
                  // var options = {
                  //   'key': "rzp_live_KXP39ErEKPxpxe",
                  //   'amount': widget.totalAmount,
                  //   'name': nameController.text,
                  //   'description': selectedItemsString,
                  //   'timeout':300,
                  //
                  // };
                  // try{
                  //   _razorpay.open(options);
                  // }catch(e){
                  //   print("Error"+e.toString());
                  //   Fluttertoast.showToast(msg: e.toString());


                  // Get.back();
                  // captureImageWithPhoneCamera();

                  createOrder();
                  // Get.to(Razorpay_test(
                  //   selectedCartIDs: widget.selectedCartIDs,
                  //   selectedCartListItemsInfo: widget.selectedCartListItemsInfo,
                  //   totalAmount: widget.totalAmount,
                  //   // deliverySystem: orderNowController.deliverySys,
                  //   paymentSystem: orderNowController.paymentSys,
                  //   phoneNumber: phoneNumberController.text,
                  //   email: emailController.text,
                  //   shipmentAddress: shipmentAddressController.text,
                  //   note: noteToSellerController.text,
                  //   name:  nameController.text,
                  // ));
                },
                child: const Text(
                  "Razorpay via UPI\n(Credit/Debit Card or Net Banking)",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SimpleDialogOption(
                onPressed: ()
                {
                  orderNowController.setPaymentSystem("Cash_On_Delivery");
                  // pickImageFromPhoneGallery();
                  // Get.to(OrderConfirmationScreen1(
                  //       selectedCartIDs: selectedCartIDs,
                  //       selectedCartListItemsInfo: selectedCartListItemsInfo,
                  //       totalAmount: totalAmount,
                  //       // deliverySystem: orderNowController.deliverySys,
                  //       paymentSystem: orderNowController.paymentSys,
                  //       phoneNumber: phoneNumberController.text,
                  //       shipmentAddress: shipmentAddressController.text,
                  //       note: noteToSellerController.text,
                  //     ));

                  saveNewOrderInfo();
                  // String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
                  // print(("error:"+selectedItemsString));
                  // Order order = Order(
                  //   order_id: 1,
                  //   user_id: currentUser.user.user_id,
                  //   user_name: nameController.text,
                  //   user_email: emailController.text,
                  //   selectedItems: selectedItemsString,
                  //   // deliverySystem: deliverySystem,
                  //   paymentSystem: orderNowController.paymentSys,
                  //   note: noteToSellerController.text,
                  //   totalAmount: widget.totalAmount,
                  //   // image: DateTime.now().millisecondsSinceEpoch.toString() + "-" + imageSelectedName,
                  //   status: "new",
                  //   dateTime: DateTime.now(),
                  //   shipmentAddress: shipmentAddressController.text,
                  //   phoneNumber: phoneNumberController.text,
                  // );
                  //
                  // Get.to(OrderDetailsScreen(
                  //     clickedOrderInfo: order,
                  // ));



                },
                child: const Text(
                  "Cash On Delivery",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SimpleDialogOption(
                onPressed: ()
                {
                  Get.back();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context)
  {
    nameController=TextEditingController(text:currentUser.user.user_name);
    emailController=TextEditingController(text:currentUser.user.user_email);
    // nameController.text=currentUser.user.user_name;
    // emailController.text=currentUser.user.user_email;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
            "Order Now"
        ),
        titleSpacing: 0,
      ),
      body: ListView(
        children: [

          //display selected items from cart list
          displaySelectedItemsFromUserCart(),

          const SizedBox(height: 30),


          const SizedBox(height: 16),

          //Full Name
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Full Name:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(
                  color: Colors.grey
              ),
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Full Name..',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black54,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          //Email
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Email:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(
                  color: Colors.grey
              ),
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email..',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black54,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          //phone number
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Phone Number:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(
                  color: Colors.grey
              ),
              controller: phoneNumberController,
              decoration: InputDecoration(
                hintText: 'Contact Number..',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black54,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          //shipment address
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Shipping Address:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(
                  color: Colors.grey
              ),
              controller: shipmentAddressController,
              decoration: InputDecoration(
                hintText: 'your Shipping Address..',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black54,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          //note to seller
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Note to Seller:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(
                  color: Colors.grey
              ),
              controller: noteToSellerController,
              decoration: InputDecoration(
                hintText: 'Any note you want to write to seller..',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black54,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          //pay amount now btn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: ()
                {
                  if(phoneNumberController.text.isNotEmpty && shipmentAddressController.text.isNotEmpty)
                  {

                    showDialogBoxForImagePickingAndCapturing(context);

                    // Get.to(OrderConfirmationScreen(
                    //   selectedCartIDs: selectedCartIDs,
                    //   selectedCartListItemsInfo: selectedCartListItemsInfo,
                    //   totalAmount: totalAmount,
                    //   // deliverySystem: orderNowController.deliverySys,
                    //   paymentSystem: orderNowController.paymentSys,
                    //   phoneNumber: phoneNumberController.text,
                    //   shipmentAddress: shipmentAddressController.text,
                    //   note: noteToSellerController.text,
                    // ));

                  }
                  else
                  {
                    Fluttertoast.showToast(msg: "Please complete the form.");
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [

                      Text(
                        "\₹" + widget.totalAmount!.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Spacer(),

                      const Text(
                        "Pay Amount Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

        ],
      ),
    );
  }

  //display added item to cart
  displaySelectedItemsFromUserCart()
  {
    return Column(
      children: List.generate(widget.selectedCartListItemsInfo!.length, (index)
      {
        Map<String, dynamic> eachSelectedItem = widget.selectedCartListItemsInfo![index];

        return Container(
          margin: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 16 : 8,
            16,
            index == widget.selectedCartListItemsInfo!.length - 1 ? 16 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black54,
            boxShadow:
            const [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 6,
                color: Colors.black26,
              ),
            ],
          ),
          child: Row(
            children: [

              //image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: FadeInImage(
                  height: 150,
                  width: 130,
                  fit: BoxFit.cover,
                  placeholder: const AssetImage("images/place_holder.png"),
                  image: NetworkImage(
                    eachSelectedItem["image"],
                  ),
                  imageErrorBuilder: (context, error, stackTraceError)
                  {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                      ),
                    );
                  },
                ),
              ),

              //name
              //size
              //price
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //name
                      Text(
                        eachSelectedItem["name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      //size + color
                      Text(
                        eachSelectedItem["size"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 16),

                      //price
                      Text(
                        "\₹ " + eachSelectedItem["totalAmount"].toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        eachSelectedItem["price"].toString() + " x "
                            + eachSelectedItem["quantity"].toString()
                            + " = " + eachSelectedItem["totalAmount"].toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),


                    ],
                  ),
                ),
              ),

              //quantity
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Qty: " + eachSelectedItem["quantity"].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),


            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose(){
    _razorpay.clear();

  }
}



class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }

}


//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:get/get.dart';
//
// import '../../api_connection/api_connection.dart';
// import '../controllers/order_now_controller.dart';
// import '../fragments/dashboard_of_fragments.dart';
// import '../model/order.dart';
//
// import '../userPreferences/current_user.dart';
// import 'OrderConfirmationScreen1.dart';
// import 'order_confirmation.dart';
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;
// import 'razor_credentials.dart' as razorCredentials;
//
// import 'order_details.dart';
//
//
// class OrderNowScreen2 extends StatefulWidget
// {
//
//   final List<Map<String, dynamic>>? selectedCartListItemsInfo;
//   final double? totalAmount;
//   final List<int>? selectedCartIDs;
//
//
//   OrderNowScreen2({
//     this.selectedCartListItemsInfo,
//     this.totalAmount,
//     this.selectedCartIDs,
//   });
//
//   @override
//   State<OrderNowScreen2> createState() => _OrderNowScreen2State();
// }
//
// class _OrderNowScreen2State extends State<OrderNowScreen2> {
//
//   var _razorpay = Razorpay();
//   OrderNowController orderNowController = Get.put(OrderNowController());
//
//   // List<String> deliverySystemNamesList = ["Standard Shipping\n(Next Day- 2pm to 6pm)", "Priority Shipping (WEFAST)\nNext Day before 2PM"];
//   List<String> paymentSystemNamesList = ["Razorpay\n(Credit/ Debit Card/ UPI/Net Banking)","Cash On Delivery"];
//
//   TextEditingController phoneNumberController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController shipmentAddressController = TextEditingController();
//   TextEditingController noteToSellerController = TextEditingController();
//   CurrentUser currentUser = Get.put(CurrentUser());
//
//
//   // final _razorpay = Razorpay();
//
//   int _counter = 0;
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//       _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//       _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     });
//     super.initState();
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     // Do something when payment succeeds
//     print(response);
//     verifySignature(
//       signature: response.signature,
//       paymentId: response.paymentId,
//       orderId: response.orderId,
//     );
//     saveNewOrderInfo();
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     print(response);
//     // Do something when payment fails
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(response.message ?? ''),
//       ),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print(response);
//     // Do something when an external wallet is selected
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(response.walletName ?? ''),
//       ),
//     );
//   }
//
// // create order
//   void createOrder() async {
//     String username = razorCredentials.keyId;
//     String password = razorCredentials.keySecret;
//     String basicAuth =
//         'Basic ${base64Encode(utf8.encode('$username:$password'))}';
//
//     Map<String, dynamic> body = {
//       "amount": widget.totalAmount,
//       "currency": "INR",
//       "receipt": "rcptid_11"
//     };
//     var res = await http.post(
//       Uri.https(
//           "api.razorpay.com", "v1/orders"), //https://api.razorpay.com/v1/orders
//       headers: <String, String>{
//         "Content-Type": "application/json",
//         'authorization': basicAuth,
//       },
//       body: jsonEncode(body),
//     );
//
//     if (res.statusCode == 200) {
//       openGateway(jsonDecode(res.body)['id']);
//     }
//     print(res.body);
//   }
//
//   openGateway(String orderId) {
//     String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
//     var options = {
//       'key': razorCredentials.keyId,
//       'amount': widget.totalAmount, //in the smallest currency sub-unit.
//       'name': 'Vivers Express Private Limited',
//       'order_id': orderId, // Generate order_id using Orders API
//       'description': selectedItemsString,
//       'timeout': 60 * 5, // in seconds // 5 minutes
//       'prefill': {
//         'contact': phoneNumberController,
//         'email': emailController,
//       }
//     };
//     _razorpay.open(options);
//   }
//
//   verifySignature({
//     String? signature,
//     String? paymentId,
//     String? orderId,
//   }) async {
//     Map<String, dynamic> body = {
//       'razorpay_signature': signature,
//       'razorpay_payment_id': paymentId,
//       'razorpay_order_id': orderId,
//     };
//
//     var parts = [];
//     body.forEach((key, value) {
//       parts.add('${Uri.encodeQueryComponent(key)}='
//           '${Uri.encodeQueryComponent(value)}');
//     });
//     var formData = parts.join('&');
//     var res = await http.post(
//       Uri.https(
//         "10.0.2.2", // my ip address , localhost
//         "razorpay_signature_verify.php",
//       ),
//       headers: {
//         "Content-Type": "application/x-www-form-urlencoded", // urlencoded
//       },
//       body: formData,
//     );
//
//     print(res.body);
//     if (res.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(res.body),
//         ),
//       );
//     }
//   }
//
//
//   saveNewOrderInfo() async
//   {
//     String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
//     print(("error1:"+selectedItemsString));
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
//       totalAmount: widget.totalAmount,
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
//           widget.selectedCartIDs!.forEach((eachSelectedItemCartID)
//           {
//             deleteSelectedItemsFromUserCartList(eachSelectedItemCartID);
//             Get.to(OrderDetailsScreen(
//                     clickedOrderInfo: order,
//                 ));
//
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
//           // Get.to(DashboardOfFragments());
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
//   showDialogBoxForImagePickingAndCapturing(context)
//   {
//     return showDialog(
//         context: context,
//         builder: (context)
//         {
//           return SimpleDialog(
//             backgroundColor: Colors.white,
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
//                   // String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
//                   orderNowController.setPaymentSystem("RazorPay");
//                   // var options = {
//                   //   'key': "rzp_live_KXP39ErEKPxpxe",
//                   //   'amount': widget.totalAmount,
//                   //   'name': nameController.text,
//                   //   'description': selectedItemsString,
//                   //   'timeout':300,
//                   //
//                   // };
//                   try{
//                     // _razorpay.open(options);
//                     createOrder();
//                   }catch(e){
//                     print("Error"+e.toString());
//                     Fluttertoast.showToast(msg: e.toString());
//
//                   }
//                   Get.back();
//                   // captureImageWithPhoneCamera();
//                   // Get.to(OrderConfirmationScreen(
//                   //   selectedCartIDs: widget.selectedCartIDs,
//                   //   selectedCartListItemsInfo: widget.selectedCartListItemsInfo,
//                   //   totalAmount: widget.totalAmount,
//                   //   // deliverySystem: orderNowController.deliverySys,
//                   //   paymentSystem: orderNowController.paymentSys,
//                   //   phoneNumber: phoneNumberController.text,
//                   //   shipmentAddress: shipmentAddressController.text,
//                   //   note: noteToSellerController.text,
//                   // ));
//                 },
//                 child: const Text(
//                   "Razorpay via UPI\n(Credit/Debit Card or Net Banking)",
//                   style: TextStyle(
//                     color: Colors.black54,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
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
//                   // String selectedItemsString = widget.selectedCartListItemsInfo!.map((eachSelectedItem)=> jsonEncode(eachSelectedItem)).toList().join("||");
//                   // print(("error:"+selectedItemsString));
//                   // Order order = Order(
//                   //   order_id: 1,
//                   //   user_id: currentUser.user.user_id,
//                   //   user_name: nameController.text,
//                   //   user_email: emailController.text,
//                   //   selectedItems: selectedItemsString,
//                   //   // deliverySystem: deliverySystem,
//                   //   paymentSystem: orderNowController.paymentSys,
//                   //   note: noteToSellerController.text,
//                   //   totalAmount: widget.totalAmount,
//                   //   // image: DateTime.now().millisecondsSinceEpoch.toString() + "-" + imageSelectedName,
//                   //   status: "new",
//                   //   dateTime: DateTime.now(),
//                   //   shipmentAddress: shipmentAddressController.text,
//                   //   phoneNumber: phoneNumberController.text,
//                   // );
//                   //
//                   // Get.to(OrderDetailsScreen(
//                   //     clickedOrderInfo: order,
//                   // ));
//
//
//
//                 },
//                 child: const Text(
//                   "Cash On Delivery",
//                   style: TextStyle(
//                       color: Colors.black54,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SimpleDialogOption(
//                 onPressed: ()
//                 {
//                   Get.back();
//                 },
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//     );
//   }
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
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.orange,
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
//           const SizedBox(height: 16),
//           //Full Name
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               'Full Name:',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.black54,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.grey
//               ),
//               controller: nameController,
//               decoration: InputDecoration(
//                 hintText: 'Full Name..',
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
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
//                     color: Colors.black54,
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
//                 color: Colors.black54,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.grey
//               ),
//               controller: emailController,
//               decoration: InputDecoration(
//                 hintText: 'Email..',
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
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
//                     color: Colors.black54,
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
//                 color: Colors.black54,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.grey
//               ),
//               controller: phoneNumberController,
//               decoration: InputDecoration(
//                 hintText: 'Contact Number..',
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
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
//                     color: Colors.black54,
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
//                 color: Colors.black54,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.grey
//               ),
//               controller: shipmentAddressController,
//               decoration: InputDecoration(
//                 hintText: 'your Shipping Address..',
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
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
//                     color: Colors.black54,
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
//                 color: Colors.black54,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: TextField(
//               style: const TextStyle(
//                   color: Colors.grey
//               ),
//               controller: noteToSellerController,
//               decoration: InputDecoration(
//                 hintText: 'Any note you want to write to seller..',
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
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
//                     color: Colors.black54,
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
//                     // showDialogBoxForImagePickingAndCapturing(context);
//                     createOrder();
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
//                         "\₹" + widget.totalAmount!.toStringAsFixed(2),
//                         style: const TextStyle(
//                           color: Colors.black54,
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
//       children: List.generate(widget.selectedCartListItemsInfo!.length, (index)
//       {
//         Map<String, dynamic> eachSelectedItem = widget.selectedCartListItemsInfo![index];
//
//         return Container(
//           margin: EdgeInsets.fromLTRB(
//             16,
//             index == 0 ? 16 : 8,
//             16,
//             index == widget.selectedCartListItemsInfo!.length - 1 ? 16 : 8,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.black54,
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
//                           color: Colors.black54,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       //size + color
//                       Text(
//                         eachSelectedItem["size"],
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.grey,
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
//                   "Qty: " + eachSelectedItem["quantity"].toString(),
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
//
//   @override
//   void dispose() {
//     _razorpay.clear(); // Removes all listeners
//
//     super.dispose();
//   }
// }
