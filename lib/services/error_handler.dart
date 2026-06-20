class ErrorHandler {
  static String getMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'El usuario no está registrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este correo ya tiene una cuenta activa.';
      case 'network-request-failed':
        return 'Comprueba tu conexión a internet e inténtalo de nuevo.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      default:
        return 'Ocurrió un error inesperado ($errorCode). Inténtalo más tarde.';
    }
  }
}
