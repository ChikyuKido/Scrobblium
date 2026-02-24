// This is a generated file - do not edit.
//
// Generated from proto/song_datam.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SongDataM extends $pb.GeneratedMessage {
  factory SongDataM({
    $core.int? id,
    $core.String? artist,
    $core.String? title,
    $core.String? album,
    $core.String? albumAuthor,
    $core.int? maxProgress,
    $fixnum.Int64? startTime,
    $core.int? progress,
    $fixnum.Int64? endTime,
    $core.int? timeListened,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (artist != null) result.artist = artist;
    if (title != null) result.title = title;
    if (album != null) result.album = album;
    if (albumAuthor != null) result.albumAuthor = albumAuthor;
    if (maxProgress != null) result.maxProgress = maxProgress;
    if (startTime != null) result.startTime = startTime;
    if (progress != null) result.progress = progress;
    if (endTime != null) result.endTime = endTime;
    if (timeListened != null) result.timeListened = timeListened;
    return result;
  }

  SongDataM._();

  factory SongDataM.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SongDataM.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SongDataM',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'io.github.chikyukido.scrobblium.messages'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'artist')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'album')
    ..aOS(5, _omitFieldNames ? '' : 'albumAuthor', protoName: 'albumAuthor')
    ..aI(6, _omitFieldNames ? '' : 'maxProgress', protoName: 'maxProgress')
    ..aInt64(7, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aI(8, _omitFieldNames ? '' : 'progress')
    ..aInt64(9, _omitFieldNames ? '' : 'endTime', protoName: 'endTime')
    ..aI(10, _omitFieldNames ? '' : 'timeListened', protoName: 'timeListened')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SongDataM clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SongDataM copyWith(void Function(SongDataM) updates) =>
      super.copyWith((message) => updates(message as SongDataM)) as SongDataM;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SongDataM create() => SongDataM._();
  @$core.override
  SongDataM createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SongDataM getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SongDataM>(create);
  static SongDataM? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get artist => $_getSZ(1);
  @$pb.TagNumber(2)
  set artist($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasArtist() => $_has(1);
  @$pb.TagNumber(2)
  void clearArtist() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get album => $_getSZ(3);
  @$pb.TagNumber(4)
  set album($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAlbum() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlbum() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get albumAuthor => $_getSZ(4);
  @$pb.TagNumber(5)
  set albumAuthor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAlbumAuthor() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlbumAuthor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxProgress => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxProgress($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxProgress() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxProgress() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get startTime => $_getI64(6);
  @$pb.TagNumber(7)
  set startTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStartTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get progress => $_getIZ(7);
  @$pb.TagNumber(8)
  set progress($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasProgress() => $_has(7);
  @$pb.TagNumber(8)
  void clearProgress() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get endTime => $_getI64(8);
  @$pb.TagNumber(9)
  set endTime($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasEndTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearEndTime() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get timeListened => $_getIZ(9);
  @$pb.TagNumber(10)
  set timeListened($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTimeListened() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimeListened() => $_clearField(10);
}

class SongDataListM extends $pb.GeneratedMessage {
  factory SongDataListM({
    $core.Iterable<SongDataM>? songs,
  }) {
    final result = create();
    if (songs != null) result.songs.addAll(songs);
    return result;
  }

  SongDataListM._();

  factory SongDataListM.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SongDataListM.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SongDataListM',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'io.github.chikyukido.scrobblium.messages'),
      createEmptyInstance: create)
    ..pPM<SongDataM>(1, _omitFieldNames ? '' : 'songs',
        subBuilder: SongDataM.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SongDataListM clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SongDataListM copyWith(void Function(SongDataListM) updates) =>
      super.copyWith((message) => updates(message as SongDataListM))
          as SongDataListM;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SongDataListM create() => SongDataListM._();
  @$core.override
  SongDataListM createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SongDataListM getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SongDataListM>(create);
  static SongDataListM? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SongDataM> get songs => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
