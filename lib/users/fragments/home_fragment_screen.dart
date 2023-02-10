import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../api_connection/api_connection.dart';
import '../cart/cart_list_screen.dart';
import '../cart/cart_list_screen1.dart';
import '../controllers/cart_list_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/item_details_controller.dart';
import '../item/all_items_screen.dart';
import '../item/item_details_screen.dart';
import '../item/item_details_screen1.dart';
import '../item/search_items.dart';
import '../model/Clothes1.dart';
import '../model/cart.dart';
import '../model/category.dart';
import '../userPreferences/current_user.dart';


class HomeFragmentScreen extends StatelessWidget
{
  final itemDetailsController = Get.put(ItemDetailsController());
  TextEditingController searchController = TextEditingController();
  CategoryController categoryController = Get.put(CategoryController());
  final cartListController = Get.put(CartListController());
  final currentOnlineUser = Get.put(CurrentUser());
//fetching trending list from phpmysql
  Future<List<Clothes1>> getTrendingClothItems() async
  {
    List<Clothes1> trendingClothItemsList = [];

    try
    {
      var res = await http.post(
          Uri.parse(API.getTrendingMostPopularClothes)
      );

      if(res.statusCode == 200)
      {
        var responseBodyOfTrending = jsonDecode(res.body);
        if(responseBodyOfTrending["success"] == true)
        {
          (responseBodyOfTrending["clothItemsData"] as List).forEach((eachRecord)
          {
            trendingClothItemsList.add(Clothes1.fromJson(eachRecord));
          });
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Error, status code is not 200");
      }
    }
    catch(errorMsg)
    {
      print("Error:: " + errorMsg.toString());
    }

    return trendingClothItemsList;
  }

  //fetching allitems list from phpmysql
  Future<List<Clothes1>> getAllClothItems() async
  {
    List<Clothes1> allClothItemsList = [];

    try
    {
      var res = await http.post(
          Uri.parse(API.getAllClothes)
      );

      if(res.statusCode == 200)
      {
        var responseBodyOfAllClothes1 = jsonDecode(res.body);
        if(responseBodyOfAllClothes1["success"] == true)
        {
          (responseBodyOfAllClothes1["clothItemsData"] as List).forEach((eachRecord)
          {
            allClothItemsList.add(Clothes1.fromJson(eachRecord));
          });
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Error, status code is not 200");
      }
    }
    catch(errorMsg)
    {
      print("Error:: " + errorMsg.toString());
    }

    return allClothItemsList;

  }

  Future<List<Category>> getAllCategory() async
  {
    List<Category> allClothItemsList = [];

    try
    {
      var res = await http.post(
          Uri.parse(API.getAllCategory)
      );

      if(res.statusCode == 200)
      {
        var responseBodyOfAllClothes = jsonDecode(res.body);
        if(responseBodyOfAllClothes["success"] == true)
        {
          (responseBodyOfAllClothes["clothItemsData"] as List).forEach((eachRecord)
          {
            allClothItemsList.add(Category.fromJson(eachRecord));
          });
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Error, status code is not 200");
      }
    }
    catch(errorMsg)
    {
      print("Error:: " + errorMsg.toString());
    }

    return allClothItemsList;
  }

  getCurrentUserCartList() async
  {
    List<Cart> cartListOfCurrentUser = [];

    try
    {
      var res = await http.post(
          Uri.parse(API.getCartList),
          body:
          {
            "currentOnlineUserID": currentOnlineUser.user.user_id.toString(),
          }
      );

      if (res.statusCode == 200)
      {
        var responseBodyOfGetCurrentUserCartItems = jsonDecode(res.body);

        if (responseBodyOfGetCurrentUserCartItems['success'] == true)
        {
          (responseBodyOfGetCurrentUserCartItems['currentUserCartData'] as List).forEach((eachCurrentUserCartItemData)
          {
            cartListOfCurrentUser.add(Cart.fromJson(eachCurrentUserCartItemData));
          });
        }
        else
        {
          Fluttertoast.showToast(msg: "your Cart List is Empty.");
        }

        cartListController.setList(cartListOfCurrentUser);
        if(cartListController.cartList.length>0)
        {
          cartListController.cartList.forEach((eachItem)
          {
            cartListController.addSelectedItem(eachItem.cart_id!);
          });
        }

        calculateTotalAmount();

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
    calculateTotalAmount();
  }


  calculateTotalAmount()
  {
    cartListController.setTotal(0);

    if(cartListController.selectedItemList.length > 0)
    {
      cartListController.cartList.forEach((itemInCart)
      {
        if(cartListController.selectedItemList.contains(itemInCart.cart_id))
        {
          double eachItemTotalAmount = (itemInCart.price!) * (double.parse(itemInCart.quantity.toString()));

          cartListController.setTotal(cartListController.total + eachItemTotalAmount);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16,),

            //search bar widget
            showSearchBarWidget(),

            const SizedBox(height: 24,),

            //trending-popular items
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Categories",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            trendingAllCategoriesItemWidget(context),
            const SizedBox(height: 24,),
            //trending-popular items
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Top Selling Products",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            trendingMostPopularClothItemWidget(context),

            const SizedBox(height: 24,),

            //all new collections/items
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "New Collections",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            allItemWidget(context),
          ],
        ),
      ),
    );
  }

//Search bar widget
  Widget showSearchBarWidget()
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        style: const TextStyle(color: Colors.black54),
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            onPressed: ()
            {
              Get.to(SearchItems(typedKeyWords: searchController.text));
            },
            icon: const Icon(
              Icons.search,
              color: Colors.orangeAccent,
            ),
          ),
          hintText: "Search Organic Products here...",
          hintStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          suffixIcon: IconButton(
            onPressed: ()
            {
              Get.to(CartListScreen1());
            },
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.orangeAccent,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.orange,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.orangeAccent,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  //trending widget
  Widget trendingMostPopularClothItemWidget(context)
  {
    return FutureBuilder(
      future: getTrendingClothItems(),
      builder: (context, AsyncSnapshot<List<Clothes1>> dataSnapShot)
      {
        if(dataSnapShot.connectionState == ConnectionState.waiting)
        {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if(dataSnapShot.data == null)
        {
          return const Center(
            child: Text(
              "No Trending item found",
            ),
          );
        }
        if(dataSnapShot.data!.length > 0)
        {
          return SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: dataSnapShot.data!.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index)
              {
                Clothes1 eachClothItemData = dataSnapShot.data![index];
                return GestureDetector(
                  onTap: ()
                  {
                    Get.to(ItemDetailsScreen(itemInfo: eachClothItemData));
                  },
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.fromLTRB(
                      index == 0 ? 16 : 8,
                      10,
                      index == dataSnapShot.data!.length - 1 ? 16 : 8,
                      10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white70,
                      boxShadow:
                      const [
                        BoxShadow(
                          offset: Offset(0,3),
                          blurRadius: 6,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        //item image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                          child: FadeInImage(
                            height: 130,
                            width: 200,
                            fit: BoxFit.cover,
                            placeholder: const AssetImage("images/place_holder.png"),
                            image: NetworkImage(
                              eachClothItemData.image!,
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

                        //item name & price
                        //rating stars & rating numbers
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              //item name & price
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eachClothItemData.name!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "\₹ " + eachClothItemData.price.toString(),
                                    style: const TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6,),
                              Text(
                                "(\₹" + eachClothItemData.subtext.toString() + ")",
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6,),
                              Material(
                                elevation: 4,
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: ()
                                  {
                                    itemDetailsController.outofchickenStatus=="Out of Stock"?
                                    Fluttertoast.showToast(msg: "Item is currently Out of Stock")
                                        :addItemToCart(eachClothItemData.item_id!,eachClothItemData.sizes!);
                                    itemDetailsController.setFakeCartCount(1);
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 30,
                                    child: const Text(
                                      "Add to Cart",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              //rating stars & rating numbers
                              // Row(
                              //   children: [
                              //
                              //     //     RatingBar.builder(
                              //     //       initialRating: eachClothItemData.rating!,
                              //     //       minRating: 1,
                              //     //       direction: Axis.horizontal,
                              //     //       allowHalfRating: true,
                              //     //       itemCount: 5,
                              //     //       itemBuilder: (context, c)=> const Icon(
                              //     //         Icons.star,
                              //     //         color: Colors.amber,
                              //     //       ),
                              //     //       onRatingUpdate: (updateRating){},
                              //     //       ignoreGestures: true,
                              //     //       unratedColor: Colors.grey,
                              //     //       itemSize: 20,
                              //     //     ),
                              //
                              //
                              //
                              //
                              //
                              //   ],
                              // ),

                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        else
        {
          return const Center(
            child: Text("Empty, No Data."),
          );
        }
      },
    );
  }

  Widget trendingAllCategoriesItemWidget(context)
  {
    return FutureBuilder(
      future: getAllCategory(),
      builder: (context, AsyncSnapshot<List<Category>> dataSnapShot)
      {
        if(dataSnapShot.connectionState == ConnectionState.waiting)
        {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if(dataSnapShot.data == null)
        {
          return const Center(
            child: Text(
              "No Categories found",
            ),
          );
        }
        if(dataSnapShot.data!.length > 0)
        {
          return SizedBox(
            height: 210,
            child: ListView.builder(
              itemCount: dataSnapShot.data!.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index)
              {
                Category eachCategoryItemRecord = dataSnapShot.data![index];
                return GestureDetector(
                  onTap: ()
                  {
                    categoryController.setCategoryName(eachCategoryItemRecord!.category_name!);
                    Get.to(AllItemsScreen(itemInfo: eachCategoryItemRecord));
                  },
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.fromLTRB(
                      index == 0 ? 16 : 8,
                      10,
                      index == dataSnapShot.data!.length - 1 ? 16 : 8,
                      10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white70,
                      boxShadow:
                      const [
                        BoxShadow(
                          offset: Offset(0,3),
                          blurRadius: 6,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        //item image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                          child: FadeInImage(
                            height: 150,
                            width: 200,
                            fit: BoxFit.cover,
                            placeholder: const AssetImage("images/place_holder.png"),
                            image: NetworkImage(
                              eachCategoryItemRecord.category_imagelink!,
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
                        const SizedBox(height: 8,),
                        Text(
                          eachCategoryItemRecord.category_name!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        else
        {
          return const Center(
            child: Text("Empty, No Data."),
          );
        }
      },
    );
  }

  //all item widget
  allItemWidget(context)
  {
    return FutureBuilder(
        future: getAllClothItems(),
        builder: (context, AsyncSnapshot<List<Clothes1>> dataSnapShot)
        {
          if(dataSnapShot.connectionState == ConnectionState.waiting)
          {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(dataSnapShot.data == null)
          {
            return const Center(
              child: Text(
                "No Trending item found",
              ),
            );
          }
          if(dataSnapShot.data!.length > 0)
          {
            return ListView.builder(
              itemCount: dataSnapShot.data!.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index)
              {
                Clothes1 eachClothItemRecord = dataSnapShot.data![index];

                return GestureDetector(
                  onTap: ()
                  {
                    Get.to(ItemDetailsScreen(itemInfo: eachClothItemRecord));
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      16,
                      index == 0 ? 16 : 8,
                      16,
                      index == dataSnapShot.data!.length - 1 ? 16 : 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white70,
                      boxShadow:
                      const [
                        BoxShadow(
                          offset: Offset(0,0),
                          blurRadius: 6,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [

                        //name + price
                        //tags
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                //name and price
                                Row(
                                  children: [

                                    //name
                                    Expanded(
                                      child: Text(
                                        eachClothItemRecord.name!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    //price
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12, right: 12),
                                      child: Text(
                                        "\₹ " + eachClothItemRecord.price.toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "\₹ " + eachClothItemRecord.subtext!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),

                                // const SizedBox(height: 16,),

                                // //tags
                                // Text(
                                //   "Tags: \n" + eachClothItemRecord.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                                //   maxLines: 2,
                                //   overflow: TextOverflow.ellipsis,
                                //   style: const TextStyle(
                                //     fontSize: 12,
                                //     color: Colors.grey,
                                //   ),
                                // ),

                              ],
                            ),
                          ),
                        ),

                        //image Clothes1
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: FadeInImage(
                            height: 130,
                            width: 130,
                            fit: BoxFit.cover,
                            placeholder: const AssetImage("images/place_holder.png"),
                            image: NetworkImage(
                              eachClothItemRecord.image!,
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

                      ],
                    ),
                  ),
                );
              },
            );
          }
          else
          {
            return const Center(
              child: Text("Empty, No Data."),
            );
          }
        }
    );
  }

  addItemToCart(int itemId, String sizes) async
  {
    try
    {
      var res = await http.post(
        Uri.parse(API.addToCart),
        body: {
          "user_id": currentOnlineUser.user.user_id.toString(),
          "item_id": itemId.toString(),
          "quantity": itemDetailsController.quantity.toString(),
          // "color": widget.itemInfo!.colors![itemDetailsController.color],
          "size": sizes,
          // "size": widget.itemInfo!.sizes![itemDetailsController.size],
        },
      );

      if(res.statusCode == 200) //from flutter app the connection with api to server - success
          {
        var resBodyOfAddCart = jsonDecode(res.body);
        if(resBodyOfAddCart['success'] == true)
        {
          Fluttertoast.showToast(msg: "item added to Cart Successfully\n Go to cart to place your order");
        }
        else
        {
          Fluttertoast.showToast(msg: "Item already added to cart");
          // Fluttertoast.showToast(msg: "Error Occur. Item not saved to Cart and Try Again.");
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    }
    catch(errorMsg)
    {
      print("Error :: " + errorMsg.toString());
    }
  }
}
