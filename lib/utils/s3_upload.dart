import 'dart:io';

import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:async/async.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/utils/s3_policy.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

Future<bool> s3Upload(File file, String fileKey) async {

  String _accessKeyId = await AppData().getAccessKey();
  String _secretKeyId = await AppData().getSecretKey();
  String _bucketName = await AppData().getBucketName();
  String _region = await AppData().getBucketRegion();
  String _s3Endpoint = await AppData().getBucketUrl();

  final stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
  final length = await file.length();

  final uri = Uri.parse(_s3Endpoint);
  final req = http.MultipartRequest("POST", uri);
  final multipartFile = http.MultipartFile('file', stream, length,
      filename: path.basename(file.path));

  final policy = Policy.fromS3PresignedPost(
      'uploaded/$fileKey', _bucketName, _accessKeyId, 15, length, region: _region);
  final key =
  SigV4.calculateSigningKey(_secretKeyId, policy.datetime, _region, 's3');
  final signature = SigV4.calculateSignature(key, policy.encode());

  req.files.add(multipartFile);
  req.fields['key'] = policy.key;
  req.fields['acl'] = 'public-read';
  req.fields['X-Amz-Credential'] = policy.credential;
  req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
  req.fields['X-Amz-Date'] = policy.datetime;
  req.fields['Policy'] = policy.encode();
  req.fields['X-Amz-Signature'] = signature;

  try {
    final res = await req.send();
    if (res.statusCode == 200 || res.statusCode == 204) {
      return true;
    }
  } catch (e) {
    print(e.toString());
    return false;
  }

  return false;
}