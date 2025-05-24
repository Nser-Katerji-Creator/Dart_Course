import 'package:equatable/equatable.dart';
import '../../../models/person.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Person user;
  
  const AuthSuccess(this.user);
  
  @override
  List<Object?> get props => [user];

  bool get isAdmin => user.email == 'admin@example.com';
}

class AuthFailure extends AuthState {
  final String error;
  
  const AuthFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}

class AuthOperationSuccess extends AuthState {
  final String message;
  
  const AuthOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class LoggedOut extends AuthState {}

class AuthRequirePersonalNumber extends AuthState {
  final String uid;
  final String name;
  final String email;
  const AuthRequirePersonalNumber(this.uid, this.name, this.email);
  @override
  List<Object?> get props => [uid, name, email];
}
