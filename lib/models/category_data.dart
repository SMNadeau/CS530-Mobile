
/// Data Class Category for category data returned from web app
class Category {
  String id;
  String name;

  Category(this.id, this.name);

  Category.fromJson(Map json)
      : id = json['_id'],
        name = json['name'];

  Map toJson() {
    return {'_id': id, 'name': name};
  }

  Object? toList() {}
  
}
