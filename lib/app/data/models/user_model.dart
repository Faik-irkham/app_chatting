class UserModel {
  String? uid;
  String? nama;
  String? email;
  String? creationTime;
  String? lastSignInTime;
  String? photoUrl;
  String? status;
  String? updateTime;

  UserModel(
      {this.uid,
      this.nama,
      this.email,
      this.creationTime,
      this.lastSignInTime,
      this.photoUrl,
      this.status,
      this.updateTime});

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    nama = json['nama'];
    email = json['email'];
    creationTime = json['creationTime'];
    lastSignInTime = json['lastSignInTime'];
    photoUrl = json['photoUrl'];
    status = json['status'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['nama'] = nama;
    data['email'] = email;
    data['creationTime'] = creationTime;
    data['lasSignInTime'] = lastSignInTime;
    data['photoUrl'] = photoUrl;
    data['status'] = status;
    data['updateTime'] = updateTime;
    return data;
  }
}
