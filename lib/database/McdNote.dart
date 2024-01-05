class McdNote {
  int _id;
  String _taskSyskey;
  String _mcdCheck;

  McdNote(
      this._taskSyskey,
      this._mcdCheck);

  McdNote.withId(
      this._id,
      this._taskSyskey,
      this._mcdCheck);

  int get id => _id;

  String get taskSyskey => _taskSyskey;

  String get mcdCheck => _mcdCheck;

  set taskSyskey(String newtaskSyskey) {
    this._taskSyskey = newtaskSyskey;
  }

  set mcdCheck(String newcheck) {
    this._mcdCheck = newcheck;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }

    map['taskSyskey'] = _taskSyskey;
    map['mcdCheck'] = _mcdCheck;

    return map;
  }

  McdNote.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._taskSyskey = map['taskSyskey'];
    this._mcdCheck = map['mcdCheck'];
  }
}
