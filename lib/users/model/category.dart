class Category
{
  int? category_id;
  String? category_name;
  String? category_imagelink;

  Category({
    this.category_id,
    this.category_name,
    this.category_imagelink,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    category_id: int.parse(json["category_id"]),
    category_name: json["category_name"],
    category_imagelink: json['category_imagelink'],
  );
}