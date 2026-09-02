import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/domain/ownership.dart';

void main() {
  test('shared ownership is explicit', () {
    final artifact = OwnedArtifact<String>.shared('共同批注');
    expect(artifact.owner, ArtifactOwner.shared);
    expect(artifact.value, '共同批注');
  });
}
