abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erreur d\'authentification.']);
}

class EmailAlreadyUsedFailure extends Failure {
  const EmailAlreadyUsedFailure()
      : super('Cette adresse email est déjà utilisée.');
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super('Email ou mot de passe incorrect.');
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure()
      : super('Le mot de passe doit contenir au moins 8 caractères.');
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure() : super('Utilisateur introuvable.');
}

class PermissionFailure extends Failure {
  const PermissionFailure()
      : super('Vous n\'êtes pas autorisé à effectuer cette action.');
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur est survenue.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
