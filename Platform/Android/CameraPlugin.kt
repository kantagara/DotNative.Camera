package com.dotnative.plugins

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import java.io.ByteArrayOutputStream

class CameraPlugin(private val activity: Activity) {

    private var pending: PluginReply? = null

    init {

        val channel = NativeChannels.channel("dotnative.camera")
        channel.handle("capturePhoto") { _, reply ->
            if (pending != null) {

                reply.failure("busy", "A camera capture is already open")
                return@handle
            }
            val intent = Intent("android.media.action.IMAGE_CAPTURE")
            if (intent.resolveActivity(activity.packageManager) == null) {

                reply.failure("unavailable", "No camera app is installed")
                return@handle
            }
            try {

                pending = reply
                val code =
                    NativeChannels.launch(activity, intent) { status, data ->
                        pending = null
                        if (status != Activity.RESULT_OK) {

                            reply.success()
                            return@launch
                        }
                        val bitmap = data?.extras?.get("data") as? Bitmap
                        if (bitmap == null) {

                            reply.failure("capture_failed", "Camera returned no image")
                            return@launch
                        }
                        val output = ByteArrayOutputStream()
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 75, output)
                        val bytes = output.toByteArray()
                        if (bytes.size > 900_000)
                            reply.failure(
                                "capture_failed",
                                "Camera thumbnail exceeded the channel size limit",
                            )
                        else reply.success(bytes)
                    }
                reply.onCancel = {
                    NativeChannels.cancelResult(code)
                    runCatching {
                        activity.finishActivity(code)
                    }
                    pending = null
                }
            } catch (error: Exception) {

                pending = null
                reply.failure("capture_failed", error.message ?: "Could not launch camera")
            }
        }
    }
}
