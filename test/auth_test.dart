import 'package:firstproject/services/auth/auth_exceptions.dart';
import 'package:firstproject/services/auth/auth_provider.dart';
import 'package:firstproject/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main(){
  group('Mock Authentication', (){
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', (){
      expect(provider.isInitialized, false);
    });
    test('Cannot log out if is not initialized ', () {
      expect(
        provider.logOut(), 
        throwsA(const TypeMatcher<NotInitializedExeption>()),
        );
    });

    test('Should be able to be initialized',() async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('User should be null after initialization', (){
      expect(provider.currentUser, null);
    });

    test('Should be able to initialized in less than 2 seconds',() async{
      await provider.initialize();
      expect(provider.isInitialized, true); 
    }, 
    timeout: const Timeout(const Duration(seconds: 2)),
    );
    test('Create user should delegate to logIn function', () async{
    final badEmailUser = provider.createUser(
      email: 'ana@chenoweth.com', 
      password: 'anypassword',
      );
      expect(badEmailUser, 
            throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPasswordUser = provider.createUser(
        email: 'someone@email.com', 
        password: 'bebe69',
      );
      expect(badPasswordUser, 
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

          final user = await provider.createUser(
            email: 'foo', 
            password: 'bar',
            );
          expect(provider.currentUser, user);
          expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', (){
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, false);
    });

    test('Should be able to log out and log in again', () async{
      await provider.logOut();
      await provider.logIn(
        email: 'email', 
        password: 'password',
        );
        final user = provider.currentUser;
        expect(user, isNotNull);
    });
  });

  
}

class NotInitializedExeption implements Exception {}

class MockAuthProvider implements AuthProvider{
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  @override
  Future<AuthUser> createUser({
    required String email, 
    required String password,
    }) async{
      if(!isInitialized) throw NotInitializedExeption();
      await Future.delayed(const Duration(seconds: 1));
      return logIn(
        email: email, 
        password: password,
        );
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email, 
    required String password,
    }) {
    if(!isInitialized) throw NotInitializedExeption();
    if(email == 'ana@chenoweth.com') throw UserNotFoundAuthException();
    if(password == 'bebe69') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified:  false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if(!isInitialized) throw NotInitializedExeption();
    if(_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if(!isInitialized) throw NotInitializedExeption();
    final user = _user;
    if(user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }

}