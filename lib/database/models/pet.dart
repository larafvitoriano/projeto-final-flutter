class Pet {
  int? id;
  String name;
  String species;
  String breed;
  String sex;
  int age;
  double? weight;
  String? allergy;
  String? observations;

  Pet({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.age,
    this.weight,
    this.allergy,
    this.observations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'sex': sex,
      'age': age,
      'weight': weight,
      'allergy': allergy,
      'observations': observations,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      sex: map['sex'],
      age: map['age'],
      weight: map['weight'],
      allergy: map['allergy'],
      observations: map['observations'],
    );
  }
}