class ReturnNote {
  int _id;
  String _shopName;
  String _itemCode;
  String _itemName;
  String _itemQty;
  String _itemTolCount;

  ReturnNote(
      this._shopName,
      this._itemCode,
      this._itemName,
      this._itemQty,
      this._itemTolCount);

  ReturnNote.withId(
      this._id,
      this._shopName,
      this._itemCode,
      this._itemName,
      this._itemQty,
      this._itemTolCount);

  int get id => _id;

  String get shopName => _shopName;

  String get itemCode => _itemCode;

  String get itemName => _itemName;

  String get itemQty => _itemQty;

  String get itemTolCount => _itemTolCount;

  set shopName(String newshopName) {
    this._shopName = newshopName;
  }

  set itemCode(String newitemCode) {
    this._itemCode = newitemCode;
  }

  set itemName(String newitemName) {
    this._itemName = newitemName;
  }

  set itemQty(String newitemQty) {
    this._itemQty = newitemQty;
  }

  set itemTolCount(String newitemTolCount) {
    this._itemTolCount = newitemTolCount;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }

    map['shopName'] = _shopName;
    map['itemCode'] = _itemCode;
    map['itemName'] = _itemName;
    map['itemQty'] = _itemQty;
    map['itemTolCount'] = _itemTolCount;

    return map;
  }

  ReturnNote.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._shopName = map['shopName'];
    this._itemCode = map['itemCode'];
    this._itemName = map['itemName'];
    this._itemQty = map['itemQty'];
    this._itemTolCount = map['itemTolCount'];
  }
}
