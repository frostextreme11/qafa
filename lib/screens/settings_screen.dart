import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/fasting_provider.dart';
import '../widgets/glass_card.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('APPEARANCE'),
              const SizedBox(height: 12),
              _buildAppearanceSettings(themeProvider, isDark),
              
              const SizedBox(height: 32),
              _buildSectionHeader('NOTIFICATIONS'),
              const SizedBox(height: 12),
              _buildNotificationSettings(settingsProvider, isDark),
              
              const SizedBox(height: 32),
              _buildSectionHeader('PERSONALIZATION'),
              const SizedBox(height: 12),
              _buildTargetSettings(context, isDark),
              
              const SizedBox(height: 32),
              _buildSectionHeader('ABOUT'),
              const SizedBox(height: 12),
              _buildAboutCard(isDark),
              
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'QADA TRACKER V1.0.0',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Theme.of(context).primaryColor.withOpacity(0.6),
      ),
    );
  }

  Widget _buildAppearanceSettings(ThemeProvider provider, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      isAsymmetric: false,
      borderRadius: 20,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.brightness_4_rounded,
            title: 'Dark Mode',
            subtitle: 'Recommended for Celestial atmosphere',
            trailing: Switch(
              value: provider.themeMode == ThemeMode.dark,
              onChanged: (val) => provider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
              activeColor: Theme.of(context).primaryColor,
            ),
            isDark: isDark,
          ),
          Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.palette_rounded,
            title: 'Signature Theme',
            subtitle: 'Celestial Prism (Emerald & Gold)',
            trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF3CE36A), size: 20),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(SettingsProvider provider, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      isAsymmetric: false,
      borderRadius: 20,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.mosque_rounded,
            title: 'Prayer Alerts',
            subtitle: 'Enable all Sholat notifications',
            trailing: Switch(
              value: provider.prayerNotificationsEnabled,
              onChanged: (val) async {
                if (val) await NotificationService().requestPermissions();
                provider.setPrayerNotificationsEnabled(val);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            isDark: isDark,
          ),
          if (provider.prayerNotificationsEnabled) ...[
            _buildSubTile('15 Min Before', provider.prayerReminder15, provider.setPrayerReminder15, isDark),
            _buildSubTile('5 Min Before', provider.prayerReminder5, provider.setPrayerReminder5, isDark),
            _buildSubTile('On Time', provider.prayerNow, provider.setPrayerNow, isDark),
          ],
          Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.opacity_rounded,
            title: 'Hydration Alerts',
            subtitle: 'Remind me to drink water',
            trailing: Switch(
              value: provider.waterNotificationsEnabled,
              onChanged: (val) async {
                if (val) await NotificationService().requestPermissions();
                provider.setWaterNotificationsEnabled(val);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            isDark: isDark,
          ),
          Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.music_note_rounded,
            title: 'Custom Sound',
            subtitle: provider.notificationSound.toUpperCase(),
            onTap: () => _showSoundPicker(provider, isDark),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSubTile(String label, bool value, Function(bool) onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: ListTile(
        title: Text(label, style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
        trailing: Checkbox(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  void _showSoundPicker(SettingsProvider provider, bool isDark) {
    final sounds = ['default', 'azan_soft', 'water_drop', 'zen_bell'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('CHOOSE SOUND', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 20),
            ...sounds.map((s) => ListTile(
              title: Text(s.toUpperCase(), style: GoogleFonts.inter(fontSize: 14)),
              trailing: provider.notificationSound == s ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor) : null,
              onTap: () {
                provider.setNotificationSound(s);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSettings(BuildContext context, bool isDark) {
    final fastingProvider = Provider.of<FastingProvider>(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      isAsymmetric: false,
      borderRadius: 20,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.track_changes_rounded,
            title: 'Qada Goal',
            subtitle: '${fastingProvider.qadaTarget ?? 0} days remaining',
            onTap: () => _updateQadaTarget(context, fastingProvider),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      isAsymmetric: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qada Tracker is your digital sanctuary, designed to bring serenity to your spiritual journey.',
            style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: isDark ? Colors.white.withOpacity(0.7) : Colors.black87),
          ),
          const SizedBox(height: 20),
          _buildAboutRow(Icons.security_rounded, 'Privacy focused & local-first', isDark),
          const SizedBox(height: 12),
          _buildAboutRow(Icons.auto_awesome_rounded, 'Powered by Celestial Prism Design', isDark),
        ],
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white.withOpacity(0.54) : Colors.black54)),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (isDark ? Colors.white : Colors.black).withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: (isDark ? Colors.white : Colors.black).withOpacity(0.7)),
      ),
      title: Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: (isDark ? Colors.white : Colors.black).withOpacity(0.38))),
      trailing: trailing,
    );
  }

  void _updateQadaTarget(BuildContext context, FastingProvider provider) {
    final controller = TextEditingController(text: provider.qadaTarget?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text('SET QADA GOAL', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: 'Total days to qada',
            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4)))),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(controller.text);
              if (target != null) provider.setQadaTarget(target);
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}