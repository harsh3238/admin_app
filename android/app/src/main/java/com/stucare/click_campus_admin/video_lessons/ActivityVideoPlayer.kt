package com.stucare.click_campus_admin.video_lessons

import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.YouTubePlayer
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.listeners.AbstractYouTubePlayerListener
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.views.YouTubePlayerView
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.VideoPlayerBinding
import org.json.JSONArray


/**
 * Author: Ashish Walia(ashishwalia.me) on 06-11-2017.
 */

class ActivityVideoPlayer : AppCompatActivity() {

    var videoName = ""
    var videoId = ""
    var topicName = ""
    var topicId = ""
    private  var video_index: Int = 0
    private lateinit var videoList: JSONArray
    lateinit var contentView: VideoPlayerBinding
    lateinit var ytPlayer: YouTubePlayer
    private var isViewLayoutDone = false
    private lateinit var bottomSheetBehavior: BottomSheetBehavior<*>

    private var shouldCleanWhenFinishes = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        title = "Video Preview"
        contentView = DataBindingUtil.setContentView(this, R.layout.video_player)
        contentView.controller = this

        videoList = JSONArray(intent.getStringExtra("data"))
        video_index = intent.getIntExtra("position", 0)
        val data = videoList.getJSONObject(video_index)
        videoName = data.getString("video_name")
        videoId = data.getString("link")
        topicName = data.optString("chapter_name")
        topicId = data.optString("chapter_id")



        initViews()
        //setUpListenersForPlayer()
        //initYoutubePlayer()
        initCustomYoutubePlayer()


    }

    private fun initViews() {
        /**
         * Setting the Video data we already received in
         * the Intent
         */
        contentView.textViewVideoName.text = videoName
        contentView.textViewTopicName.text = topicName
        contentView.textViewTopicNameBottomSheet.text = topicName

        /**
         * Here we set the BottomSheet's height to be exactly
         * the same as the device's screen LEFT AFTER INFLATING the PLAYER
         * so when it's expanded, its top aligns with player's bottom
         */

        val viewTreeObserver = contentView.youtubePlayerView.viewTreeObserver
        viewTreeObserver.addOnGlobalLayoutListener(ViewTreeObserver.OnGlobalLayoutListener {
            if (isViewLayoutDone) return@OnGlobalLayoutListener
            val content: FrameLayout = window.findViewById(android.R.id.content)

            val lp = androidx.coordinatorlayout.widget.CoordinatorLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX,
                            (content.height - contentView.youtubePlayerView.height).toFloat()-120F,
                            resources.displayMetrics).toInt())

            lp.behavior = BottomSheetBehavior<LinearLayout>()
            contentView.bottomSheet.layoutParams = lp
            bottomSheetBehavior = BottomSheetBehavior.from<LinearLayout>(contentView.bottomSheet)
            bottomSheetBehavior.isHideable = false
            bottomSheetBehavior.peekHeight = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                    60f, resources.displayMetrics).toInt()

            bottomSheetBehavior.setBottomSheetCallback(object : BottomSheetBehavior.BottomSheetCallback() {
                override fun onStateChanged(bottomSheet: View, newState: Int) {

                }

                override fun onSlide(bottomSheet: View, slideOffset: Float) {

                    contentView.dropDownArrow.rotation = 180 * slideOffset

                }
            })

            isViewLayoutDone = true
        })


        contentView.btmVisibleBit.setOnClickListener {
            if (bottomSheetBehavior.state == BottomSheetBehavior.STATE_EXPANDED)
                bottomSheetBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED)
            else
                bottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED)
        }


        contentView.btmRecyclerView.layoutManager = androidx.recyclerview.widget.LinearLayoutManager(this)
        contentView.btmRecyclerView.adapter = AdapterVideoPlayerPlaylist(this, videoList)

    }


    private fun initCustomYoutubePlayer() {
        val youTubePlayerView: YouTubePlayerView = findViewById(R.id.youtube_player_view)
        getLifecycle().addObserver(youTubePlayerView)

        youTubePlayerView.addYouTubePlayerListener(object : AbstractYouTubePlayerListener() {
            override fun onReady(youTubePlayer: com.pierfrancescosoffritti.androidyoutubeplayer.core.player.YouTubePlayer) {
                super.onReady(youTubePlayer)
                ytPlayer = youTubePlayer
                youTubePlayer.loadVideo(videoId, 0F)

            }
        })

    }
}
