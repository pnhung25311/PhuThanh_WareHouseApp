package com.example.phuthanh_warehouseapp

import android.content.ContentResolver
import android.content.Context
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Watches MediaStore for newly inserted screenshot images and streams the
 * local (app cache) file path of each one to Flutter via an EventChannel.
 *
 * Only images added in the last [RECENT_WINDOW_MS] whose display name or
 * relative path looks like a screenshot are forwarded, since MediaStore
 * fires onChange() for unrelated media writes too.
 */
class ScreenshotStreamHandler(
    private val context: Context,
    private val isInForeground: () -> Boolean,
) : EventChannel.StreamHandler {

    private var contentObserver: ContentObserver? = null
    private var lastHandledId: Long = -1

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val resolver = context.contentResolver
        val handler = Handler(Looper.getMainLooper())

        val observer = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                super.onChange(selfChange, uri)
                // Không để lỗi (thiếu quyền đọc ảnh, MediaStore từ chối truy vấn...)
                // lan ra thành crash app trên main thread.
                try {
                    handleChange(resolver, events)
                } catch (e: Exception) {
                    Log.w(TAG, "Screenshot detection failed", e)
                }
            }
        }
        contentObserver = observer
        resolver.registerContentObserver(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            true,
            observer,
        )
    }

    override fun onCancel(arguments: Any?) {
        contentObserver?.let { context.contentResolver.unregisterContentObserver(it) }
        contentObserver = null
    }

    private fun handleChange(resolver: ContentResolver, events: EventChannel.EventSink) {
        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.DATE_ADDED,
        )

        queryLatestImage(resolver, projection)?.use { cursor ->
            if (!cursor.moveToFirst()) return

            val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID))
            if (id == lastHandledId) return

            val displayName = cursor.getString(
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME),
            ) ?: ""
            val dateAddedSec = cursor.getLong(
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED),
            )

            val isRecent = (System.currentTimeMillis() / 1000) - dateAddedSec <= RECENT_WINDOW_SEC
            val looksLikeScreenshot = displayName.lowercase().contains("screenshot")
            if (!isRecent || !looksLikeScreenshot) return

            val sourceUri = Uri.withAppendedPath(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id.toString())
            val cachedPath = copyToCache(resolver, sourceUri, displayName) ?: return
            // Chỉ đánh dấu đã xử lý khi copy thành công: ảnh còn đang được ghi
            // (IS_PENDING) sẽ được thử lại ở lần onChange kế tiếp.
            lastHandledId = id

            val fromBackground = !isInForeground()
            Handler(Looper.getMainLooper()).post {
                events.success(mapOf("path" to cachedPath, "fromBackground" to fromBackground))
            }
        }
    }

    /**
     * Lấy ảnh mới nhất trong MediaStore. Android 11+ từ chối `LIMIT` đặt trong
     * sortOrder (IllegalArgumentException) nên phải dùng Bundle query args.
     */
    private fun queryLatestImage(resolver: ContentResolver, projection: Array<String>): Cursor? {
        val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val args = Bundle().apply {
                putStringArray(
                    ContentResolver.QUERY_ARG_SORT_COLUMNS,
                    arrayOf(MediaStore.Images.Media.DATE_ADDED),
                )
                putInt(
                    ContentResolver.QUERY_ARG_SORT_DIRECTION,
                    ContentResolver.QUERY_SORT_DIRECTION_DESCENDING,
                )
                putInt(ContentResolver.QUERY_ARG_LIMIT, 1)
            }
            return resolver.query(uri, projection, args, null)
        }
        return resolver.query(
            uri,
            projection,
            null,
            null,
            "${MediaStore.Images.Media.DATE_ADDED} DESC LIMIT 1",
        )
    }

    private fun copyToCache(resolver: ContentResolver, uri: Uri, displayName: String): String? {
        return try {
            val dir = File(context.cacheDir, "screenshots").apply { mkdirs() }
            val outFile = File(dir, "${System.currentTimeMillis()}_$displayName")
            resolver.openInputStream(uri)?.use { input ->
                FileOutputStream(outFile).use { output -> input.copyTo(output) }
            }
            outFile.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    companion object {
        private const val TAG = "ScreenshotStream"
        private const val RECENT_WINDOW_SEC = 10L
    }
}
