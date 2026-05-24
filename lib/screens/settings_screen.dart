import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
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
  
  // Staggered Animations
  late Animation<double> _appearanceAnim;
  late Animation<double> _notificationsAnim;
  late Animation<double> _personalizationAnim;
  late Animation<double> _aboutAnim;

  // Shorebird Updater State
  final _shorebirdUpdater = ShorebirdUpdater();
  bool _isShorebirdAvailable = false;
  int? _currentPatchNumber;
  bool _isCheckingForUpdate = false;
  String _updateStatusMessage = '';
  bool _restartRequired = false;

  void _initShorebird() {
    _isShorebirdAvailable = _shorebirdUpdater.isAvailable;
    if (_isShorebirdAvailable) {
      _shorebirdUpdater.readCurrentPatch().then((patch) {
        if (mounted) {
          setState(() {
            _currentPatchNumber = patch?.number;
          });
        }
      });
    }
  }

  Future<void> _checkForUpdates() async {
    if (!_isShorebirdAvailable) return;
    
    setState(() {
      _isCheckingForUpdate = true;
      _updateStatusMessage = 'Memeriksa pembaruan dari server...';
    });

    try {
      final status = await _shorebirdUpdater.checkForUpdate();
      
      if (!mounted) return;

      if (status == UpdateStatus.outdated) {
        setState(() {
          _updateStatusMessage = 'Pembaruan tersedia! Mengunduh...';
        });

        // Trigger the download of the update
        await _shorebirdUpdater.update();

        if (mounted) {
          setState(() {
            _restartRequired = true;
            _isCheckingForUpdate = false;
            _updateStatusMessage = 'Pembaruan berhasil diunduh!';
          });
        }
      } else if (status == UpdateStatus.restartRequired) {
        setState(() {
          _restartRequired = true;
          _isCheckingForUpdate = false;
          _updateStatusMessage = 'Pembaruan sudah terunduh. Silakan restart!';
        });
      } else {
        setState(() {
          _isCheckingForUpdate = false;
          _updateStatusMessage = 'Aplikasi sudah versi terbaru.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingForUpdate = false;
          _updateStatusMessage = 'Gagal memeriksa pembaruan: $e';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initShorebird();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _appearanceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );
    _notificationsAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)),
    );
    _personalizationAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
    );
    _aboutAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStaggeredItem({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _pickCustomSound(SettingsProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path;
        final fileName = result.files.single.name;
        
        provider.setCustomSound(filePath, fileName);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF042A36),
              content: Text(
                'Suara kustom terpilih: $fileName',
                style: GoogleFonts.manrope(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text(
              'Gagal memilih file suara: ${e.toString()}',
              style: GoogleFonts.manrope(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _showSoundPicker(SettingsProvider provider, bool isDark) {
    final defaultSounds = ['default', 'azan_soft', 'water_drop', 'zen_bell'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF02161D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ATUR NADA ALARM & NOTIFIKASI',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900, 
                    fontSize: 12, 
                    letterSpacing: 1.5,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                
                // OS Limitations Warning Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Catatan OS: File suara kustom eksternal hanya akan berfungsi penuh saat aplikasi aktif di layar (foreground) karena kebijakan keamanan Android/iOS yang membatasi pemutaran file lokal acak di latar belakang.',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            height: 1.45,
                            color: Colors.amber.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sound List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ...defaultSounds.map((soundName) {
                        final isSelected = provider.notificationSound == soundName;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            soundName.toUpperCase(), 
                            style: GoogleFonts.manrope(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20) 
                              : null,
                          onTap: () {
                            provider.setNotificationSound(soundName);
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                        );
                      }),
                      
                      const Divider(color: Colors.white10, height: 24),
                      
                      // Custom Sound Picker
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.audio_file_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          'PILIH FILE DARI HP...',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        subtitle: Text(
                          provider.customSoundName ?? 'Belum ada file kustom terpilih',
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white30),
                        ),
                        trailing: provider.notificationSound == 'custom'
                            ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20)
                            : Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 20),
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickCustomSound(provider);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Appearance Section
            _buildStaggeredItem(
              animation: _appearanceAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('APPEARANCE'),
                  const SizedBox(height: 12),
                  _buildAppearanceSettings(themeProvider, isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // 2. Notifications Section
            _buildStaggeredItem(
              animation: _notificationsAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('NOTIFICATIONS'),
                  const SizedBox(height: 12),
                  _buildNotificationSettings(settingsProvider, isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // 3. Personalization Section
            _buildStaggeredItem(
              animation: _personalizationAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('PERSONALIZATION'),
                  const SizedBox(height: 12),
                  _buildTargetSettings(context, isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // System Updates Section
            _buildStaggeredItem(
              animation: _aboutAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('SYSTEM UPDATES'),
                  const SizedBox(height: 12),
                  _buildShorebirdSettings(isDark),
                ],
              ),
            ),

            const SizedBox(height: 28),
            
            // 4. About Section
            _buildStaggeredItem(
              animation: _aboutAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('ABOUT'),
                  const SizedBox(height: 12),
                  _buildAboutCard(isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                'version  1.0.0+1' + (_currentPatchNumber != null ? ' Patch $_currentPatchNumber' : ''),
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

  Widget _buildShorebirdSettings(bool isDark) {
    final themeColor = Theme.of(context).primaryColor;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      isAsymmetric: false,
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_isShorebirdAvailable ? Colors.green : Colors.orange).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isShorebirdAvailable ? Icons.offline_bolt_rounded : Icons.warning_amber_rounded,
                  color: _isShorebirdAvailable ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isShorebirdAvailable ? 'SHOREBIRD ENGINE AKTIF' : 'STANDARD BUILD (NO OTA)',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.0,
                        color: _isShorebirdAvailable ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isShorebirdAvailable
                          ? 'Mendukung pembaruan instan otomatis di latar belakang.'
                          : 'Update instan tidak didukung pada build standar.',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Pembaruan',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Base: 1.0.0+2' + (_currentPatchNumber != null ? ' (Patch $_currentPatchNumber)' : ' (Belum ada Patch)'),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              if (_isShorebirdAvailable)
                ElevatedButton.icon(
                  onPressed: _isCheckingForUpdate ? null : _checkForUpdates,
                  icon: _isCheckingForUpdate
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh_rounded, size: 14),
                  label: Text(
                    _isCheckingForUpdate ? 'MENGECEK...' : 'CEK UPDATE',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: const Color(0xFF02161D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
            ],
          ),
          if (_updateStatusMessage.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    _restartRequired ? Icons.restart_alt_rounded : Icons.info_outline_rounded,
                    color: themeColor,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _updateStatusMessage,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: themeColor,
                        fontWeight: _restartRequired ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
            trailing: Switch.adaptive(
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
            trailing: Switch.adaptive(
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
            trailing: Switch.adaptive(
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
            subtitle: provider.notificationSound == 'custom' 
                ? (provider.customSoundName ?? 'CUSTOM FILE') 
                : provider.notificationSound.toUpperCase(),
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
            'Qada Fast Tracker is your digital sanctuary, designed to bring serenity to your spiritual journey.',
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
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white.withOpacity(0.54) : Colors.black54))),
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