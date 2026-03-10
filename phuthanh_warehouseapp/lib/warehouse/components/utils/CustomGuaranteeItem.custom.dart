import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/guarantee/GuaranteeDetail.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/model/info/Guaranteet.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class GuaranteeListItem extends StatefulWidget {
  final Guarantee guarantee;
  final VoidCallback? cb; // callback cũ (nếu có, ví dụ refresh list)

  const GuaranteeListItem({super.key, required this.guarantee, this.cb});

  @override
  State<GuaranteeListItem> createState() => _GuaranteeListItemState();
}

class _GuaranteeListItemState extends State<GuaranteeListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  final NavigationHelper _nav = NavigationHelper();

  bool _isExpanded = false;
  bool _isViewed = false;

  String? _cachedInternalNetwork; // cache kết quả mạng nội bộ
  final Formatdatehelper _dateHelper = Formatdatehelper();
  final FunctionConvertHelper _convertHelper = FunctionConvertHelper();
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _checkInternalNetworkOnce();
  }

  Future<void> _checkInternalNetworkOnce() async {
    if (_cachedInternalNetwork != null) return;

    try {
      final isInternal = await _apiClient.isInternalNetwork();
      if (mounted) {
        setState(() {
          _cachedInternalNetwork = isInternal ? 'internal' : 'public';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cachedInternalNetwork = 'public');
      }
    }
  }

  String _getImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final url = rawUrl.trim();

    if (_cachedInternalNetwork == 'internal') return url;
    if (_cachedInternalNetwork == 'public') {
      return _convertHelper.convertToPublicIP(url);
    }
    // fallback
    return url;
  }

  String _formatDate(DateTime? date) =>
      date != null ? _dateHelper.formatDMY(date) : '—';

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final g = widget.guarantee;
    final isAdminOrEditor =
        AppState.instance.get<bool>("role") ==
        true; // giả sử role true = có quyền edit

    final hasRemarkOrImages =
        (g.remark?.trim().isNotEmpty ?? false) ||
        g.img1 != null ||
        g.img2 != null ||
        g.img3 != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: _isViewed ? 1 : 2,
      shadowColor: colorScheme.shadow.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Đánh dấu đã xem
          setState(() {
            _isViewed = true;
          });
          // Mở màn hình chi tiết (chế độ xem)
          final result = await _nav.push(
            context,
            GuaranteeDetailScreen(
              item: widget.guarantee,
              readOnly: !isAdminOrEditor,
              isUpdate: isAdminOrEditor,
            ),
          );
          // Optional: khi quay lại có thể refresh trạng thái nếu cần
          if (mounted) {
            setState(() {}); // ví dụ: nếu backend có thay đổi viewed
          }
          if (result == true) {
            widget.cb?.call();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Mã phiếu + Thời gian bảo hành
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.guaranteeID ?? 'Chưa có mã',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (g.timeGuarantee != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'Bảo hành ${_formatDate(g.timeGuarantee)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 16),

              // Thông tin chính - dạng grid nhỏ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCompactStat(
                    label: 'Bắt đầu',
                    value: _formatDate(g.timeStart),
                  ),
                  _buildCompactStat(
                    label: 'Hỏng',
                    value: _formatDate(g.timeBroken),
                    color: Colors.orange.shade800,
                  ),
                  _buildCompactStat(
                    label: 'Sử dụng',
                    value: g.timeUsage != null
                        ? '${g.timeUsage!.toStringAsFixed(0)} ngày'
                        : '—',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sản phẩm hỏng
              _buildDetailRow(
                icon: Icons.broken_image_rounded,
                label: 'Sản phẩm hỏng',
                value: g.nameProductBroken ?? '—',
                subtitle:
                    '${g.productIDBroken ?? ''} ${g.idPartNoBroken?.isNotEmpty == true ? '• ${g.idPartNoBroken}' : ''}'
                        .trim(),
                iconColor: Colors.red.shade700,
              ),

              if (g.reasonBroken?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'Lý do hỏng',
                  value: g.reasonBroken!,
                  iconColor: Colors.orange.shade700,
                ),
              ],

              // Sản phẩm thay thế / bảo hành
              if (g.nameProductGuarantee?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Thay thế / Bảo hành',
                  value: g.nameProductGuarantee!,
                  subtitle: g.productIDGuarantee,
                  iconColor: Colors.blue.shade700,
                ),
              ],

              // Đối tác
              if (g.partner?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.business_rounded,
                  label: 'Đối tác / NCC',
                  value: g.partner!,
                ),
              ],

              // Phần mở rộng: Ghi chú + Ảnh
              if (hasRemarkOrImages) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      if (_isExpanded) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isExpanded
                            ? 'Thu gọn chi tiết'
                            : 'Xem chi tiết (ghi chú & ảnh)',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (g.remark?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Ghi chú:',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g.remark!.trim(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: colorScheme.onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      if (g.img1 != null ||
                          g.img2 != null ||
                          g.img3 != null) ...[
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (g.img1 != null) _buildImagePreview(g.img1!),
                              if (g.img2 != null) _buildImagePreview(g.img2!),
                              if (g.img3 != null) _buildImagePreview(g.img3!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Footer: Người cập nhật
              if (g.lastUser != null || g.lastTime != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Cập nhật bởi ${g.lastUser ?? "—"} • ${_formatDate(g.lastTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat({
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle.trim(),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String rawUrl) {
    final url = _getImageUrl(rawUrl);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // TODO: implement full-screen image viewer nếu muốn
          // Navigator.push(context, MaterialPageRoute(builder: (_) => FullImageScreen(url: url)));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.grey,
                  size: 32,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
