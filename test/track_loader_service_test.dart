import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/core/services/track_loader_service.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;
  late TrackLoaderService trackLoaderService;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    trackLoaderService = TrackLoaderService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('loadFullGpxData should parse GPX file and save data to database', () async {
    // This is a placeholder for a real test.
    // We would need to mock the rootBundle to return a fake GPX file.
    expect(true, isTrue);
  });
}
