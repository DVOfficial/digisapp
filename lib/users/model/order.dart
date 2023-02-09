class Order
{
  int? order_id;
  int? user_id;
  String? user_name;
  String? user_email;
  String? selectedItems;
  // String? deliverySystem;
  String? paymentSystem;
  String? note;
  double? totalAmount;
  String? image;
  String? status;
  DateTime? dateTime;
  String? shipmentAddress;
  String? phoneNumber;
  String? dateTime1;

  Order({
    this.order_id,
    this.user_id,
    this.user_name,
    this.user_email,
    this.selectedItems,
    // this.deliverySystem,
    this.paymentSystem,
    this.note,
    this.totalAmount,
    this.image,
    this.status,
    this.dateTime,
    this.shipmentAddress,
    this.phoneNumber,
    this.dateTime1,
  });

  factory Order.fromJson(Map<String, dynamic> json)=> Order(
    order_id: int.parse(json["order_id"]),
    user_id: int.parse(json["user_id"]),
    user_name: json["user_name"],
    user_email: json["user_email"],
    selectedItems: json["selectedItems"],
    // deliverySystem: json["deliverySystem"],
    paymentSystem: json["paymentSystem"],
    note: json["note"],
    totalAmount: double.parse(json["totalAmount"]),
    image: json["image"],
    status: json["status"],
    dateTime: DateTime.parse(json["dateTime"]),
    shipmentAddress: json["shipmentAddress"],
    phoneNumber: json["phoneNumber"],
    dateTime1: json["dateTime1"],
  );

  Map<String, dynamic> toJson()=>
      {
        "order_id": order_id.toString(),
        "user_id": user_id.toString(),
        "user_name": user_name,
        "user_email": user_email,
        "selectedItems": selectedItems,
        // "deliverySystem": deliverySystem,
        "paymentSystem": paymentSystem,
        "note": note,
        "totalAmount": totalAmount!.toStringAsFixed(2),
        // "image": image,
        "status": status,
        "shipmentAddress": shipmentAddress,
        "phoneNumber": phoneNumber,
        "dateTime1": dateTime1,
        // "imageFile": imageSelectedBase64,
      };
}