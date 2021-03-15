package com.stucare.click_campus_admin.video_lessons

import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import com.squareup.picasso.Picasso
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.VideoPlayerPlaylistItemBinding
import org.json.JSONArray

/**
 * Author: Ashish Walia(ashishwalia.me) on 06-11-2017.
 */

class AdapterVideoPlayerPlaylist(
    private val parentActivity: ActivityVideoPlayer,
    val data: JSONArray
) : androidx.recyclerview.widget.RecyclerView.Adapter<AdapterVideoPlayerPlaylist.MyViewHolder>() {


    inner class MyViewHolder(var boundView: VideoPlayerPlaylistItemBinding) :
        androidx.recyclerview.widget.RecyclerView.ViewHolder(boundView.root) {
        fun bindData(position: Int) {
            boundView.serialNumberText.text = (position + 1).toString()

            val data = data.getJSONObject(position)

            boundView.textViewVideoName.text = data.getString("video_name")
            val videoId = data.getString("link")
            Picasso.get().load("https://i1.ytimg.com/vi/$videoId/1.jpg")
                .into(boundView.videoThumbnail)
            itemView.setOnClickListener {
                parentActivity.ytPlayer.cueVideo(videoId,0F)
                parentActivity.contentView.textViewVideoName.text = data.getString("video_name")
                parentActivity.videoId = videoId
            }
        }
    }


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val viewBinding = DataBindingUtil.inflate<VideoPlayerPlaylistItemBinding>(
            parentActivity.layoutInflater,
            R.layout.video_player_playlist_item, parent, false
        )
        return MyViewHolder(viewBinding)
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        holder.bindData(position)
    }

    override fun getItemCount(): Int {
        return data.length()
    }


}
