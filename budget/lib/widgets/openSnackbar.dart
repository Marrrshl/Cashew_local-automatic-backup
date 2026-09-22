import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/navigationFramework.dart';

openSnackbar(SnackbarMessage message, {bool postIfQueue = true}) {
  if (snackbarKey.currentState == null) {
    Future.delayed(const Duration(milliseconds: 150), () {
      openSnackbar(message, postIfQueue: postIfQueue);
    });
    return;
  }
  snackbarKey.currentState!.post(message, postIfQueue: postIfQueue);
  return;
}
