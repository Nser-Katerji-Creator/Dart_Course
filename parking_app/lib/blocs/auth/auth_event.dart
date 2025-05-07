import 'package:equatable/equatable.dart';
import '../../../models/person.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String personalNumber;
  
  const LoginRequested(this.personalNumber);
  
  @override
  List<Object?> get props => [personalNumber];
}

class RegisterRequested extends AuthEvent {
  final Person person;
  
  const RegisterRequested(this.person);
  
  @override
  List<Object?> get props => [person];
}

class LogoutRequested extends AuthEvent {}

class GetCurrentUser extends AuthEvent {}

class UpdateUser extends AuthEvent {
  final String personalNumber;
  final Person person;
  
  const UpdateUser(this.personalNumber, this.person);
  
  @override
  List<Object?> get props => [personalNumber, person];
}
