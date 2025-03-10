import 'package:flutter/material.dart';
import '../services/database_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final String userId;

  const EmergencyContactsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _contact1NameController = TextEditingController();
  final _contact1PhoneController = TextEditingController();
  final _contact2NameController = TextEditingController();
  final _contact2PhoneController = TextEditingController();
  final _db = DatabaseService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _db.getEmergencyContacts(widget.userId);
    setState(() {
      if (contacts.isNotEmpty) {
        _contact1NameController.text = contacts[0]['name'] ?? '';
        _contact1PhoneController.text = contacts[0]['phone'] ?? '';
      }
      if (contacts.length > 1) {
        _contact2NameController.text = contacts[1]['name'] ?? '';
        _contact2PhoneController.text = contacts[1]['phone'] ?? '';
      }
      _isLoading = false;
    });
  }

  Future<void> _saveContacts() async {
    final success = await _db.updateEmergencyContact(
      widget.userId,
      contact1Name: _contact1NameController.text,
      contact1Phone: _contact1PhoneController.text,
      contact2Name: _contact2NameController.text,
      contact2Phone: _contact2PhoneController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('紧急联系人已更新')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新失败，请重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('紧急联系人'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveContacts,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '主要联系人',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contact1NameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contact1PhoneController,
              decoration: const InputDecoration(
                labelText: '电话',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            const Text(
              '备用联系人',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contact2NameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contact2PhoneController,
              decoration: const InputDecoration(
                labelText: '电话',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contact1NameController.dispose();
    _contact1PhoneController.dispose();
    _contact2NameController.dispose();
    _contact2PhoneController.dispose();
    super.dispose();
  }
} 