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

  AuthBloc({
    required this.personRepository,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUser>(_onGetCurrentUser);
    on<UpdateUser>(_onUpdateUser);
    
    // Listen to Firebase Auth state changes
    authRepository.authStateChanges.listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser == null) {
        add(LogoutRequested());
      } else {
        // User is signed in, get their profile from Firestore
        _fetchUserProfile(firebaseUser.uid);
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final user = await personRepository.getCurrentUser();
      if (user != null) {
        add(UpdateUser(user.personalNumber ?? '', user));
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
        id:userCredential.user!.uid,
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
}
