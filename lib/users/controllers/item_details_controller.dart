import 'package:get/get.dart';

class ItemDetailsController extends GetxController
{
  RxInt _quantityItem = 1.obs;
  RxInt _fakeCartCount = 0.obs;
  RxInt _sizeItem = 0.obs;
  RxInt _colorItem = 0.obs;
  RxDouble _updatedPrice = 0.0.obs;
  RxBool _isFavorite = false.obs;
  RxString _outofstockStatus = "Available".obs;


  int get quantity => _quantityItem.value;
  int get fakeCartCount => _fakeCartCount.value;
  double get updatedPrice => _updatedPrice.value;
  int get size => _sizeItem.value;
  int get color => _colorItem.value;
  bool get isFavorite => _isFavorite.value;
  String get outofchickenStatus => _outofstockStatus.value;

  setOutofStockStatus(String newOutofStockStatus)
  {
    _outofstockStatus.value = newOutofStockStatus;
  }

  setQuantityItem(int quantityOfItem)
  {
    _quantityItem.value = quantityOfItem;
  }
  setFakeCartCount(int fakeCartCount)
    {
      _fakeCartCount.value = fakeCartCount;
    }

  setSizeItem(int sizeOfItem)
  {
    _sizeItem.value = sizeOfItem;
  }

  setPrice(double updatedPrice)
    {
      _updatedPrice.value = updatedPrice;
    }

  setColorItem(int colorOfItem)
  {
    _colorItem.value = colorOfItem;
  }

  setIsFavorite(bool isFavorite)
  {
    _isFavorite.value = isFavorite;
  }






}