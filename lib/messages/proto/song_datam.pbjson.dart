//
//  Generated code. Do not modify.
//  source: proto/song_datam.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use songDataMDescriptor instead')
const SongDataM$json = {
  '1': 'SongDataM',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'artist', '3': 2, '4': 1, '5': 9, '10': 'artist'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'album', '3': 4, '4': 1, '5': 9, '10': 'album'},
    {'1': 'albumAuthor', '3': 5, '4': 1, '5': 9, '10': 'albumAuthor'},
    {'1': 'maxProgress', '3': 6, '4': 1, '5': 3, '10': 'maxProgress'},
    {'1': 'startTime', '3': 7, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'progress', '3': 8, '4': 1, '5': 3, '10': 'progress'},
    {'1': 'endTime', '3': 9, '4': 1, '5': 3, '10': 'endTime'},
    {'1': 'timeListened', '3': 10, '4': 1, '5': 5, '10': 'timeListened'},
  ],
};

/// Descriptor for `SongDataM`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List songDataMDescriptor = $convert.base64Decode(
    'CglTb25nRGF0YU0SDgoCaWQYASABKANSAmlkEhYKBmFydGlzdBgCIAEoCVIGYXJ0aXN0EhQKBX'
    'RpdGxlGAMgASgJUgV0aXRsZRIUCgVhbGJ1bRgEIAEoCVIFYWxidW0SIAoLYWxidW1BdXRob3IY'
    'BSABKAlSC2FsYnVtQXV0aG9yEiAKC21heFByb2dyZXNzGAYgASgDUgttYXhQcm9ncmVzcxIcCg'
    'lzdGFydFRpbWUYByABKANSCXN0YXJ0VGltZRIaCghwcm9ncmVzcxgIIAEoA1IIcHJvZ3Jlc3MS'
    'GAoHZW5kVGltZRgJIAEoA1IHZW5kVGltZRIiCgx0aW1lTGlzdGVuZWQYCiABKAVSDHRpbWVMaX'
    'N0ZW5lZA==');

@$core.Deprecated('Use songDataListMDescriptor instead')
const SongDataListM$json = {
  '1': 'SongDataListM',
  '2': [
    {'1': 'songs', '3': 1, '4': 3, '5': 11, '6': '.io.github.chikyukido.scrobblium.messages.SongDataM', '10': 'songs'},
  ],
};

/// Descriptor for `SongDataListM`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List songDataListMDescriptor = $convert.base64Decode(
    'Cg1Tb25nRGF0YUxpc3RNEkkKBXNvbmdzGAEgAygLMjMuaW8uZ2l0aHViLmNoaWt5dWtpZG8uc2'
    'Nyb2JibGl1bS5tZXNzYWdlcy5Tb25nRGF0YU1SBXNvbmdz');

