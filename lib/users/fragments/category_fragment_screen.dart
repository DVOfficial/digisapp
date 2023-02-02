import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../api_connection/api_connection.dart';
import '../cart/cart_list_screen.dart';
import '../item/all_items_screen.dart';
import '../item/item_details_screen.dart';
import '../item/search_items.dart';
import '../model/category.dart';
import '../model/clothes.dart';


class CategoryFragmentScreen extends StatelessWidget
{
  TextEditingController searchController = TextEditingController();

  Future<List<Category>> getAllClothItems() async
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 16,),

          //search bar widget
          showSearchBarWidget(),

          const SizedBox(height: 24,),

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

          allItemWidget(context),

        ],
      ),
    );
  }

  Widget showSearchBarWidget()
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        style: const TextStyle(color: Colors.white),
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
          hintText: "Search organic products here...",
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          suffixIcon: IconButton(
            onPressed: ()
            {
              Get.to(CartListScreen());
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

  // Widget trendingMostPopularClothItemWidget(context)
  // {
  //   return FutureBuilder(
  //     future: getTrendingClothItems(),
  //     builder: (context, AsyncSnapshot<List<Clothes>> dataSnapShot)
  //     {
  //       if(dataSnapShot.connectionState == ConnectionState.waiting)
  //       {
  //         return const Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       }
  //       if(dataSnapShot.data == null)
  //       {
  //         return const Center(
  //           child: Text(
  //             "No Trending item found",
  //           ),
  //         );
  //       }
  //       if(dataSnapShot.data!.length > 0)
  //       {
  //         return SizedBox(
  //           height: 260,
  //           child: ListView.builder(
  //             itemCount: dataSnapShot.data!.length,
  //             scrollDirection: Axis.horizontal,
  //             itemBuilder: (context, index)
  //             {
  //               Clothes eachClothItemData = dataSnapShot.data![index];
  //               return GestureDetector(
  //                 onTap: ()
  //                 {
  //                   Get.to(ItemDetailsScreen(itemInfo: eachClothItemData));
  //                 },
  //                 child: Container(
  //                   width: 200,
  //                   margin: EdgeInsets.fromLTRB(
  //                     index == 0 ? 16 : 8,
  //                     10,
  //                     index == dataSnapShot.data!.length - 1 ? 16 : 8,
  //                     10,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(20),
  //                     color: Colors.black,
  //                     boxShadow:
  //                     const [
  //                       BoxShadow(
  //                         offset: Offset(0,3),
  //                         blurRadius: 6,
  //                         color: Colors.grey,
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     children: [
  //
  //                       //item image
  //                       ClipRRect(
  //                         borderRadius: const BorderRadius.only(
  //                           topLeft: Radius.circular(22),
  //                           topRight: Radius.circular(22),
  //                         ),
  //                         child: FadeInImage(
  //                           height: 150,
  //                           width: 200,
  //                           fit: BoxFit.cover,
  //                           placeholder: const AssetImage("images/place_holder.png"),
  //                           image: NetworkImage(
  //                             eachClothItemData.image!,
  //                           ),
  //                           imageErrorBuilder: (context, error, stackTraceError)
  //                           {
  //                             return const Center(
  //                               child: Icon(
  //                                 Icons.broken_image_outlined,
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //
  //                       //item name & price
  //                       //rating stars & rating numbers
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //
  //                             //item name & price
  //                             Row(
  //                               children: [
  //                                 Expanded(
  //                                   child: Text(
  //                                     eachClothItemData.name!,
  //                                     maxLines: 2,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: const TextStyle(
  //                                       color: Colors.grey,
  //                                       fontSize: 16,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 const SizedBox(
  //                                   width: 10,
  //                                 ),
  //                                 Text(
  //                                   "\₹ " + eachClothItemData.price.toString(),
  //                                   style: const TextStyle(
  //                                     color: Colors.purpleAccent,
  //                                     fontSize: 18,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //
  //                             const SizedBox(height: 8,),
  //
  //                             //rating stars & rating numbers
  //                             Row(
  //                               children: [
  //
  //                                 RatingBar.builder(
  //                                   initialRating: eachClothItemData.rating!,
  //                                   minRating: 1,
  //                                   direction: Axis.horizontal,
  //                                   allowHalfRating: true,
  //                                   itemCount: 5,
  //                                   itemBuilder: (context, c)=> const Icon(
  //                                     Icons.star,
  //                                     color: Colors.amber,
  //                                   ),
  //                                   onRatingUpdate: (updateRating){},
  //                                   ignoreGestures: true,
  //                                   unratedColor: Colors.grey,
  //                                   itemSize: 20,
  //                                 ),
  //
  //                                 const SizedBox(width: 8,),
  //
  //                                 Text(
  //                                   "(" + eachClothItemData.rating.toString() + ")",
  //                                   style: const TextStyle(
  //                                     color: Colors.grey,
  //                                   ),
  //                                 ),
  //
  //                               ],
  //                             ),
  //
  //                           ],
  //                         ),
  //                       ),
  //
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         );
  //       }
  //       else
  //       {
  //         return const Center(
  //           child: Text("Empty, No Data."),
  //         );
  //       }
  //     },
  //   );
  // }

  allItemWidget(context)
  {
    return FutureBuilder(
        future: getAllClothItems(),
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
                "No categories found",
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
                Category eachCategoryItemRecord = dataSnapShot.data![index];

                return GestureDetector(
                  onTap: ()
                  {
                    Get.to(AllItemsScreen(itemInfo: eachCategoryItemRecord));

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
                      color: Colors.black,
                      boxShadow:
                      const [
                        BoxShadow(
                          offset: Offset(0,0),
                          blurRadius: 6,
                          color: Colors.white,
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
                                        eachCategoryItemRecord.category_name!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // //price
                                    // Padding(
                                    //   padding: const EdgeInsets.only(left: 12, right: 12),
                                    //   child: Text(
                                    //     "\₹ " + eachClothItemRecord.price.toString(),
                                    //     maxLines: 2,
                                    //     overflow: TextOverflow.ellipsis,
                                    //     style: const TextStyle(
                                    //       fontSize: 18,
                                    //       color: Colors.purpleAccent,
                                    //       fontWeight: FontWeight.bold,
                                    //     ),
                                    //   ),
                                    // ),

                                  ],
                                ),

                                const SizedBox(height: 16,),

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

                        //image clothes
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
}
