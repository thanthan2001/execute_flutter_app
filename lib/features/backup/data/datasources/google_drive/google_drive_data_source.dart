import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleDriveDataSource {
  final GoogleSignIn googleSignIn;

  GoogleDriveDataSource({required this.googleSignIn});

  Future<drive.DriveApi> _getDriveApi() async {
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google Sign-In canceled');
    }

    final authHeaders = await account.authHeaders;
    final client = _GoogleAuthClient(authHeaders);
    return drive.DriveApi(client);
  }

  Future<void> signIn() async {
    await googleSignIn.signIn();
  }

  Future<drive.File> uploadFile(File file) async {
    final api = await _getDriveApi();
    final fileName = file.path.split(Platform.pathSeparator).last;

    final driveFile = drive.File();
    driveFile.name = fileName;
    driveFile.mimeType = 'application/json';

    final media = drive.Media(file.openRead(), await file.length());

    final result = await api.files.create(
      driveFile,
      uploadMedia: media,
    );

    return result;
  }

  Future<List<drive.File>> listFiles() async {
    final api = await _getDriveApi();

    final fileList = await api.files.list(
      q: "mimeType='application/json' and name contains 'moni_backup'",
      $fields: 'files(id,name,createdTime,size)',
      orderBy: 'createdTime desc',
    );

    return fileList.files ?? [];
  }

  Future<File> downloadFile(String fileId) async {
    final api = await _getDriveApi();

    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/moni_backup_download.json');

    final sink = file.openWrite();
    await media.stream.pipe(sink);
    await sink.flush();
    await sink.close();

    return file;
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request..headers.addAll(_headers));
  }
}
