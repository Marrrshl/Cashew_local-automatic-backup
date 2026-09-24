package com.budget.cashewfork

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.budget.cashewfork/storage"
    private val REQUEST_CODE_PICK_DIRECTORY = 9988
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "checkStoragePermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        result.success(Environment.isExternalStorageManager())
                    } else {
                        result.success(true)
                    }
                }
                "requestStoragePermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        try {
                            val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                            intent.data = Uri.parse("package:" + applicationContext.packageName)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                            startActivity(intent)
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }
                "pickDirectory" -> {
                    if (pendingResult != null) {
                        result.error("BUSY", "Directory picker is already active", null)
                        return@setMethodCallHandler
                    }
                    pendingResult = result
                    try {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                        intent.addFlags(
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                            Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                            Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                        )
                        startActivityForResult(intent, REQUEST_CODE_PICK_DIRECTORY)
                    } catch (e: Exception) {
                        pendingResult?.error("ERROR", e.message, null)
                        pendingResult = null
                    }
                }
                "checkBackupFileExists" -> {
                    val treeUriString = call.argument<String>("treeUri")
                    val fileName = call.argument<String>("fileName") ?: "cashew-latest.sql"
                    if (treeUriString.isNullOrEmpty()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    try {
                        val treeUri = Uri.parse(treeUriString)
                        val docDir = DocumentFile.fromTreeUri(applicationContext, treeUri)
                        val file = docDir?.findFile(fileName)
                        result.success(file != null && file.exists())
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "readBackupFile" -> {
                    val treeUriString = call.argument<String>("treeUri")
                    val fileName = call.argument<String>("fileName") ?: "cashew-latest.sql"
                    if (treeUriString.isNullOrEmpty()) {
                        result.error("INVALID_ARG", "treeUri is null", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val treeUri = Uri.parse(treeUriString)
                        val docDir = DocumentFile.fromTreeUri(applicationContext, treeUri)
                        val fileDoc = docDir?.findFile(fileName)
                        if (fileDoc != null && fileDoc.exists()) {
                            val inputStream = contentResolver.openInputStream(fileDoc.uri)
                            val bytes = inputStream?.readBytes()
                            inputStream?.close()
                            if (bytes != null) {
                                result.success(bytes)
                            } else {
                                result.error("READ_FAILED", "Empty or null bytes read", null)
                            }
                        } else {
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        result.error("READ_ERROR", e.message, null)
                    }
                }
                "writeBackupAndRotate" -> {
                    val treeUriString = call.argument<String>("treeUri")
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName") ?: "cashew-latest.sql"
                    val retentionCount = call.argument<Int>("retentionCount") ?: 10

                    if (treeUriString.isNullOrEmpty() || bytes == null) {
                        result.error("INVALID_ARG", "treeUri or bytes is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val treeUri = Uri.parse(treeUriString)
                        val docDir = DocumentFile.fromTreeUri(applicationContext, treeUri)
                        if (docDir == null || !docDir.exists() || !docDir.canWrite()) {
                            result.error("PERMISSION_ERROR", "Cannot write to backup folder", null)
                            return@setMethodCallHandler
                        }

                        val dateFormat = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US)
                        val timestampStr = dateFormat.format(Date())
                        val existingLatest = docDir.findFile(fileName)

                        // Step 1: If cashew-latest.sql exists, create a rotated snapshot copy
                        if (existingLatest != null && existingLatest.exists()) {
                            val rotatedFile = docDir.createFile("application/octet-stream", "cashew-backup-$timestampStr.sql")
                            if (rotatedFile != null) {
                                val rotatedOut = contentResolver.openOutputStream(rotatedFile.uri, "w")
                                if (rotatedOut != null) {
                                    val inStream = contentResolver.openInputStream(existingLatest.uri)
                                    inStream?.use { input ->
                                        rotatedOut.use { output ->
                                            input.copyTo(output)
                                        }
                                    }
                                }
                            }
                        }

                        // Step 2: Write fresh bytes into cashew-latest.sql directly (in-place)
                        var targetFile = existingLatest
                        if (targetFile == null || !targetFile.exists()) {
                            targetFile = docDir.createFile("application/octet-stream", fileName)
                        }
                        if (targetFile == null) {
                            result.error("CREATE_FAILED", "Failed to create backup file", null)
                            return@setMethodCallHandler
                        }

                        val outputStream = contentResolver.openOutputStream(targetFile.uri, "rwt")
                            ?: contentResolver.openOutputStream(targetFile.uri, "w")
                        if (outputStream == null) {
                            result.error("WRITE_FAILED", "Cannot open output stream", null)
                            return@setMethodCallHandler
                        }
                        outputStream.use { out ->
                            out.write(bytes)
                            out.flush()
                        }

                        // Step 3: Check rotated cashew-backup-*.sql files and delete oldest excess
                        val children = docDir.listFiles()
                        val backupFiles = children.filter {
                            val name = it.name ?: ""
                            name.startsWith("cashew-backup-") && name.endsWith(".sql")
                        }.sortedBy { it.name ?: "" }

                        if (backupFiles.size > retentionCount) {
                            val numToDelete = backupFiles.size - retentionCount
                            for (i in 0 until numToDelete) {
                                try {
                                    backupFiles[i].delete()
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                }
                            }
                        }

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("BACKUP_ERROR", e.message, null)
                    }
                }
                "releasePersistedUriPermission" -> {
                    val treeUriString = call.argument<String>("treeUri")
                    if (!treeUriString.isNullOrEmpty()) {
                        try {
                            val treeUri = Uri.parse(treeUriString)
                            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                            contentResolver.releasePersistableUriPermission(treeUri, flags)
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_PICK_DIRECTORY) {
            val res = pendingResult
            pendingResult = null
            if (resultCode == RESULT_OK && data?.data != null) {
                val treeUri = data.data!!
                val takeFlags: Int = data.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                try {
                    contentResolver.takePersistableUriPermission(treeUri, takeFlags)
                } catch (e: Exception) {
                    try {
                        contentResolver.takePersistableUriPermission(
                            treeUri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                        )
                    } catch (e2: Exception) {
                        e2.printStackTrace()
                    }
                }
                res?.success(treeUri.toString())
            } else {
                res?.success(null)
            }
        }
    }
}
