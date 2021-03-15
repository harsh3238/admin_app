package com.stucare.click_campus_admin.tests

import android.app.Activity
import android.app.ProgressDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.PorterDuff
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.ImageView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.vectordrawable.graphics.drawable.VectorDrawableCompat
import com.google.android.material.tabs.TabLayout
import com.otaliastudios.cameraview.controls.Preview
import com.stucare.click_campus_admin.api.NetworkClient
import com.stucare.click_campus_admin.model.ModelTestQuestion
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.ActivityObjectiveTestRoomBinding
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*
import android.util.Log.d as d1


class ActivityObjectiveTestRoom : AppCompatActivity() {

    lateinit var contentView: ActivityObjectiveTestRoomBinding
    private lateinit var progressDialog: ProgressDialog
    private val mQuestionsList = mutableListOf<ModelTestQuestion>()
    private var mLastAnsweredQuestionId = ""

    private lateinit var mUserId: String
   // private lateinit var mSchoolId: String
    private lateinit var accessToken: String


    override fun onCreate(savedInstanceState: Bundle?) {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        super.onCreate(savedInstanceState)
        contentView = DataBindingUtil.setContentView(this, R.layout.activity_objective_test_room)

        supportActionBar?.setTitle("Objective Test Preview");
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)


        progressDialog = ProgressDialog(this)
        progressDialog.setCancelable(false)
        progressDialog.isIndeterminate = true
        progressDialog.setMessage("Please wait...")
        contentView.linearLayout3.visibility = View.GONE
        mUserId = intent.getStringExtra("user_id") ?: ""
        //mSchoolId = intent.getStringExtra("school_id") ?: ""
        accessToken = intent.getStringExtra("accessToken") ?: ""

        if (mUserId.isBlank()) {
            Toast.makeText(
                this,
                "User not initialised, you may need to logout and login again",
                Toast.LENGTH_SHORT
            ).show()
            finish()
        }

        contentView.viewPager.offscreenPageLimit = 4


        getQueries()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 498 && resultCode == Activity.RESULT_OK) {
            val p = data?.getIntExtra("position", -1)
            p?.let {
                if (p != -1) {
                    contentView.viewPager.currentItem = p
                }
            }
            fragmentManager.popBackStack()
        }
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        var valid = true
        for (grantResult in grantResults) {
            valid = valid && grantResult == PackageManager.PERMISSION_GRANTED
        }
        if (!valid) {
            Toast.makeText(this, "Tests require camera permission to work", Toast.LENGTH_SHORT)
                .show()
            finish()
            return
        }

    }

    private fun getQueries() {
        progressDialog.show()


        val call = NetworkClient.create()
            .getObjectiveTestQuestions(intent.getStringExtra("test_id"), accessToken)
        call.enqueue(object : Callback<String> {

            override fun onResponse(call: Call<String>?, response: Response<String>?) {
                response?.let {
                    if (response.isSuccessful) {
                        d1("response", response.body().toString());
                        val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject.has("status") && jsonObject.getString("status") == "success") {
                            val jsonArray = jsonObject.getJSONArray("data")
                            for (i in 0 until jsonArray.length()) {
                                val modelTestQuestion = ModelTestQuestion(false)
                                modelTestQuestion.questionId =
                                    jsonArray.getJSONObject(i).getString("id")
                                modelTestQuestion.question =
                                    jsonArray.getJSONObject(i).getString("question")
                                modelTestQuestion.optionA =
                                    jsonArray.getJSONObject(i).getString("option_a")
                                modelTestQuestion.optionB =
                                    jsonArray.getJSONObject(i).getString("option_b")
                                modelTestQuestion.optionC =
                                    jsonArray.getJSONObject(i).getString("option_c")
                                modelTestQuestion.optionD =
                                    jsonArray.getJSONObject(i).getString("option_d")
                                modelTestQuestion.answer =
                                    jsonArray.getJSONObject(i).getString("answer")

                                modelTestQuestion.marks =
                                    jsonArray.getJSONObject(i).optString("marks")

                                mQuestionsList.add(modelTestQuestion)
                            }
                            if(jsonArray!=null){
                                contentView.tvQuestionCount.text = ""+jsonArray.length();
                            }
                            inItPager(mQuestionsList)
                        }

                    }
                    progressDialog.dismiss()
                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressDialog.dismiss()
                Toast.makeText(
                    this@ActivityObjectiveTestRoom,
                    "There has been error, please try again",
                    Toast.LENGTH_SHORT
                ).show()
            }


        })
    }


    fun inItPager(data: MutableList<ModelTestQuestion>) {
        val adapter = AdapterSchoolTestRoom(fragmentManager, this, data)
        contentView.viewPager.adapter = adapter
        contentView.tabLayout.setupWithViewPager(contentView.viewPager)

        for (i in 0..contentView.tabLayout.tabCount) {
            contentView.tabLayout.getTabAt(i)?.customView = adapter.getTabView(i)
        }


        val v = contentView.tabLayout.getChildAt(0) as ViewGroup


        val yellowD = VectorDrawableCompat.create(resources, R.drawable.c_circle_white, theme)

        yellowD?.setColorFilter(
            ContextCompat.getColor(this, R.color.yellow),
            PorterDuff.Mode.SRC_ATOP
        )



        contentView.tabLayout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabReselected(tab: TabLayout.Tab?) {
                //Just return
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {
                val tabPosition = tab?.position

                if (mQuestionsList[tabPosition!!].userSelectedAnswer != -1) {
                    mQuestionsList[tabPosition].skipped = 0
                    val image =
                        contentView.tabLayout.getTabAt(tabPosition)?.customView?.findViewById<ImageView>(
                            R.id.imageView
                        )
                    image?.setColorFilter(
                        ContextCompat.getColor(
                            this@ActivityObjectiveTestRoom,
                            R.color.zm_green
                        )
                    )
                    image?.visibility = View.VISIBLE
                } else {
                    mQuestionsList[tabPosition].skipped = 1
                    val image =
                        contentView.tabLayout.getTabAt(tabPosition)?.customView?.findViewById<ImageView>(
                            R.id.imageView
                        )
                    image?.setColorFilter(
                        ContextCompat.getColor(
                            this@ActivityObjectiveTestRoom,
                            R.color.yellow
                        )
                    )
                    image?.visibility = View.VISIBLE
                }
            }

            override fun onTabSelected(tab: TabLayout.Tab?) {
                val image = tab?.customView?.findViewById<ImageView>(R.id.imageView)
                image?.visibility = View.INVISIBLE

            }
        })

    }



    fun getQuestionList(): ArrayList<ModelTestQuestion> {
        return mQuestionsList as ArrayList<ModelTestQuestion>
    }


    fun getAttemptedQuesCount(): Int {
        var i = 0
        mQuestionsList.forEach {
            if (it.userSelectedAnswer != -1) {
                i += 1
            }
        }
        return i
    }

    fun getQUestionCount(): Int {
        return mQuestionsList.size
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {

            android.R.id.home ->{
                finish()
                return true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }


}
