
import 'package:photoediter/export.dart';

class PhotoOpenProvider with ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void show() {
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  void toggler(Duration duration) {
    if (!_isVisible) {
      show();
      Future.delayed(duration, () {
        hide();
      });
    } else {
      hide();
    }
  }

  // save image CALL THE MAINACTIVITY.KT
  static const platform = MethodChannel('com.photoediter.save');
    Future<void> sImageToGallery(String image,String mime,BuildContext context) async {
      // Request permission
      try {
        // Ask permission
        String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}${mime == 'png' ? '.png' : '.jpg'}';
        final result = await platform.invokeMethod('saveToGallery', {
          'path': image,
          'name': fileName,
          'mime':mime == 'png' ? 'image/png' : 'image/jpg'
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Image saved to gallery!")),
        );

      } catch (e) {
        print("❌ Save failed: $e");
      }
    }
}
