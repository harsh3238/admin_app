package com.stucare.click_campus_admin

import android.content.Intent
import android.util.Log
import com.stucare.click_campus_admin.api.NetworkClient
import com.stucare.click_campus_admin.tests.OnlineTestsActivity
import com.stucare.click_campus_admin.video_lessons.ActivityVideoLessons
import com.stucare.click_campus_admin.zoom.InitAuthSDKCallback
import com.stucare.click_campus_teacher.zoom.InitAuthSDKHelper
import com.stucare.click_campus_teacher.zoom.UserLoginCallback
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import us.zoom.sdk.*
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity(), InitAuthSDKCallback, UserLoginCallback.ZoomDemoAuthenticationListener, PreMeetingServiceListener {

    private val METHOD_CHANNEL_NAME = "com.stucare.cloud_admin.default_channel"
    private var SHARED_PREFS = "FlutterSharedPreferences"
    private var userName: String? = null
    private var password: String? = null
    private var methodChannelResult: MethodChannel.Result? = null
    val inDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        InitAuthSDKHelper.instance?.initSDK(this, this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result? ->
                    methodChannelResult = result
                    when (call.method) {
                        "initZoom" -> {
                            userName = call.argument<String>("zoom_id")
                            password = call.argument<String>("zoom_pass")
                            initZoom()
                        }
                        "schedule_class" -> {
                            scheduleMeeting(call.argument<String>("topic")!!, call.argument<String>("date")!!,
                                    call.argument<String>("time")!!, call.argument<String>("password")!!,
                                    call.argument<String>("duration")!!)
                        }

                        "start_class" -> {
                            startMeeting(call.argument<String>("meetingId")!!)
                        }

                        "join_class" -> {
                            joinMeeting(call.argument<String>("meetingId")!!, call.argument<String>("password")!!)
                        }

                        "video_lesson_preview" -> {
                            viewVideoLessons(call.argument<String>("userId")!!,
                                    call.argument<String>("sessionToken")!!,
                                    call.argument<String>("schoolId")!!,
                                    call.argument<String>("schoolUrl")!!)
                        }

                        "test_preview" -> {
                            testPreview(call.argument<String>("userId")!!,
                                    call.argument<String>("sessionToken")!!,
                                    call.argument<String>("schoolUrl")!!
                            )
                        }
                    }
                }
    }

    private fun viewVideoLessons(userId: String, sessionToken: String, schoolId: String, schoolUrl: String) {
        NetworkClient.baseUrl = schoolUrl

        Log.d("Mainactivity-USER_ID", userId)
        Log.d("Mainactivity-TOKEN", sessionToken)
        Log.d("Mainactivity-URL", schoolUrl)

        val i = Intent(this, ActivityVideoLessons::class.java)
        i.putExtra("stucareId", userId)
        i.putExtra("sessionToken", sessionToken)
        i.putExtra("schoolId", schoolId)
        i.putExtra("baseUrl", schoolUrl)
        startActivity(i)
    }


    private fun testPreview(userId: String, sessionToken: String, schoolUrl: String) {
        NetworkClient.baseUrl = schoolUrl

        Log.d("URL", schoolUrl)
        Log.d("USER_ID", userId)
        Log.d("TOKEN", sessionToken)

        val i = Intent(this, OnlineTestsActivity::class.java)
        i.putExtra("stucareId", userId)
        i.putExtra("sessionToken", sessionToken)
        startActivity(i)
    }


    private fun initZoom() {
        if (ZoomSDK.getInstance().isInitialized) {
            zoomLoginUser()
        } else {
            InitAuthSDKHelper.instance?.initSDK(this, this)
        }
    }

    private fun zoomLoginUser() {
        if (ZoomSDK.getInstance().tryAutoLoginZoom() == ZoomApiError.ZOOM_API_ERROR_SUCCESS) {
            UserLoginCallback.instance?.addListener(this)
        } else {
            if (userName != null && password != null) {
                ZoomSDK.getInstance().loginWithZoom(userName, password)
                UserLoginCallback.instance?.addListener(this)
            }
        }
    }

    override fun onZoomSDKInitializeResult(p0: Int, p1: Int) {
        if (p0 == ZoomError.ZOOM_ERROR_SUCCESS && userName != null && password != null) {
            zoomLoginUser()
        }
    }

    override fun onZoomAuthIdentityExpired() {

    }

    override fun onZoomSDKLoginResult(result: Long) {
        Log.d(this.javaClass.simpleName, "ZOOM = onZoomSDKLoginResult = $result")
    }

    override fun onZoomIdentityExpired() {
    }

    override fun onZoomSDKLogoutResult(result: Long) {

    }

    private fun scheduleMeeting(topic: String, date: String, time: String, password: String, duration: String) {
        val mPreMeetingService = ZoomSDK.getInstance().preMeetingService

        val startDate = inDateFormat.parse("$date $time")
        val meetingItem = mPreMeetingService!!.createScheduleMeetingItem()

        meetingItem.meetingTopic = topic
        meetingItem.startTime = startDate.time
        meetingItem.durationInMinutes = duration.toInt()
        meetingItem.canJoinBeforeHost = false
        meetingItem.password = password
        meetingItem.isHostVideoOff = true
        meetingItem.isAttendeeVideoOff = true


        meetingItem.isEnableMeetingToPublic = false
        meetingItem.isEnableLanguageInterpretation = false
        meetingItem.isEnableWaitingRoom = false
        meetingItem.audioType = MeetingItem.AudioType.AUDIO_TYPE_VOIP
        meetingItem.isOnlySignUserCanJoin = false
        meetingItem.timeZoneId = TimeZone.getDefault().id

        mPreMeetingService.addListener(this)
        val error = mPreMeetingService.scheduleMeeting(meetingItem)
    }

    private fun startMeeting(meetingId: String) {
        val opts = getMeetingOptions()
        val params = StartMeetingParams4NormalUser()
        params.meetingNo = meetingId
        ZoomSDK.getInstance().meetingService.startMeetingWithParams(this, params, opts)
        ZoomSDK.getInstance().meetingService.addListener { meetingStatus, errorCode, internalErrorCode ->
            if (meetingStatus == MeetingStatus.MEETING_STATUS_INMEETING) {
                val inMeetingService =
                        ZoomSDK.getInstance().inMeetingService
                inMeetingService.inMeetingShareController.lockShare(true)
                inMeetingService.inMeetingAudioController.setMuteOnEntry(
                        false
                )

                inMeetingService.inMeetingChatController.allowAttendeeChat(
                        InMeetingChatController.MobileRTCWebinarChatPriviledge.No_One
                )
                inMeetingService.inMeetingChatController.changeAttendeeChatPriviledge(
                        InMeetingChatController.MobileRTCMeetingChatPriviledge.No_One
                )
            }
        }
    }

    private fun joinMeeting(meetingId: String, password: String) {
        val opts = getJoinMeetingOptions()
        val params = JoinMeetingParams()

        params.displayName = "Admin"
        params.meetingNo = meetingId
        params.password = password
        ZoomSDK.getInstance().meetingService.joinMeetingWithParams(this, params, opts)
    }

    fun getMeetingOptions(): StartMeetingOptions? {
        val opts = StartMeetingOptions()
        opts.no_driving_mode = true  //for disable zoom meeting ui driving mode
        opts.no_invite = true // for hide invite button on participant view
        opts.no_meeting_end_message =
                true // for disable to show meeting end dialog when meeting is end.
        // opts.no_titlebar = true // for hide title bar on zoom meeting ui
//		opts.no_bottom_toolbar = true; // for hide bottom bar on zoom meeting ui
        opts.no_dial_in_via_phone = true
        opts.no_dial_out_to_phone = true
        opts.no_disconnect_audio = true
        opts.no_share = false
        opts.invite_options = InviteOptions.INVITE_DISABLE_ALL
//		opts.no_audio = true;
//		opts.no_video = true;
        opts.meeting_views_options =
                MeetingViewsOptions.NO_TEXT_MEETING_ID + MeetingViewsOptions.NO_TEXT_PASSWORD
//		opts.no_meeting_error_message = true;
        return opts
    }

    fun getJoinMeetingOptions(): JoinMeetingOptions? {
        val opts = JoinMeetingOptions()

        opts.no_driving_mode = true
        opts.no_invite = true
        opts.no_meeting_end_message = false
        opts.no_titlebar = false
        opts.no_bottom_toolbar = false
        opts.no_dial_in_via_phone = true
        opts.no_dial_out_to_phone = true
        opts.no_disconnect_audio = true
        opts.no_share = true
        opts.invite_options = InviteOptions.INVITE_VIA_EMAIL + InviteOptions.INVITE_VIA_SMS
        opts.no_audio = false
        opts.no_video = true
        opts.meeting_views_options =
                MeetingViewsOptions.NO_BUTTON_SHARE + MeetingViewsOptions.NO_TEXT_MEETING_ID + MeetingViewsOptions.NO_TEXT_PASSWORD
        opts.no_meeting_error_message = true
        return opts
    }

    override fun onUpdateMeeting(p0: Int, p1: Long) {

    }

    override fun onScheduleMeeting(p0: Int, p1: Long) {
        if (p0 == 0) {
            methodChannelResult?.success(p1)
        }
    }

    override fun onListMeeting(p0: Int, p1: MutableList<Long>?) {

    }

    override fun onDeleteMeeting(p0: Int) {

    }
}