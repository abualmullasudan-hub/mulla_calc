import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController pinCtrl;
  late bool pinEnabled;

  @override
  void initState() {
    super.initState();
    final s = Provider.of<AppState>(context, listen: false).settings;
    nameCtrl = TextEditingController(text: s.shopName);
    phoneCtrl = TextEditingController(text: s.phone);
    addressCtrl = TextEditingController(text: s.address);
    pinCtrl = TextEditingController(text: s.pin);
    pinEnabled = s.pinEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _box('بيانات المحل', [
                _field('اسم المحل', nameCtrl),
                _field('الهاتف', phoneCtrl, keyboard: TextInputType.phone),
                _field('العنوان', addressCtrl),
              ]),
              const SizedBox(height: 10),
              _box('الحماية', [
                SwitchListTile(
                  title: const Text('تفعيل قفل التطبيق برقم سري',
                    style: TextStyle(color: Color(0xFF0B4D2C), fontWeight: FontWeight.bold)),
                  value: pinEnabled,
                  activeColor: const Color(0xFF0B4D2C),
                  onChanged: (v) => setState(() => pinEnabled = v),
                ),
                _field('الرقم السري (4 أرقام)', pinCtrl, keyboard: TextInputType.number),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A059),
                    foregroundColor: const Color(0xFF0B4D2C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final s = AppSettings(
                      shopName: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      pin: pinCtrl.text.trim().length == 4 ? pinCtrl.text.trim() : '0000',
                      pinEnabled: pinEnabled,
                    );
                    app.updateSettings(s);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ الإعدادات ✅')));
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ الإعدادات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF052616),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                ),
                child: const Column(
                  children: [
                    Text('Mulla Exchange', style: TextStyle(color: Color(0xFFC5A059), fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('نظام إدارة الصرافة', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    SizedBox(height: 6),
                    Text('Abu Almulla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('0922008009', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C), fontSize: 15)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF4EBD0),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
