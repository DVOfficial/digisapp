import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../api_connection/api_connection.dart';
import '../cart/cart_list_screen.dart';
import 'package:http/http.dart' as http;

import '../model/Clothes1.dart';
import 'item_details_screen.dart';
import 'item_details_screen1.dart';


class SearchItems extends StatefulWidget
{
  final String? typedKeyWords;

  SearchItems({this.typedKeyWords,});

  @override
  State<SearchItems> createState() => _SearchItemsState();
}



class _SearchItemsState extends State<SearchItems>
{
  TextEditingController searchController = TextEditingController();


  Future<List<Clothes1>> readSearchRecordsFound() async
  {
    List<Clothes1> Clothes1SearchList = [];

    if(searchController.text != "")
    {
      try
      {
        var res = await http.post(
            Uri.parse(API.searchItems),
            body:
            {
              "typedKeyWords": searchController.text,
            }
        );

        if (res.statusCode == 200)
        {
          var responseBodyOfSearchItems = jsonDecode(res.body);

          if (responseBodyOfSearchItems['success'] == true)
          {
            (responseBodyOfSearchItems['itemsFoundData'] as List).forEach((eachItemData)
            {
              Clothes1SearchList.add(Clothes1.fromJson(eachItemData));
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
    }

    return Clothes1SearchList;
  }

  @override
  void initState()
  {
    super.initState();

    searchController.text = widget.typedKeyWords!;
  }

  @override
  Widget build(BuildContext context)
  {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: showSearchBarWidget(),
          titleSpacing: 0,
          leading: IconButton(
            onPressed: ()
            {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.orangeAccent,
            ),
          ),
        ),
        body: searchItemDesignWidget(context),
      ),
    );
  }

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
              setState(() {
              });
            },
            icon: const Icon(
              Icons.search,
              color: Colors.orangeAccent,
            ),
          ),
          hintText: "Search best organic products here...",
          hintStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          suffixIcon: IconButton(
            onPressed: ()
            {
              searchController.clear();

              setState(() {
              });
            },
            icon: const Icon(
              Icons.close,
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

  searchItemDesignWidget(context)
  {
    return FutureBuilder(
        future: readSearchRecordsFound(),
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
                "No item found",
              ),
            );
          }
          if(dataSnapShot.data!.length > 0)
          {
            return ListView.builder(
              itemCount: dataSnapShot.data!.length,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
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
                      color: Colors.white54,
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
                                // Row(
                                //   children: [
                                //
                                //     //name
                                //     Expanded(
                                //       child: Text(
                                //         eachClothItemRecord.name!,
                                //         maxLines: 3,
                                //         overflow: TextOverflow.ellipsis,
                                //         style: const TextStyle(
                                //           fontSize: 18,
                                //           color: Colors.black54,
                                //           fontWeight: FontWeight.bold,
                                //         ),
                                //       ),
                                //     ),
                                //
                                //
                                //
                                //   ],
                                // ),
                                const SizedBox(height: 8,),
                                Text(
                                  eachClothItemRecord.name!,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // const SizedBox(height: 8,),

                                //tags
                                Text(
                                  "\n\???" + eachClothItemRecord.subtext.toString(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                //price
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 12),
                                  child: Text(
                                    "\??? " + eachClothItemRecord.price.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
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
}
