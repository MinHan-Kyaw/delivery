class Note {
  int _id;
  String _syskey;
  String _code;
  String _desc;
  String _img;
  String _packTypeCode;
  String _packSizeCode;
  String _floverCode;
  String _brandCode;
  String _brandOwnerCode;
  String _brandOwnerName;
  String _brandOwnerSyskey;
  String _vendorCode;
  String _categoryCode;
  String _subCategoryCode;
  String _whCode;
  String _whSyskey;
  String _details;

  Note(
      this._syskey,
      this._code,
      this._desc,
      this._img,
      this._packTypeCode,
      this._packSizeCode,
      this._floverCode,
      this._brandCode,
      this._brandOwnerCode,
      this._brandOwnerName,
      this._brandOwnerSyskey,
      this._vendorCode,
      this._categoryCode,
      this._subCategoryCode,
      this._whCode,
      this._whSyskey,
      this._details);
  Note.withId(
      this._id,
      this._syskey,
      this._code,
      this._desc,
      this._img,
      this._packTypeCode,
      this._packSizeCode,
      this._floverCode,
      this._brandCode,
      this._brandOwnerCode,
      this._brandOwnerName,
      this._brandOwnerSyskey,
      this._vendorCode,
      this._categoryCode,
      this._subCategoryCode,
      this._whCode,
      this._whSyskey,
      this._details);

  int get id => _id;

  String get syskey => _syskey;

  String get code => _code;

  String get desc => _desc;

  String get img => _img;

  String get packTypeCode => _packTypeCode;

  String get packSizeCode => _packSizeCode;

  String get floverCode => _floverCode;

  String get brandCode => _brandCode;

  String get brandOwnerCode => _brandOwnerCode;

  String get brandOwnerName => _brandOwnerName;

  String get brandOwnerSyskey => _brandOwnerSyskey;

  String get vendorCode => _vendorCode;

  String get categoryCode => _categoryCode;

  String get subCategoryCode => _subCategoryCode;

  String get whCode => _whCode;

  String get whSyskey => _whSyskey;

  String get details => _details;

  set syskey(String newsyskey) {
    this._syskey = newsyskey;
  }

  set code(String newcode) {
    this._code = newcode;
  }

  set desc(String newdesc) {
    this._desc = newdesc;
  }

  set img(String newImg) {
    this._img = newImg;
  }

  set packTypeCode(String newpackTypeCode) {
    this._packTypeCode = newpackTypeCode;
  }

  set packSizeCode(String newpackSizeCode) {
    this._packSizeCode = newpackSizeCode;
  }

  set floverCode(String newfloverCode) {
    this._floverCode = newfloverCode;
  }

  set brandCode(String newbrandCode) {
    this._brandCode = newbrandCode;
  }

  set brandOwnerCode(String newbrandOwnerCode) {
    this._brandOwnerCode = newbrandOwnerCode;
  }

  set brandOwnerName(String newbrandOwnerName) {
    this._brandOwnerName = newbrandOwnerName;
  }

  set brandOwnerSyskey(String newbrandOwnerSyskey) {
    this._brandOwnerSyskey = newbrandOwnerSyskey;
  }

  set vendorCode(String newvendorCode) {
    this._vendorCode = newvendorCode;
  }

  set categoryCode(String newcategoryCode) {
    this._categoryCode = newcategoryCode;
  }

  set subCategoryCode(String newsubCategoryCode) {
    this._subCategoryCode = newsubCategoryCode;
  }

  set whCode(String newwhCode) {
    this._whCode = newwhCode;
  }

  set whSyskey(String newwhSyskey) {
    this._whSyskey = newwhSyskey;
  }

  set details(String newdetails) {
    this._details = newdetails;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }

    map['syskey'] = _syskey;
    map['code'] = _code;
    map['desc'] = _desc;
    map['img'] = _img;
    map['packTypeCode'] = _packTypeCode;
    map['packSizeCode'] = _packSizeCode;
    map['floverCode'] = _floverCode;
    map['brandCode'] = _brandCode;
    map['brandOwnerCode'] = _brandOwnerCode;
    map['brandOwnerName'] = _brandOwnerName;
    map['brandOwnerSyskey'] = _brandOwnerSyskey;
    map['vendorCode'] = _vendorCode;
    map['categoryCode'] = _categoryCode;
    map['subCategoryCode'] = _subCategoryCode;
    map['whCode'] = _whCode;
    map['whSyskey'] = _whSyskey;
    map['details'] = _details;

    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._syskey = map['syskey'];
    this._code = map['code'];
    this._desc = map['desc'];
    this._img = map['img'];
    this._packTypeCode = map['packTypeCode'];
    this._packSizeCode = map['packSizeCode'];
    this._floverCode = map['floverCode'];
    this._brandCode = map['brandCode'];
    this._brandOwnerCode = map['brandOwnerCode'];
    this._brandOwnerName = map['brandOwnerName'];
    this._brandOwnerSyskey = map['brandOwnerSyskey'];
    this._vendorCode = map['vendorCode'];
    this._categoryCode = map['categoryCode'];
    this._subCategoryCode = map['subCategoryCode'];
    this._whCode = map['whCode'];
    this._whSyskey = map['whSyskey'];
    this._details = map['details'];
  }
}
