import 'package:ht_crud_client/ht_crud_client.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class FakeHtCrudClient extends Fake implements HtCrudClient<Object> {}

void main() {
  test('NotificationsClient can be implemented', () {
    expect(FakeHtCrudClient.new, returnsNormally);
  });
}
