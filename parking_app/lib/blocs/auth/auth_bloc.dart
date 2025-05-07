import "package:bloc/bloc.dart";
import 'package:parking_app/repositories/person_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PersonRepository personRepository;

  AuthBloc({required this.personRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUser>(_onGetCurrentUser);
    on<UpdateUser>(_onUpdateUser);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await personRepository.getByPersonalNumber(event.personalNumber);
      if (user != null) {
        // Save user info to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', user.id);
        await prefs.setString('currentUserPersonalNumber', user.personalNumber ?? '');
        
        emit(AuthSuccess(user));
      } else {
        emit(const AuthFailure('User not found'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await personRepository.create(event.person);
      
      // Save user info to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', event.person.id);
      await prefs.setString('currentUserPersonalNumber', event.person.personalNumber ?? '');
      
      emit(AuthSuccess(event.person));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Clear user info from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUserId');
      await prefs.remove('currentUserPersonalNumber');
      
      emit(LoggedOut());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGetCurrentUser(GetCurrentUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Get user info from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final personalNumber = prefs.getString('currentUserPersonalNumber');
      
      if (personalNumber != null && personalNumber.isNotEmpty) {
        final user = await personRepository.getByPersonalNumber(personalNumber);
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
