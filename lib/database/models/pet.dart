class Pet {
  int? id;
  String pictureFile;
  String name;
  String species;
  String breed;
  String sex;
  String birthDate;
  int? age;
  double? weight;
  String? allergy;
  String? notes;

  Pet({
    this.id,
    required this.pictureFile,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.birthDate,
    this.age,
    this.weight,
    this.allergy,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pictureFile': pictureFile,
      'name': name,
      'species': species,
      'breed': breed,
      'sex': sex,
      'birthDate': birthDate,
      'age': age,
      'weight': weight,
      'allergy': allergy,
      'notes': notes,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      pictureFile: map['pictureFile'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      sex: map['sex'],
      birthDate: map['birthDate'],
      age: map['age'],
      weight: map['weight'],
      allergy: map['allergy'],
      notes: map['notes'],
    );
  }
}