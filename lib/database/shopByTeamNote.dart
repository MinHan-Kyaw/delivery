class ShopByTeamNote {
  int _id;
  String _address;
  String _shopnamemm;
  String _shopsyskey;
  String _long;
  String _phoneno;
  String _zonecode;
  String _shopcode;
  String _shopname;
  String _teamcode;
  String _location;
  String _usercode;
  String _user;
  String _lat;
  String _email;
  String _username;

  ShopByTeamNote(
    this._address,
    this._shopnamemm,
    this._shopsyskey,
    this._long,
    this._phoneno,
    this._zonecode,
    this._shopcode,
    this._shopname,
    this._teamcode,
    this._location,
    this._usercode,
    this._user,
    this._lat,
    this._email,
    this._username,
  );
  ShopByTeamNote.withId(
    this._id,
    this._address,
    this._shopnamemm,
    this._shopsyskey,
    this._long,
    this._phoneno,
    this._zonecode,
    this._shopcode,
    this._shopname,
    this._teamcode,
    this._location,
    this._usercode,
    this._user,
    this._lat,
    this._email,
    this._username,
  );

  int get id => _id;

  String get address => _address;

  String get shopnamemm => _shopnamemm;

  String get shopsyskey => _shopsyskey;

  String get long => _long;

  String get phoneno => _phoneno;

  String get zonecode => _zonecode;

  String get shopcode => _shopcode;

  String get shopname => _shopname;

  String get teamcode => _teamcode;

  String get location => _location;

  String get usercode => _usercode;

  String get user => _user;

  String get lat => _lat;

  String get email => _email;

  String get username => _username;

  set address(String newAddress) {
    this._address = newAddress;
  }

  set shopnamemm(String newshopnamemm) {
    this._shopnamemm = newshopnamemm;
  }

  set shopsyskey(String newshopsyskey) {
    this._shopsyskey = newshopsyskey;
  }

  set long(String newlong) {
    this._long = newlong;
  }

  set phoneno(String newphoneno) {
    this._phoneno = newphoneno;
  }

  set zonecode(String newzonecode) {
    this._zonecode = newzonecode;
  }

  set shopcode(String newshopcode) {
    this._shopcode = newshopcode;
  }

  set shopname(String newshopname) {
    this._shopname = newshopname;
  }

  set teamcode(String newteamcode) {
    this._teamcode = newteamcode;
  }

  set location(String newlocation) {
    this._location = newlocation;
  }

  set usercode(String newusercode) {
    this._usercode = newusercode;
  }

  set user(String newuser) {
    this._user = newuser;
  }

  set lat(String newlat) {
    this._lat = newlat;
  }

  set email(String newemail) {
    this._email = newemail;
  }

  set username(String newusername) {
    this._username = newusername;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }

    map['address'] = _address;
    map['shopnamemm'] = _shopnamemm;
    map['shopsyskey'] = _shopsyskey;
    map['long'] = _long;
    map['phoneno'] = _phoneno;
    map['zonecode'] = _zonecode;
    map['shopcode'] = _shopcode;
    map['shopname'] = _shopname;
    map['teamcode'] = _teamcode;
    map['location'] = _location;
    map['usercode'] = _usercode;
    map['user'] = _user;
    map['lat'] = _lat;
    map['email'] = _email;
    map['username'] = _username;

    return map;
  }

  ShopByTeamNote.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._address = map['address'];
    this._shopnamemm = map['shopnamemm'];
    this._shopsyskey = map['shopsyskey'];
    this._long = map['long'];
    this._phoneno = map['phoneno'];
    this._zonecode = map['zonecode'];
    this._shopcode = map['shopcode'];
    this._shopname = map['shopname'];
    this._teamcode = map['teamcode'];
    this._location = map['location'];
    this._usercode = map['usercode'];
    this._user = map['user'];
    this._lat = map['lat'];
    this._email = map['email'];
    this._username = map['username'];
  }
}
