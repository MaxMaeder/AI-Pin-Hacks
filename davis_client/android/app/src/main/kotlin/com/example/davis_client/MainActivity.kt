package com.example.davis_client

import android.os.Bundle
import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.util.Log


class MainActivity: FlutterActivity(), View.OnGenericMotionListener {

    private val CHANNEL = "touchpad_events"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
      super.configureFlutterEngine(flutterEngine)


      val contentView = findViewById<View>(android.R.id.content)
      contentView.setOnGenericMotionListener(this)

      window.decorView.setOnGenericMotionListener(this)

      Log.e("HERE!", "HI")

      val inputDevices = mutableListOf<InputDevice>()
      for (id in InputDevice.getDeviceIds()) {
          val device = InputDevice.getDevice(id)
          if (device != null) {
              inputDevices.add(device)
          }
      }
      
      for (device in inputDevices) {
          Log.e("InputDevice", "Device: ${device.name}, Sources: ${device.sources}")
      }
      
      
    }
    
    override fun dispatchGenericMotionEvent(event: MotionEvent?): Boolean {
      Log.e("Touchpad Dispatch", "Event detected")
      if (event != null) {
          Log.e("Touchpad Dispatch", "Event detected: x=${event.x}, y=${event.y}, action=${event.action}")
      }
      return super.dispatchGenericMotionEvent(event)
    }


    override fun onGenericMotion(v: View?, event: MotionEvent?): Boolean {
      Log.e("Touchpad Dispatch", "Event detected")
      if (event != null) {
        Log.e("Touchpad", "Event detected: x=${event.x}, y=${event.y}, action=${event.action}")
          //print("here")
          val x = event.x
          val y = event.y
          sendTouchpadEvent(x, y)
          return true
      }
      return false
    }

    private fun sendTouchpadEvent(x: Float, y: Float) {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod(
            "onTouchpadEvent", mapOf("x" to x, "y" to y)
        )
    }
}
