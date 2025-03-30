class Pet {
  int? id;
  String name;
  String species;
  String breed;
  int age;

  Pet({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      age: map['age'],
    );
  }
}