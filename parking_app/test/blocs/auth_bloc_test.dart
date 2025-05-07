import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart';
import 'package:parking_app/blocs/auth/auth_event.dart';
import 'package:parking_app/blocs/auth/auth_state.dart';
import 'package:parking_app/models/person.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockPersonRepository mockPersonRepository;
  late Person testUser;
  
  setUp(() {
    mockPersonRepository = MockPersonRepository();
    
    testUser = Person(
      id: '1',
      name: 'Test User',
      personalNumber: '123456-7890',
    );
    
    // Setup for SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when LoginRequested is added and successful',
      build: () {
        when(() => mockPersonRepository.getByPersonalNumber('123456-7890'))
            .thenAnswer((_) async => testUser);
        return AuthBloc(personRepository: mockPersonRepository);
      },
      act: (bloc) => bloc.add(const LoginRequested('123456-7890')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((state) => state.user, 'user', testUser),
      ],
      verify: (_) {
        verify(() => mockPersonRepository.getByPersonalNumber('123456-7890')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when LoginRequested is added and user not found',
      build: () {
        when(() => mockPersonRepository.getByPersonalNumber('123456-7890'))
            .thenAnswer((_) async => null);
        return AuthBloc(personRepository: mockPersonRepository);
      },
      act: (bloc) => bloc.add(const LoginRequested('123456-7890')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (state) => state.error,
          'error',
          'User not found',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when LoginRequested is added and fails',
      build: () {
        when(() => mockPersonRepository.getByPersonalNumber('123456-7890'))
            .thenThrow(Exception('Failed to login'));
        return AuthBloc(personRepository: mockPersonRepository);
      },
      act: (bloc) => bloc.add(const LoginRequested('123456-7890')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (state) => state.error,
          'error',
          contains('Failed to login'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when RegisterRequested is added and successful',
      build: () {
        when(() => mockPersonRepository.create(testUser))
            .thenAnswer((_) async {});
        return AuthBloc(personRepository: mockPersonRepository);
      },
      act: (bloc) => bloc.add(RegisterRequested(testUser)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((state) => state.user, 'user', testUser),
      ],
      verify: (_) {
        verify(() => mockPersonRepository.create(testUser)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, LoggedOut] when LogoutRequested is added',
      build: () {
        return AuthBloc(personRepository: mockPersonRepository);
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<LoggedOut>(),
      ],
    );
  });
}
