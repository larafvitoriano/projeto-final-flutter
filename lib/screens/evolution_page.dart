import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/models/evolution.dart';
import '../database/helpers/database_helper.dart';
import '../database/repositories/evolution_repository.dart';
import '../database/models/pet.dart';
import 'evolution_form.dart';

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
        title: Text('Evolução do ${widget.pet.name}'),
        backgroundColor: Colors.blue[300],
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
              child: Column(
                children: [
                  _buildChart(evolutions),
                  const SizedBox(height: 16),
                  _buildEvolutionList(evolutions),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Abre o formulário para adicionar evolução
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChart(List<Evolution> evolutions) {
    // Ordena por data
    evolutions.sort((a, b) => a.date.compareTo(b.date));
    // Mapeia para pontos no gráfico
    final spots = evolutions.asMap().entries.map((entry) {
      final index = entry.key;
      final evo = entry.value;
      return FlSpot(index.toDouble(), evo.weight);
    }).toList();

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
    );
  }

  Widget _buildEvolutionList(List<Evolution> evolutions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: evolutions.length,
      itemBuilder: (context, index) {
        final evo = evolutions[index];
        return ListTile(
          title: Text(
            'Peso: ${evo.weight} kg',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Data: ${evo.date.day}/${evo.date.month}/${evo.date.year}'
                '${evo.notes != null ? "\nObservações: ${evo.notes}" : ""}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await _evolutionRepository.deleteEvolution(evo.id!, widget.pet.id!);
              setState(() {
                _futureEvolutions = _evolutionRepository.getEvolutionsByPetId(widget.pet.id!);
              });
            },
          ),
        );
      },
    );
  }
}
