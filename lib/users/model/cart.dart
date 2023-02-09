class Cart
{
  int? cart_id;
  int? user_id;
  int? item_id;
  int? quantity;
  // String? color;
  String? size;
  String? name;
  // double? rating;
  // List<String>? tags;
  double? price;
  String? sizes;
  // List<String>? colors;
  String? description;
  String? image;
  String? outofstock;
  String? subtext;

  Cart({
    this.cart_id,
    this.user_id,
    this.item_id,
    this.quantity,
    // this.color,
    this.size,
    this.name,
    // this.rating,
    // this.tags,
    this.price,
    this.sizes,
    // this.colors,
    this.description,
    this.image,
    this.outofstock,
    this.subtext,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    cart_id: int.parse(json['cart_id']),
    user_id: int.parse(json['user_id']),
    item_id: int.parse(json['item_id']),
    quantity: int.parse(json['quantity']),
    // color: json['color'],
    size: json['size'],
    name: json['name'],
    // rating: double.parse(json['rating']),
    // tags: json['tags'].toString().split(', '),
    price: double.parse(json['price']),
    sizes: json['sizes'].toString(),
    // colors: json['colors'].toString().split(', '),
    description: json['description'],
    image: json['image'],
    outofstock: json['outofstock'],
    subtext: json['subtext'],
  );
}