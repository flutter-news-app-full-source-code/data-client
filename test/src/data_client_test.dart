import 'package:data_client/data_client.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class FakeDataClient extends Fake implements DataClient<Object> {}

void main() {
  test('Data client can be implemented', () {
    expect(FakeDataClient.new, returnsNormally);
  });
}
