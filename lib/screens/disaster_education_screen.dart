import 'package:flutter/material.dart';
import '../models/disaster_info.dart';
import '../theme/app_theme.dart';

class DisasterEducationScreen extends StatefulWidget {
  const DisasterEducationScreen({super.key});

  @override
  State<DisasterEducationScreen> createState() => _DisasterEducationScreenState();
}

class _DisasterEducationScreenState extends State<DisasterEducationScreen> {
  final List<DisasterInfo> _disasterInfoList = [
    DisasterInfo(
      type: 'Flood',
      description: 'Floods can occur anywhere in the world and cause extensive damage to life and property.',
      safetyTips: [
        'Stay informed about flood warnings',
        'Keep emergency supplies ready',
        'Know your evacuation route',
        'Keep important documents in a waterproof container',
      ],
      beforeDisaster: [
        'Move to higher ground',
        'Fill clean water containers',
        'Charge all communication devices',
        'Pack emergency kit with essentials',
      ],
      duringDisaster: [
        'Avoid walking through flood water',
        'Do not drive through flooded areas',
        'Stay away from power lines',
        'Listen to official instructions',
      ],
      afterDisaster: [
        'Wait for official clearance to return home',
        'Document damage for insurance',
        'Clean and disinfect everything that got wet',
        'Watch for news updates',
      ],
      emergencyContacts: {
        'National Disaster Response Force': '011-24363260',
        'State Emergency Operation Center': '1070',
        'District Emergency Operation Center': '1077',
        'Police': '100',
        'Ambulance': '108',
      },
    ),
    DisasterInfo(
      type: 'Earthquake',
      description: 'Earthquakes are sudden and violent shaking of the ground, caused by movement of tectonic plates.',
      safetyTips: [
        'Identify safe spots in each room',
        'Secure heavy furniture to walls',
        'Keep emergency supplies accessible',
        'Learn the Drop, Cover, and Hold On technique',
      ],
      beforeDisaster: [
        'Create a family emergency plan',
        'Secure heavy items',
        'Know how to turn off utilities',
        'Keep emergency contacts handy',
      ],
      duringDisaster: [
        'Drop to the ground',
        'Take cover under sturdy furniture',
        'Hold on until shaking stops',
        'Stay away from windows',
      ],
      afterDisaster: [
        'Check for injuries',
        'Listen for emergency information',
        'Stay out of damaged buildings',
        'Be prepared for aftershocks',
      ],
      emergencyContacts: {
        'National Disaster Response Force': '011-24363260',
        'Earthquake Warning Center': '011-24619943',
        'State Emergency Operation Center': '1070',
        'Fire Service': '101',
        'Ambulance': '108',
      },
    ),
    DisasterInfo(
      type: 'Tsunami',
      description: 'Tsunamis are series of giant waves caused by earthquakes or volcanic eruptions under the sea, capable of causing devastating coastal damage.',
      safetyTips: [
        'Learn natural tsunami warning signs',
        'Know your evacuation route to higher ground',
        'Keep emergency kit ready',
        'Stay informed about tsunami warnings',
      ],
      beforeDisaster: [
        'Plan evacuation route to higher ground',
        'Store emergency supplies',
        'Create a family communication plan',
        'Keep important documents in waterproof container',
      ],
      duringDisaster: [
        'Move immediately to higher ground',
        'Stay away from the beach',
        'Follow evacuation orders immediately',
        'Stay out of buildings if water is around',
      ],
      afterDisaster: [
        'Stay away until officials give all-clear',
        'Avoid disaster areas',
        'Stay away from debris in water',
        'Check yourself for injuries',
      ],
      emergencyContacts: {
        'National Disaster Response Force': '011-24363260',
        'Indian National Centre for Ocean Information Services': '040-23895011',
        'Coast Guard': '1554',
        'State Emergency Operation Center': '1070',
        'Ambulance': '108',
      },
    ),
    DisasterInfo(
      type: 'Landslide',
      description: 'Landslides are movements of rock, earth, or debris down a sloped section of land, commonly triggered by rainfall, earthquakes, or human activity.',
      safetyTips: [
        'Recognize warning signs like cracks in ground',
        'Monitor local rainfall and alerts',
        'Know evacuation routes',
        'Have emergency supplies ready',
      ],
      beforeDisaster: [
        'Watch for signs of land movement',
        'Create family emergency plan',
        'Pack emergency supplies',
        'Keep important documents safe',
      ],
      duringDisaster: [
        'Evacuate immediately if advised',
        'Listen for unusual sounds',
        'Move away from slide path',
        'Help neighbors who need assistance',
      ],
      afterDisaster: [
        'Stay away from slide area',
        'Check for injured people',
        'Report broken utilities',
        'Watch for additional sliding',
      ],
      emergencyContacts: {
        'National Disaster Response Force': '011-24363260',
        'Geological Survey of India': '033-22861676',
        'State Emergency Operation Center': '1070',
        'District Emergency Operation Center': '1077',
        'Ambulance': '108',
      },
    ),
    DisasterInfo(
      type: 'Cyclone',
      description: 'Cyclones are powerful tropical storms with strong winds and heavy rainfall that can cause extensive damage through high winds, flooding, and storm surge.',
      safetyTips: [
        'Stay updated with weather forecasts',
        'Know your evacuation zone',
        'Keep emergency supplies ready',
        'Secure important documents',
      ],
      beforeDisaster: [
        'Stock up on essential supplies',
        'Secure loose outdoor items',
        'Board up windows',
        'Fill vehicles with fuel',
      ],
      duringDisaster: [
        'Stay indoors away from windows',
        'Keep monitoring official updates',
        'Stay in the safest room',
        'Turn off main power if flooding occurs',
      ],
      afterDisaster: [
        'Wait for official all-clear',
        'Watch for downed power lines',
        'Document damage with photos',
        'Be careful of contaminated water',
      ],
      emergencyContacts: {
        'National Disaster Response Force': '011-24363260',
        'Indian Meteorological Department': '011-24631913',
        'State Emergency Operation Center': '1070',
        'Coast Guard': '1554',
        'Ambulance': '108',
      },
    ),
  ];

  int _selectedDisasterIndex = 0;

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      color: AppTheme.surfaceGrey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts(Map<String, String> contacts) {
    return Card(
      color: AppTheme.surfaceGrey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                color: AppTheme.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...contacts.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: AppTheme.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDisaster = _disasterInfoList[_selectedDisasterIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Disaster Education'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disaster Type Selection
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<int>(
                  value: _selectedDisasterIndex,
                  isExpanded: true,
                  dropdownColor: AppTheme.surfaceGrey,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  underline: const SizedBox(),
                  items: _disasterInfoList.asMap().entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value.type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDisasterIndex = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                selectedDisaster.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Safety Tips
              _buildInfoCard('Safety Tips', selectedDisaster.safetyTips),
              const SizedBox(height: 16),

              // Before Disaster
              _buildInfoCard('Before ${selectedDisaster.type}', selectedDisaster.beforeDisaster),
              const SizedBox(height: 16),

              // During Disaster
              _buildInfoCard('During ${selectedDisaster.type}', selectedDisaster.duringDisaster),
              const SizedBox(height: 16),

              // After Disaster
              _buildInfoCard('After ${selectedDisaster.type}', selectedDisaster.afterDisaster),
              const SizedBox(height: 16),

              // Emergency Contacts
              _buildEmergencyContacts(selectedDisaster.emergencyContacts),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 