package com.in4ray.audio.music;

import android.media.MediaPlayer;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.in4ray.audio.AudioExtensionContext;

public class UnloadMusicFunction implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		FREObject result = null;
		try {
			// Get application context
			AudioExtensionContext ac = (AudioExtensionContext) context;
			// Get media player ID
			int mediaID = args[0].getAsInt();
			// Resets the MediaPlayer to its uninitialized state
			MediaPlayer mp = ac.mediaPlayerMap.get(mediaID);
			mp.reset();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

}
