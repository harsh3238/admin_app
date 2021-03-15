package com.stucare.click_campus_teacher.zoom

import us.zoom.sdk.ZoomSDK
import us.zoom.sdk.ZoomSDKAuthenticationListener
import java.util.*

class UserLoginCallback private constructor() : ZoomSDKAuthenticationListener {
    private val mListenerList = ArrayList<ZoomDemoAuthenticationListener>()

    interface ZoomDemoAuthenticationListener {
        fun onZoomSDKLoginResult(result: Long)
        fun onZoomSDKLogoutResult(result: Long)
        fun onZoomIdentityExpired()
        fun onZoomAuthIdentityExpired()
    }

    fun addListener(listener: ZoomDemoAuthenticationListener) {
        if (!mListenerList.contains(listener)) mListenerList.add(listener)
    }

    fun removeListener(listener: ZoomDemoAuthenticationListener) {
        mListenerList.remove(listener)
    }

    /**
     * Called on ZoomSDK login success or failed
     * @param result [ZoomAuthenticationError].ZOOM_AUTH_ERROR_SUCCESS for success
     */
    override fun onZoomSDKLoginResult(result: Long) {
        for (listener in mListenerList) {
            listener?.onZoomSDKLoginResult(result)
        }
    }

    /**
     * Called on ZoomSDK logout success or failed
     * @param result [ZoomAuthenticationError].ZOOM_AUTH_ERROR_SUCCESS for success
     */
    override fun onZoomSDKLogoutResult(result: Long) {
        for (listener in mListenerList) {
            listener?.onZoomSDKLogoutResult(result)
        }
    }

    /**
     * Zoom identity expired, please re-login or generate new zoom access token via REST api
     */
    override fun onZoomIdentityExpired() {
        for (listener in mListenerList) {
            listener?.onZoomIdentityExpired()
        }
    }

    /**
     * ZOOM jwt token is expired, please generate a new jwt token.
     */
    override fun onZoomAuthIdentityExpired() {
        for (listener in mListenerList) {
            listener?.onZoomAuthIdentityExpired()
        }
    }

    companion object {
        private const val TAG = "UserLoginCallback"
        private var mUserLoginCallback: UserLoginCallback? = null

        @get:Synchronized
        val instance: UserLoginCallback?
            get() {
                mUserLoginCallback = UserLoginCallback()
                return mUserLoginCallback
            }
    }

    init {
        ZoomSDK.getInstance().addAuthenticationListener(this)
    }
}