// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'ExpertSystem.dart';

class TunasAgentWidget extends StatefulWidget {
  const TunasAgentWidget({
    super.key,
    required this.saran,
    required this.jenisTanaman,
    required this.cuaca,
    required this.onPlantChanged,
  });

  final String saran;
  final String jenisTanaman;
  final WeatherInsight cuaca;
  final ValueChanged<String> onPlantChanged;

  @override
  State<TunasAgentWidget> createState() => _TunasAgentWidgetState();
}

class _TunasAgentWidgetState extends State<TunasAgentWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showPlantDialog() async {
    var selectedPlant = widget.jenisTanaman;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final profile = ExpertSystem.getProfile(selectedPlant);
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.eco_rounded, color: Color(0xFF0F766E)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Kenalkan tanamanmu')),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tunas akan menyesuaikan analisis sensor dengan kebutuhan tanaman.',
                        style: TextStyle(color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPlant,
                        decoration: const InputDecoration(
                          labelText: 'Jenis tanaman',
                          prefixIcon: Icon(Icons.local_florist_rounded),
                          border: OutlineInputBorder(),
                        ),
                        items: ExpertSystem.supportedPlants
                            .map(
                              (plant) => DropdownMenuItem(
                                value: plant,
                                child: Text(plant),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedPlant = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Target $selectedPlant\n'
                          'Suhu: ${profile.minTemperature.toInt()}-${profile.maxTemperature.toInt()} C\n'
                          'Kelembapan tanah: ${profile.minSoilMoisture.toInt()}-${profile.maxSoilMoisture.toInt()}%\n'
                          'Musim cocok: ${profile.suitableSeasons.join(', ')}',
                          style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, selectedPlant),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Analisis'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      widget.onPlantChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                ),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: Color(0xFFCCFBF1),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tunas AI Agent',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.jenisTanaman} | ${widget.cuaca.condition}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Atur jenis tanaman',
                onPressed: _showPlantDialog,
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: SelectableText(
              widget.saran,
              style: const TextStyle(
                color: Color(0xFF134E4A),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _showPlantDialog,
              icon: const Icon(Icons.local_florist_rounded),
              label: const Text('Pilih Tanaman'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
