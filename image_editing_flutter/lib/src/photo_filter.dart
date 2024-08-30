part of '../image_editing_flutter.dart';

class PhotoFilterHomePage extends StatefulWidget {
  const PhotoFilterHomePage({super.key});

  @override
  _PhotoFilterHomePageState createState() => _PhotoFilterHomePageState();
}

class _PhotoFilterHomePageState extends State<PhotoFilterHomePage> {
  File? _image;
  ui.Image? _filteredImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final permissionStatus = await _requestPermission();
    if (!permissionStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery access is required to select an image.')),
      );
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _filteredImage = null; // Reset filtered image
      });
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
        return status.isGranted;
      }
      return true;
    } else if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    }
    return false;
  }

  Future<void> _applyFilter() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final image = await _loadImage(_image!.path);
    final filteredImage = await compute(_applyGrayscaleFilter, image);

    setState(() {
      _filteredImage = filteredImage;
      _isLoading = false; // Hide loading indicator
    });
  }

  Future<ui.Image> _loadImage(String path) async {
    try {
      final data = await File(path).readAsBytes();
      return await decodeImageFromList(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image: $e')),
      );
      rethrow;
    }
  }

  static Future<ui.Image> _applyGrayscaleFilter(ui.Image image) async {
    final paint = ui.Paint()
      ..colorFilter = const ui.ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    canvas.drawImage(image, Offset.zero, paint);
    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Filter App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _image == null
              ? const Text('No image selected.')
              : _isLoading
              ? const CircularProgressIndicator()
              : (_filteredImage == null
              ? Image.file(_image!)
              : CustomPaint(
            size: Size(_filteredImage!.width.toDouble(), _filteredImage!.height.toDouble()),
            painter: ImagePainter(_filteredImage!),
          )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async{
                await  _pickImage() ;
                },
                child: const Text('Pick Image'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _applyFilter,
                child: const Text('Apply Filter'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

