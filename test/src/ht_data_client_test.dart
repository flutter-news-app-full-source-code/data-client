import 'package:ht_data_client/ht_data_client.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class FakeHtDataClient extends Fake implements HtDataClient<Object> {}

void main() {
  test('Data client can be implemented', () {
    expect(FakeHtDataClient.new, returnsNormally);
  });
}
