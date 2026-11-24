package com.holidayhomemanager.app;
import android.os.Bundle;import com.getcapacitor.BridgeActivity;
public class MainActivity extends BridgeActivity { @Override public void onCreate(Bundle b){registerPlugin(ArchivePlugin.class);super.onCreate(b);} }