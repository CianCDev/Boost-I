import 'dart:convert';
import 'dart:io';

void main() {
  void check(String f) {
    try {
      final json = jsonDecode(File('assets/animations/$f').readAsStringSync());
      print('$f: OK - v=${json['v']} ${json['w']}x${json['h']} fr=${json['fr']} frames=${json['op']-json['ip']} layers=${json['layers'].length} nm="${json['nm']}"');
      for (int i=0; i<json['layers'].length; i++) {
        final l = json['layers'][i];
        if (l['ty'] == null || l['nm'] == null || l['shapes'] == null) {
          print('  Layer $i (${l['nm']}): MISSING ty/nm/shapes');
        }
      }
    } catch (e) {
      print('$f: ERROR - $e');
    }
  }
  check('success.json');
  check('error.json');
  check('clock.json');
  check('Clock Alarm Animation.json');
}