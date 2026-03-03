import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';

class ViewImageScreen extends StatefulWidget {
  final Product item;

  const ViewImageScreen({super.key, required this.item});

  @override
  State<ViewImageScreen> createState() => _ViewImageScreenState();
}

class _ViewImageScreenState extends State<ViewImageScreen> {
  bool? statusConnect; // null = chưa load xong
  FunctionConvertHelper functionConvertHelper = FunctionConvertHelper();
  @override
  void initState() {
    super.initState();
    checkNetwork();
  }

  void checkNetwork() async {
    final api = ApiClient();
    bool result = await api.isInternalNetwork();
    setState(() {
      statusConnect = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = [
      widget.item.img1,
      widget.item.img2,
      widget.item.img3,
    ].whereType<String>().where((url) => url.isNotEmpty).toList();

    // 🟡 Chưa load xong trạng thái mạng => show loading
    if (statusConnect == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ảnh: ${widget.item.nameProduct}'),
        centerTitle: true,
      ),
      body: images.isEmpty
          ? const Center(child: Text('Không có ảnh để hiển thị'))
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index].trim();
                print(imageUrl);

                final finalUrl = statusConnect == true
                    ? imageUrl
                    : functionConvertHelper.convertToPublicIP(imageUrl);

                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    InteractiveViewer(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          finalUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Text('Không tải được ảnh')),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 100),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Ảnh ${index + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
