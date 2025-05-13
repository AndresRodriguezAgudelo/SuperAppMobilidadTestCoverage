import 'package:mockito/annotations.dart';
import 'package:Equirent_Mobility/services/API.dart';
import 'package:Equirent_Mobility/BLoC/auth/auth_context.dart';
import 'package:Equirent_Mobility/BLoC/images/image_bloc.dart';
import 'package:Equirent_Mobility/BLoC/guides/guides_bloc.dart';

@GenerateMocks([APIService, AuthContext, ImageBloc, GuidesBloc])
void main() {}
