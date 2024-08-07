// Generated by the protocol buffer compiler.  DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// source: proto/song_datam.proto
// Protobuf Java Version: 4.27.2

package io.github.chikyukido.scrobblium.messages;

public interface SongDataMOrBuilder extends
    // @@protoc_insertion_point(interface_extends:io.github.chikyukido.scrobblium.messages.SongDataM)
    com.google.protobuf.MessageOrBuilder {

  /**
   * <code>int64 id = 1;</code>
   * @return The id.
   */
  long getId();

  /**
   * <code>string artist = 2;</code>
   * @return The artist.
   */
  java.lang.String getArtist();
  /**
   * <code>string artist = 2;</code>
   * @return The bytes for artist.
   */
  com.google.protobuf.ByteString
      getArtistBytes();

  /**
   * <code>string title = 3;</code>
   * @return The title.
   */
  java.lang.String getTitle();
  /**
   * <code>string title = 3;</code>
   * @return The bytes for title.
   */
  com.google.protobuf.ByteString
      getTitleBytes();

  /**
   * <code>string album = 4;</code>
   * @return The album.
   */
  java.lang.String getAlbum();
  /**
   * <code>string album = 4;</code>
   * @return The bytes for album.
   */
  com.google.protobuf.ByteString
      getAlbumBytes();

  /**
   * <code>string albumAuthor = 5;</code>
   * @return The albumAuthor.
   */
  java.lang.String getAlbumAuthor();
  /**
   * <code>string albumAuthor = 5;</code>
   * @return The bytes for albumAuthor.
   */
  com.google.protobuf.ByteString
      getAlbumAuthorBytes();

  /**
   * <code>int64 maxProgress = 6;</code>
   * @return The maxProgress.
   */
  long getMaxProgress();

  /**
   * <code>int64 startTime = 7;</code>
   * @return The startTime.
   */
  long getStartTime();

  /**
   * <code>int64 progress = 8;</code>
   * @return The progress.
   */
  long getProgress();

  /**
   * <code>int64 endTime = 9;</code>
   * @return The endTime.
   */
  long getEndTime();

  /**
   * <code>int32 timeListened = 10;</code>
   * @return The timeListened.
   */
  int getTimeListened();
}
