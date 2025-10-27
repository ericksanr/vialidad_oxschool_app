import 'package:flutter/material.dart';
import '../Controller/device_controller.dart';

/// Example widget showing how to use the DeviceController
class DeviceInfoExample extends StatefulWidget {
  const DeviceInfoExample({super.key});

  @override
  State<DeviceInfoExample> createState() => _DeviceInfoExampleState();
}

class _DeviceInfoExampleState extends State<DeviceInfoExample> {
  Map<String, dynamic>? deviceInfo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    setState(() {
      isLoading = true;
    });

    try {
      final info = await DeviceController.getDeviceDetail();
      setState(() {
        deviceInfo = info;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading device info: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceInfo,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : deviceInfo == null
          ? const Center(child: Text('No device information available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('Platform Information', [
                    'Platform: ${deviceInfo!['platform']}',
                    'Name: ${deviceInfo!['name']}',
                    'Version: ${deviceInfo!['version']}',
                    'Identifier: ${deviceInfo!['identifier']}',
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'All Device Information',
                    deviceInfo!.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
