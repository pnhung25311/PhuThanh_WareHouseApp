import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

typedef OnImageSelected = void Function(File? image, String? imageUrl);

class CustomImagePicker extends StatefulWidget {
  final File? initialImage;
  final double width;
  final double height;
  final String label;
  final OnImageSelected? onImageSelected;

  const CustomImagePicker({
    super.key,
    this.initialImage,
    this.width = 150,
    this.height = 150,
    this.label = "Chọn ảnh",
    this.onImageSelected,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  File? _image;
  String? _uploadedImageUrl; // URL ảnh sau khi upload
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _uploadedImageUrl = null;
      });

      // Upload ảnh sau khi chọn
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      // 🔹 API upload của Spring Boot
      final uri = Uri.parse("http://192.168.1.67:8080/upload");
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        final imageUrl = data['url'];

        setState(() {
          _uploadedImageUrl = imageUrl;
          _isUploading = false;
        });

        // Gọi callback trả về ảnh và URL
        if (widget.onImageSelected != null) {
          widget.onImageSelected!(_image, imageUrl);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload thành công!')),
        );
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload thất bại: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi upload: $e')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ Thư viện'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => _showImageSourceActionSheet(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _image != null
                    ? Image.file(
                        _image!,
                        width: widget.width,
                        height: widget.height,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: widget.width,
                        height: widget.height,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 80, color: Colors.white),
                      ),
              ),
              if (_isUploading)
                Container(
                  width: widget.width,
                  height: widget.height,
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        if (_uploadedImageUrl != null)
          Text(
            "URL: $_uploadedImageUrl",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
      ],
    );
  }
}
