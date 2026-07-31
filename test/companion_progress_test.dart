import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/data/companion_progress.dart';

void main() {
  test('level starts at 1 and rises every expPerLevel', () {
    expect(levelForExp(0), 1);
    expect(levelForExp(99), 1);
    expect(levelForExp(100), 2);
    expect(levelForExp(250), 3);
  });

  test('expIntoLevel wraps at each level boundary', () {
    expect(expIntoLevel(0), 0);
    expect(expIntoLevel(99), 99);
    expect(expIntoLevel(100), 0);
    expect(expIntoLevel(150), 50);
  });
}
