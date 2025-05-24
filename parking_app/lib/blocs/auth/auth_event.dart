import 'package:equatable/equatable.dart';
import '../../../models/person.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String personalNumber;
  
  const RegisterRequested(Person newUser, {
    required this.email,
    required this.password,
    required this.name,
    required this.personalNumber,
  });
  
  @override
  List<Object?> get props => [email, password, name, personalNumber];
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

class GitHubSignInRequested extends AuthEvent {}

class CompleteGitHubRegistration extends AuthEvent {
  final String uid;
  final String name;
  final String email;
  final String personalNumber;
  const CompleteGitHubRegistration({required this.uid, required this.name, required this.email, required this.personalNumber});
  @override
  List<Object?> get props => [uid, name, email, personalNumber];
}
