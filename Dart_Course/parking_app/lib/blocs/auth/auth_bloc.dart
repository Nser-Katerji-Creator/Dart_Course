import "package:bloc/bloc.dart";
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:parking_app/services/firebase_auth_repository.dart';
import 'package:parking_app/repositories/firebase_person_repository.dart';
import '../../models/person.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebasePersonRepository personRepository;
  final FirebaseAuthRepository authRepository;
  bool _isProcessingAuthChange = false; // Flag to prevent infinite loops

  AuthBloc({
    required this.personRepository,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUser>(_onGetCurrentUser);
    on<UpdateUser>(_onUpdateUser);
    on<GitHubSignInRequested>(_onGitHubSignInRequested);
    on<CompleteGitHubRegistration>(_onCompleteGitHubRegistration);

    // Listen to Firebase Auth state changes
    authRepository.authStateChanges.listen((firebase_auth.User? firebaseUser) {
      if (_isProcessingAuthChange) return; // Prevent infinite loops
      
      _isProcessingAuthChange = true;
      
      if (firebaseUser == null) {
        add(LogoutRequested());
      } else {
        // User is signed in, get their profile from Firestore
        _fetchUserProfile(firebaseUser.uid);
      }
      
      // Reset flag after a short delay
      Future.delayed(Duration(milliseconds: 100), () {
        _isProcessingAuthChange = false;
      });
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final user = await personRepository.getCurrentUser();
      if (user != null) {
        add(GetCurrentUser());
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Sign in with Firebase Auth
      await authRepository.signIn(event.email, event.password);

      // Auth state listener will handle the rest
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Register with Firebase Auth
      final userCredential = await authRepository.register(event.email, event.password);

      // Create user profile in Firestore
      final person = Person(
        id: userCredential.user!.uid,
        name: event.name,
        email: event.email,
        personalNumber: event.personalNumber,
      );

      await personRepository.create(person);
      emit(AuthSuccess(person));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(LoggedOut());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGetCurrentUser(GetCurrentUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final firebaseUser = authRepository.currentUser;

      if (firebaseUser != null) {
        final user = await personRepository.getCurrentUser();
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(LoggedOut());
        }
      } else {
        emit(LoggedOut());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await personRepository.update(event.personalNumber, event.person);
      emit(AuthSuccess(event.person));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGitHubSignInRequested(GitHubSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await authRepository.signInWithGitHub();
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception('No user returned from GitHub sign-in');
      // Try to get user profile from Firestore
      var person = await personRepository.getByEmail(firebaseUser.email ?? '');
      if (person == null) {
        // If we cannot create a Person (e.g. missing email), throw a clear error
        if (firebaseUser.email == null || firebaseUser.email!.isEmpty) {
          throw Exception('GitHub account does not provide an email. Please use a GitHub account with a public email.');
        }
        // Instead of creating Person here, emit a special state to prompt for personal number
        emit(AuthRequirePersonalNumber(
          firebaseUser.uid,
          firebaseUser.displayName ?? firebaseUser.email ?? 'GitHub User',
          firebaseUser.email ?? '',
        ));
        return;
      }
      emit(AuthSuccess(person));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCompleteGitHubRegistration(CompleteGitHubRegistration event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final person = Person(
        id: event.uid,
        name: event.name,
        email: event.email,
        personalNumber: event.personalNumber,
      );
      await personRepository.create(person);
      emit(AuthSuccess(person));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
