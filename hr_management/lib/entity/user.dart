class user {
  int? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? photo;
  String? role;
  bool? active;
  bool? enabled;
  String? username;
  bool? lock;
  bool? accountNonLocked;
  bool? credentialsNonExpired;
  bool? accountNonExpired;

  user(
      {this.id,
        this.name,
        this.email,
        this.password,
        this.phone,
        this.photo,
        this.role,
        this.active,
        this.enabled,
        this.username,
        this.lock,
        this.accountNonLocked,
        this.credentialsNonExpired,
        this.accountNonExpired});

  user.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    photo = json['photo'];
    role = json['role'];
    active = json['active'];
    enabled = json['enabled'];
    username = json['username'];
    lock = json['lock'];
    accountNonLocked = json['accountNonLocked'];
    credentialsNonExpired = json['credentialsNonExpired'];
    accountNonExpired = json['accountNonExpired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['photo'] = this.photo;
    data['role'] = this.role;
    data['active'] = this.active;
    data['enabled'] = this.enabled;
    data['username'] = this.username;
    data['lock'] = this.lock;
    data['accountNonLocked'] = this.accountNonLocked;
    data['credentialsNonExpired'] = this.credentialsNonExpired;
    data['accountNonExpired'] = this.accountNonExpired;
    return data;
  }
}




//
//
// {
// "id": 1,
// "name": "Rejaul Karim",
// "email": "cmrejaulkarim@gmail.com",
// "password": "$2a$10$4x2EBkWuQwgz9McUCgYtZe5ayS9ywQKI4uLKQQUOB7G6ZxqN32FQ.",
// "phone": "768196876",
// "photo": "Rejaul_Karim_6bce4ce5-780e-41db-a6de-ad11e6fe27e4",
// "role": "ADMIN",
// "active": true,
// "enabled": true,
// "username": "cmrejaulkarim@gmail.com",
// "lock": false,
// "accountNonLocked": false,
// "credentialsNonExpired": true,
// "accountNonExpired": true
// }