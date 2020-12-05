import 'package:firebase_database/firebase_database.dart';

class notes {
  String key;
  dynamic content;

  notes(this.content);


  notes.name(this.key, this.content);

  notes.fromSnapshot(DataSnapshot snapshot)
      :key=snapshot.key,
        content=snapshot.value['body'];

  toJson(){
    return {
      "body":content
    };
  }


}