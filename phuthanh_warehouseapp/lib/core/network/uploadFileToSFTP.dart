import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';

/// Tạo thư mục trên SFTP nếu chưa tồn tại
Future<void> createDirIfNotExist(SftpClient sftp, String path) async {
  final segments = path.split('/')..removeWhere((s) => s.isEmpty);
  String current = '';
  for (var segment in segments) {
    current += '/$segment';
    try {
      await sftp.stat(current); // kiểm tra xem thư mục có tồn tại không
    } catch (_) {
      await sftp.mkdir(current); // tạo nếu chưa có
    }
  }
}

/// Upload file lên SFTP và trả về đường link
Future<String?> uploadFileToSFTP(File file) async {
  try {
    // Kết nối SSH
    final client = SSHClient(
      await SSHSocket.connect("192.168.1.11", 2222),
      username: 'user',
      onPasswordRequest: () => '1234',
    );

    final sftp = await client.sftp();

    // Thư mục lưu file trên server
    final remoteDir = '/sftp-root/';
    await createDirIfNotExist(sftp, remoteDir);

    final remotePath = '$remoteDir${file.uri.pathSegments.last}';

    // Mở file trên server để ghi
    final sftpFile = await sftp.open(
      remotePath,
      mode: SftpFileOpenMode.write | SftpFileOpenMode.create,
    );

    // Ghi dữ liệu (writeBytes trả về void, không await)
    final bytes = await file.readAsBytes();
    sftpFile.writeBytes(Uint8List.fromList(bytes));

    sftpFile.close(); // đóng file
    client.close();

    return 'https://your.server.com$remotePath'; // tùy server
  } catch (e) {
    print('❌ Lỗi upload SFTP: $e');
    return null;
  }
}
