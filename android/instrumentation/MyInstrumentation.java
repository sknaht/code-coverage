package com.alert.instrumentation;

import android.app.Instrumentation;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.content.LocalBroadcastManager;

public class MyInstrumentation extends Instrumentation {
    private Intent intent;

    @Override
    public void onCreate(Bundle arguments) {
        intent = getTargetContext().getPackageManager()
                .getLaunchIntentForPackage("com.alert.trela.internal")
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        start(); // creates new thread which invokes onStart
    }

    @Override
    public void onStart() {
        startActivitySync(intent);
        LocalBroadcastManager.getInstance(getTargetContext()).registerReceiver(
                new EndEmmaBroadcast(), new IntentFilter("com.alert.instrumentation.END_EMMA"));
    }
}