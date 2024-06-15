//
//  Generated code. Do not modify.
//  source: proto/song_datam.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class SongDataM extends $pb.GeneratedMessage {
  factory SongDataM({
    $fixnum.Int64? id,
    $core.String? artist,
    $core.String? title,
    $core.String? album,
    $core.String? albumAuthor,
    $fixnum.Int64? maxProgress,
    $fixnum.Int64? startTime,
    $fixnum.Int64? progress,
    $fixnum.Int64? endTime,
    $core.int? timeListened,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (artist != null) {
      $result.artist = artist;
    }
    if (title != null) {
      $result.title = title;
    }
    if (album != null) {
      $result.album = album;
    }
    if (albumAuthor != null) {
      $result.albumAuthor = albumAuthor;
    }
    if (maxProgress != null) {
      $result.maxProgress = maxProgress;
    }
    if (startTime != null) {
      $result.startTime = startTime;
    }
    if (progress != null) {
      $result.progress = progress;
    }
    if (endTime != null) {
      $result.endTime = endTime;
    }
    if (timeListened != null) {
      $result.timeListened = timeListened;
    }
    return $result;
  }
  SongDataM._() : super();
  factory SongDataM.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SongDataM.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SongDataM', package: const $pb.PackageName(_omitMessageNames ? '' : 'io.github.chikyukido.scrobblium.messages'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'artist')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'album')
    ..aOS(5, _omitFieldNames ? '' : 'albumAuthor', protoName: 'albumAuthor')
    ..aInt64(6, _omitFieldNames ? '' : 'maxProgress', protoName: 'maxProgress')
    ..aInt64(7, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aInt64(8, _omitFieldNames ? '' : 'progress')
    ..aInt64(9, _omitFieldNames ? '' : 'endTime', protoName: 'endTime')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'timeListened', $pb.PbFieldType.O3, protoName: 'timeListened')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SongDataM clone() => SongDataM()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SongDataM copyWith(void Function(SongDataM) updates) => super.copyWith((message) => updates(message as SongDataM)) as SongDataM;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SongDataM create() => SongDataM._();
  SongDataM createEmptyInstance() => create();
  static $pb.PbList<SongDataM> createRepeated() => $pb.PbList<SongDataM>();
  @$core.pragma('dart2js:noInline')
  static SongDataM getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SongDataM>(create);
  static SongDataM? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get artist => $_getSZ(1);
  @$pb.TagNumber(2)
  set artist($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasArtist() => $_has(1);
  @$pb.TagNumber(2)
  void clearArtist() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get album => $_getSZ(3);
  @$pb.TagNumber(4)
  set album($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAlbum() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlbum() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get albumAuthor => $_getSZ(4);
  @$pb.TagNumber(5)
  set albumAuthor($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAlbumAuthor() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlbumAuthor() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get maxProgress => $_getI64(5);
  @$pb.TagNumber(6)
  set maxProgress($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMaxProgress() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxProgress() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get startTime => $_getI64(6);
  @$pb.TagNumber(7)
  set startTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStartTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartTime() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get progress => $_getI64(7);
  @$pb.TagNumber(8)
  set progress($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasProgress() => $_has(7);
  @$pb.TagNumber(8)
  void clearProgress() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get endTime => $_getI64(8);
  @$pb.TagNumber(9)
  set endTime($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasEndTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearEndTime() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get timeListened => $_getIZ(9);
  @$pb.TagNumber(10)
  set timeListened($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasTimeListened() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimeListened() => clearField(10);
}

class SongDataListM extends $pb.GeneratedMessage {
  factory SongDataListM({
    $core.Iterable<SongDataM>? songs,
  }) {
    final $result = create();
    if (songs != null) {
      $result.songs.addAll(songs);
    }
    return $result;
  }
  SongDataListM._() : super();
  factory SongDataListM.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SongDataListM.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SongDataListM', package: const $pb.PackageName(_omitMessageNames ? '' : 'io.github.chikyukido.scrobblium.messages'), createEmptyInstance: create)
    ..pc<SongDataM>(1, _omitFieldNames ? '' : 'songs', $pb.PbFieldType.PM, subBuilder: SongDataM.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SongDataListM clone() => SongDataListM()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SongDataListM copyWith(void Function(SongDataListM) updates) => super.copyWith((message) => updates(message as SongDataListM)) as SongDataListM;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SongDataListM create() => SongDataListM._();
  SongDataListM createEmptyInstance() => create();
  static $pb.PbList<SongDataListM> createRepeated() => $pb.PbList<SongDataListM>();
  @$core.pragma('dart2js:noInline')
  static SongDataListM getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SongDataListM>(create);
  static SongDataListM? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SongDataM> get songs => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
