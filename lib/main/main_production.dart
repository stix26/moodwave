import 'package:my_app/main/bootstrap.dart';
import 'package:my_app/models/enums/flavor.dart';
import 'package:my_app/features/app/app_view.dart';

void main() {
  bootstrap(
    builder: () => const AppView(),
    flavor: Flavor.production,
  );
}
