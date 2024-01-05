class MerchandizerNote {
  int _id;
  String _userSyskey;
  String _imgPath;
  String _pathForServer;
  String _taskKey;
  String _shopSyskey;
  String _campaignId;
  String _brandOwnerId;
  String _remark;
  String _taskToDo;
  String _completeCheck;
  String _shopComplete;

  MerchandizerNote(
      this._userSyskey,
      this._imgPath,
      this._pathForServer,
      this._taskKey,
      this._shopSyskey,
      this._campaignId,
      this._brandOwnerId,
      this._remark,
      this._taskToDo,
      this._completeCheck,
      this._shopComplete);

  MerchandizerNote.withId(
      this._id,
      this._userSyskey,
      this._imgPath,
      this._pathForServer,
      this._taskKey,
      this._shopSyskey,
      this._campaignId,
      this._brandOwnerId,
      this._remark,
      this._taskToDo,
      this._completeCheck,
      this._shopComplete);

  int get id => _id;

  String get userSyskey => _userSyskey;

  String get imgPath => _imgPath;

  String get pathForServer => _pathForServer;

  String get taskKey => _taskKey;

  String get shopSyskey => _shopSyskey;

  String get campaignId => _campaignId;

  String get brandOwnerId => _brandOwnerId;

  String get remark => _remark;

  String get taskToDo => _taskToDo;

  String get completeCheck => _completeCheck;

  String get shopComplete => _shopComplete;

  set imgPath(String newimgPath) {
    this._imgPath = newimgPath;
  }

  set pathForServer(String newPath) {
    this.pathForServer = newPath;
  }

  set taskKey(String newtaskKey) {
    this._taskKey = newtaskKey;
  }

  set shopSyskey(String newshopSyskey) {
    this._shopSyskey = newshopSyskey;
  }

  set campaignId(String newcampaignId) {
    this._campaignId = newcampaignId;
  }

  set brandOwnerId(String newbrandOwnerId) {
    this._brandOwnerId = newbrandOwnerId;
  }

  set remark(String newRemark) {
    this._remark = newRemark;
  }

  set taskToDo(String newtaskToDo) {
    this._taskToDo = newtaskToDo;
  }

  set completeCheck(String newcompleteCheck) {
    this._completeCheck = newcompleteCheck;
  }

  set shopComplete(String newshopComplete) {
    this._shopComplete = newshopComplete;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }

    map['userSyskey'] = _userSyskey;
    map['imgPath'] = _imgPath;
    map['pathForServer'] = _pathForServer;
    map['taskKey'] = _taskKey;
    map['shopSyskey'] = _shopSyskey;
    map['campaignId'] = _campaignId;
    map['brandOwnerId'] = _brandOwnerId;
    map['remark'] = _remark;
    map['taskToDo'] = _taskToDo;
    map['completeCheck'] = _completeCheck;
    map['shopComplete'] = _shopComplete;

    return map;
  }

  MerchandizerNote.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._userSyskey = map['userSyskey'];
    this._imgPath = map['imgPath'];
    this._pathForServer = map['pathForServer'];
    this._taskKey = map['taskKey'];
    this._shopSyskey = map['shopSyskey'];
    this._campaignId = map['campaignId'];
    this._brandOwnerId = map['brandOwnerId'];
    this._remark = map['remark'];
    this._taskToDo = map['taskToDo'];
    this._completeCheck = map['completeCheck'];
    this._shopComplete = map['shopComplete'];
  }
}
