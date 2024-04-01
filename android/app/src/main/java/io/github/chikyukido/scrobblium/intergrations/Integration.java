package io.github.chikyukido.scrobblium.intergrations;

import io.github.chikyukido.scrobblium.database.SongData;

import java.util.List;

/**
 * The integration for a other scrobble service like last.fm
 */
public interface Integration {
    /**
     * Checks if the user is still logged in with a valid session.
     * @return if the user is logged in
     */
    boolean isLoggedIn();

    /**
     * Sign in the user in the specific integration
     * @param username the username for the user either a email or the username
     * @param password the password in plaintext
     * @return if the login was successful
     */
    boolean signIn(String username,String password);

    /**
     * Signs out the user. Delete all the stored session data etc.
     */
    void signOut();

    /**
     * Sends a now playing notify to the integration. NowPlaying should not change the history only display the current playing song.
     * This method is called when a song changes
     * @param songData the songData of the current playing song
     */
    void nowPlaying(SongData songData);

    /**
     * Upload a finished track to the server. If there was no internet connection it can happen that multiple tracks are cached
     * up so you need to upload multiple tracks
     * @param songData the song data to upload
     */
    void uploadTracks(List<SongData> songData);
}
