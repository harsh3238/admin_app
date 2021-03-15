package com.stucare.click_campus_teacher.zoom

import android.content.Context
import android.util.Log
import com.stucare.click_campus_admin.zoom.AuthConstants
import com.stucare.click_campus_admin.zoom.InitAuthSDKCallback
import us.zoom.sdk.ZoomSDK
import us.zoom.sdk.ZoomSDKInitParams
import us.zoom.sdk.ZoomSDKInitializeListener
import us.zoom.sdk.ZoomSDKRawDataMemoryMode

/**
 * Init and auth zoom sdk first before using SDK interfaces
 */
class InitAuthSDKHelper private constructor() : AuthConstants, ZoomSDKInitializeListener {
    private val mZoomSDK: ZoomSDK
    private var mInitAuthSDKCallback: InitAuthSDKCallback? = null

    /**
     * init sdk method
     */
    fun initSDK(context: Context?, callback: InitAuthSDKCallback?) {
        if (!mZoomSDK.isInitialized) {
            mInitAuthSDKCallback = callback
            val initParams = ZoomSDKInitParams()
            initParams.appKey = AuthConstants.SDK_KEY
            initParams.appSecret = AuthConstants.SDK_SECRET
            initParams.enableLog = true
            initParams.logSize = 50
            initParams.domain = AuthConstants.WEB_DOMAIN
            initParams.videoRawDataMemoryMode = ZoomSDKRawDataMemoryMode.ZoomSDKRawDataMemoryModeStack
            mZoomSDK.initialize(context, this, initParams)
        }
    }

    /**
     * init sdk callback
     *
     * @param errorCode         defined in [us.zoom.sdk.ZoomError]
     * @param internalErrorCode Zoom internal error code
     */
    override fun onZoomSDKInitializeResult(errorCode: Int, internalErrorCode: Int) {
        Log.i(TAG, "onZoomSDKInitializeResult, errorCode=$errorCode, internalErrorCode=$internalErrorCode")
        if (mInitAuthSDKCallback != null) {
            mInitAuthSDKCallback!!.onZoomSDKInitializeResult(errorCode, internalErrorCode)
        }
    }

    override fun onZoomAuthIdentityExpired() {
        Log.e(TAG, "onZoomAuthIdentityExpired in init")
    }

    fun reset() {
        mInitAuthSDKCallback = null
    }

    companion object {
        private const val TAG = "InitAuthSDKHelper"
        private var mInitAuthSDKHelper: InitAuthSDKHelper? = null

        @get:Synchronized
        val instance: InitAuthSDKHelper?
            get() {
                mInitAuthSDKHelper = InitAuthSDKHelper()
                return mInitAuthSDKHelper
            }
    }

    init {
        mZoomSDK = ZoomSDK.getInstance()
    }
}