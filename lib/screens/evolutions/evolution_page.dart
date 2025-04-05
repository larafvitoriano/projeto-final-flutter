import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/models/evolution.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/repositories/evolution_repository.dart';
import '../../database/models/pet.dart';
import 'evolution_form.dart';
import 'package:intl/intl.dart';

class EvolutionPage extends StatefulWidget {
  final Pet pet;

  const EvolutionPage({required this.pet, Key? key}) : super(key: key);

  @override
  _EvolutionPageState createState() => _EvolutionPageState();
}

class _EvolutionPageState extends State<EvolutionPage> {
  late EvolutionRepository _evolutionRepository;
  late Future<List<Evolution>> _futureEvolutions;

  @override
  void initState() {
    super.initState();
    _evolutionRepository = EvolutionRepository(DatabaseHelper());
    _futureEvolutions = _evolutionRepository.getEvolutionsByPetId(widget.pet.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evolução de ${widget.pet.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[300],
        elevation: 2,
      ),
      body: FutureBuilder<List<Evolution>>(
        future: _futureEvolutions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar evoluções.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum registro de evolução.'));
          } else {
            final evolutions = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildChartCard(evolutions),
                    const SizedBox(height: 16),
                    _buildEvolutionListCard(evolutions),
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EvolutionForm(pet: widget.pet),
            ),
          );
          setState(() {
            _futureEvolutions = _evolutionRepository.getEvolutionsByPetId(widget.pet.id!);
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildChartCard(List<Evolution> evolutions) {
    evolutions.sort((a, b) => a.date.compareTo(b.date));
    final spots = evolutions.asMap().entries.map((entry) {
      final index = entry.key;
      final evo = entry.value;
      return FlSpot(index.toDouble(), evo.weight);
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvolutionListCard(List<Evolution> evolutions) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: evolutions.length,
          itemBuilder: (context, index) {
            final evo = evolutions[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peso: ${evo.weight} kg',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Data: ${evo.date}'),
                    if (evo.notes != null) Text('Observações: ${evo.notes}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EvolutionForm(pet: widget.pet, evolution: evo),
                              ),
                            );
                            setState(() {
                              _futureEvolutions = _evolutionRepository.getEvolutionsByPetId(widget.pet.id!);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _evolutionRepository.deleteEvolution(evo.id!, widget.pet.id!);
                            setState(() {
                              _futureEvolutions = _evolutionRepository.getEvolutionsByPetId(widget.pet.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registro excluído com sucesso!')),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(),
        ),
      ),
    );
  }
}