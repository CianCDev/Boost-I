import 'dart:convert';
import 'dart:io';

void main() {
  void test(String f) {
    final json = jsonDecode(File('assets/animations/$f').readAsStringSync());
    for (var layer in json['layers']) {
      for (var shape in layer['shapes'] ?? []) {
        if (shape['ks'] != null) {
          var ks = shape['ks'];
          if (ks is Map && ks['a'] == 1) {
            var k = ks['k'];
            if (k is List) {
              for (var keyframe in k) {
                if (keyframe['s'] is Map && keyframe['s']['v'] is List) {
                  var v = keyframe['s']['v'];
                  if (v.isNotEmpty && v[0] is List && v[0].length == 2) {
                    if (keyframe['s']['i'] == null || keyframe['s']['o'] == null) {
                      print('$f: Layer ${layer['nm']} shape missing i/o in path keyframe');
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  test('success.json');
  test('error.json');
  test('clock.json');
  test('Clock Alarm Animation.json');
  print('Done');
}