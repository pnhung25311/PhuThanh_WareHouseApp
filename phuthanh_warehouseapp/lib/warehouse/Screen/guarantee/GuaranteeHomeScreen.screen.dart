import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/guarantee/GuaranteeDetail.screen.dart';
// import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomGuaranteeItem.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/model/info/Guaranteet.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class GuaranteetHome extends StatefulWidget {
  const GuaranteetHome({super.key});

  @override
  State<GuaranteetHome> createState() => _GuaranteetHomeState();
}

class _GuaranteetHomeState extends State<GuaranteetHome> {
  List<Guarantee> _guarantees = [];
  bool _isLoading = true;
  InfoService infoService = InfoService();
  NavigationHelper navigationHelper = NavigationHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await infoService.LoadGuarantee();

      if (result["isSuccess"] == true) {
        final body = result["body"];
        if (body is List<Guarantee>) {
          setState(() {
            _guarantees = body;
            _isLoading = false;
          });
        } else {
          print("Body không phải List<Guarantee>: ${body.runtimeType}");
          setState(() {
            _guarantees = [];
            _isLoading = false;
          });
        }
      } else {
        print("API thất bại: ${result["body"]}");
        setState(() {
          _guarantees = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Exception trong _loadData: $e");
      setState(() {
        _guarantees = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = AppState.instance.get("role");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách bảo hành"),
        backgroundColor: Colors.blue,
      ),

      // drawer: CustomDrawer(onWarehouseSelected: _loadData),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await để lấy kết quả trả về từ màn hình thêm bảo hành
          final result = await navigationHelper.push(
            context,
            GuaranteeDetailScreen(
              item: Guarantee.empty(),
              isCreate: roles == true,
            ),
          );

          if(result == true){
            _loadData();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guarantees.isEmpty
          ? const Center(child: Text("Không có dữ liệu bảo hành."))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _guarantees.length,
                itemBuilder: (context, index) {
                  final item = _guarantees[index];
                  return GuaranteeListItem(guarantee: item, cb: () => _loadData(),);
                },
              ),
            ),
    );
  }
}
