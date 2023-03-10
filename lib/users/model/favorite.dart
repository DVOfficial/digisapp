class Favorite
{
  int? favorite_id;
  int? user_id;
  int? item_id;
  String? name;
  String? subtext;
  // double? rating;
  // List<String>? tags;
  double? price;
  String? sizes;
  // List<String>? colors;
  String? description;
  String? image;
  String? outofstock;

  Favorite({
    this.favorite_id,
    this.user_id,
    this.item_id,
    this.name,
    this.subtext,
    // this.rating,
    // this.tags,
    this.price,
    this.sizes,
    // this.colors,
    this.description,
    this.image,
    this.outofstock,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    favorite_id: int.parse(json['favorite_id']),
    user_id: int.parse(json['user_id']),
    item_id: int.parse(json['item_id']),
    name: json['name'],
    subtext: json['subtext'],
    // rating: double.parse(json['rating']),
    // tags: json['tags'].toString().split(', '),
    price: double.parse(json['price']),
    sizes: (json['sizes']),
    // sizes: json['sizes'].toString().split(', '),
    // colors: json['colors'].toString().split(', '),
    description: json['description'],
    image: json['image'],
    outofstock: json['outofstock'],
  );
}