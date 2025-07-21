import 'package:flutter/material.dart';

// -------------------- Field Planner Screen --------------------
class FieldPlannerScreen extends StatefulWidget {
  const FieldPlannerScreen({super.key});

  @override
  State<FieldPlannerScreen> createState() => _FieldPlannerScreenState();
}

class _FieldPlannerScreenState extends State<FieldPlannerScreen> {
  final List<FieldCard> _fields = [
    const FieldCard(
      fieldName: 'North 40',
      dateCut: 'July 12',
      drynessTarget: 15,
      status: '🌤 Drying',
    ),
    const FieldCard(
      fieldName: 'East Ridge',
      dateCut: 'July 15',
      drynessTarget: 13,
      status: '✅ Ready',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Planner'),
        backgroundColor: Colors.green[700],
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _fields.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _fields[index],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCard = await showModalBottomSheet<FieldCard>(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: const FieldForm(),
            ),
          );

          if (newCard != null) {
            setState(() => _fields.add(newCard));
          }
        },
        backgroundColor: Colors.green[600],
        tooltip: 'Add Field',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// -------------------- Field Card Widget --------------------
class FieldCard extends StatelessWidget {
  final String fieldName;
  final String dateCut;
  final int drynessTarget;
  final String status;

  const FieldCard({
    super.key,
    required this.fieldName,
    required this.dateCut,
    required this.drynessTarget,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown[50],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$status $fieldName',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('📅 Cut on: $dateCut'),
            Text('🌡️ Dryness Target: $drynessTarget%'),
          ],
        ),
      ),
    );
  }
}

// -------------------- Field Form Widget --------------------
class FieldForm extends StatefulWidget {
  const FieldForm({super.key});

  @override
  State<FieldForm> createState() => _FieldFormState();
}

class _FieldFormState extends State<FieldForm> {
  final _fieldNameController = TextEditingController();
  final _dateCutController = TextEditingController();
  final _drynessTargetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Add New Field',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: _fieldNameController,
          decoration: const InputDecoration(labelText: 'Field Name'),
        ),
        TextField(
          controller: _dateCutController,
          decoration: const InputDecoration(labelText: 'Date Cut'),
        ),
        TextField(
          controller: _drynessTargetController,
          decoration: const InputDecoration(labelText: 'Dryness Target (%)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final name = _fieldNameController.text.trim();
            final date = _dateCutController.text.trim();
            final dryness = int.tryParse(_drynessTargetController.text.trim());

            if (name.isEmpty ||
                date.isEmpty ||
                dryness == null ||
                dryness <= 0 ||
                dryness > 100) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter valid field data')),
              );
              return;
            }

            Navigator.pop(
              context,
              FieldCard(
                fieldName: name,
                dateCut: date,
                drynessTarget: dryness,
                status: '🌤 Drying',
              ),
            );
          },
          child: const Text('Save'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
