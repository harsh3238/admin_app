package com.stucare.click_campus_admin.tests

import android.content.Intent
import android.view.ViewGroup
import android.widget.Toast
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.RecyclerView
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.SchoolTestListItemBinding
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.*


class AdapterSchoolTestsMain(private val parentActivity: FragmentActivity, val mData: JSONArray, val mStucareId: String, val accessToken: String) :
        RecyclerView.Adapter<AdapterSchoolTestsMain.mViewHolder>() {

    val inTimestampFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
    val inTime = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
    val outTime = SimpleDateFormat("hh:mm a", Locale.getDefault())

    inner class mViewHolder(var boundView: SchoolTestListItemBinding) : RecyclerView.ViewHolder(boundView.root) {
        fun bindData(position: Int) {
            val data = mData.getJSONObject(position)
            boundView.txtViewTitle.text = data.getString("test_name")
            boundView.txtViewSubText.text = "${data.getString("start_date")} at ${outTime.format(inTime.parse(data.getString("start_time")))}"
            boundView.tvSection.text = data.optString("class_name")+" ("+data.getString("section_name")+")"

            boundView.cardView.setOnClickListener {

                if (data.getString("test_format") == "objective") {

                }
                if (mStucareId.isNotBlank()) {

                    val intent = if (data.getString("test_format") == "objective")
                        Intent(parentActivity, ActivityObjectiveTestRoom::class.java)
                    else Intent(parentActivity, ActivitySubjectiveTestRoom::class.java)

                    intent.putExtra("test_id", data.getString("id").toString())
                    intent.putExtra("user_id", mStucareId)
                    intent.putExtra("stucareId", mStucareId)
                    intent.putExtra("accessToken", accessToken)
                    parentActivity.startActivity(intent)
                } else {
                    Toast.makeText(parentActivity, "User not initialised, you may need to logout and login again",
                            Toast.LENGTH_SHORT)
                            .show()
                }
            }



        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): mViewHolder {
        val binding = DataBindingUtil.inflate<SchoolTestListItemBinding>(parentActivity.layoutInflater,
                R.layout.school_test_list_item, parent, false)
        return mViewHolder(binding)
    }

    override fun onBindViewHolder(holder: mViewHolder, position: Int) {
        holder.bindData(position)

    }

    override fun getItemCount(): Int {
        return mData.length()
    }
}
