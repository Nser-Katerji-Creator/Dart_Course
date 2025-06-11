import 'package:mocktail/mocktail.dart';
import 'package:parking_app/repositories/firebase_person_repository.dart';
import 'package:parking_app/services/firebase_auth_repository.dart';

class MockFirebasePersonRepository extends Mock implements FirebasePersonRepository {}
class MockFirebaseAuthRepository extends Mock implements FirebaseAuthRepository {}
