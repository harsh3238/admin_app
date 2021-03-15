package com.stucare.click_campus_admin.video_lessons

import android.app.ProgressDialog
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.widget.AdapterView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.stucare.click_campus_admin.api.NetworkClient
import com.stucare.click_campus_admin.tests.CustomDropDownAdapter
import com.stucare.click_campus_teacher.model.SpinnerModel
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.TopicHomeBinding
import org.json.JSONArray
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class ActivityVideoLessons : AppCompatActivity() {

    lateinit var contentView: TopicHomeBinding
    private lateinit var progressBar: ProgressDialog
    var chapterId: String? = null

    var schoolId: String? = null
    var stucareId: String? = null
    var accessToken: String? = null
    var schoolUrl: String? = null

    lateinit var selectedClass: SpinnerModel;
    lateinit var selectedSubject: SpinnerModel;
    lateinit var selectedChapter: SpinnerModel;

    private lateinit var classList: ArrayList<SpinnerModel>
    private lateinit var subjectList: ArrayList<SpinnerModel>
    private lateinit var chapterList: ArrayList<SpinnerModel>


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        contentView = DataBindingUtil.setContentView(this, R.layout.topic_home)
        progressBar = ProgressDialog(this)
        progressBar.setCancelable(false)
        progressBar.isIndeterminate = true
        progressBar.setMessage("Please wait...")

        supportActionBar?.setTitle("Video Lessons");
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)

        /*accessToken = intent.getStringExtra("sessionToken")
        chapterId = intent.getStringExtra("chapterId")*/
        schoolId = intent.getStringExtra("schoolId")
        stucareId = intent.getStringExtra("stucareId")
        accessToken = intent.getStringExtra("sessionToken")
        schoolUrl = intent.getStringExtra("baseUrl")

        contentView.recyclerView.layoutManager =
                androidx.recyclerview.widget.LinearLayoutManager(this)

        contentView.spClass?.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {

            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                if (position > 0) {
                    selectedClass = classList[position]
                    getSubjectByClass(classList[position].id)
                }

            }

        }


        contentView.spSubject?.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {

            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                if (position > 0) {
                    selectedSubject = subjectList[position]
                    getChapterBySubject(selectedSubject.id)
                }

            }

        }

        contentView.spChapter?.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {

            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                if (position > 0) {
                    selectedChapter = chapterList[position]
                    getVideos(selectedChapter.id)
                }else{
                    getVideos("")
                }

            }

        }

        //getTopicDetails()
        getAllClass()

    }

    fun showProgressbar() {
        progressBar.show()
    }

    fun hideProgressbar() {
        progressBar.dismiss()
    }

    private fun getVideos(chapterId: String) {

        if(chapterId==""){
            contentView.recyclerView.adapter =
                    AdapterChapter(this@ActivityVideoLessons, JSONArray())
            return
        }
        showProgressbar()
        val call = NetworkClient.create().getVideoLessons(
                accessToken!!, chapterId

        )
        call.enqueue(object : Callback<String> {

            override fun onResponse(call: Call<String>?, response: Response<String>?) {
                response?.let {
                    if (response.isSuccessful) {
                        val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject.has("status") &&
                                jsonObject.getString("status") == "success"
                        ) {
                            val jsonArray = jsonObject.getJSONArray("data")

                            if (jsonArray != null && jsonArray.length() == 0) {
                                Toast.makeText(this@ActivityVideoLessons,
                                        "No Video for this chapter",
                                        Toast.LENGTH_SHORT).show()
                                progressBar.dismiss()

                            }
                            contentView.recyclerView.adapter =
                                    AdapterChapter(this@ActivityVideoLessons, jsonArray)

                        }

                    }
                    progressBar.dismiss()
                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressBar.dismiss()
                Toast.makeText(
                        this@ActivityVideoLessons,
                        "There has been error, please try again",
                        Toast.LENGTH_SHORT
                )
                        .show()
            }

        })

    }

    private fun getAllClass() {
        progressBar.show()
        val call = NetworkClient.create().getAllClass(
                accessToken!!
        )
        call.enqueue(object : Callback<String> {

            override fun onResponse(call: Call<String>?, response: Response<String>?) {
                response?.let {
                    progressBar.dismiss()
                    if (response.isSuccessful) {

                        val responseString = response.body().toString();
                        if (responseString == "auth error") {
                            Toast.makeText(this@ActivityVideoLessons, "Authentication Error", Toast.LENGTH_SHORT).show()
                            return
                        }
                        val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject != null && jsonObject.has("status") &&
                                jsonObject.getString("status") == "success") {
                            val jsonArray = jsonObject.getJSONArray("data")
                            if (jsonArray != null && jsonArray.length() == 0) {
                                Toast.makeText(
                                        this@ActivityVideoLessons,
                                        "No Data Available",
                                        Toast.LENGTH_SHORT
                                ).show()
                            }
                            classList = ArrayList();
                            classList.add(SpinnerModel("*** Select Class ***", "0"))
                            for (i in 0 until jsonArray.length()) {
                                val data = jsonArray.getJSONObject(i)
                                val name = data.getString("class_name")
                                val id = data.getString("id")
                                classList.add(SpinnerModel(name, id));

                            }
                            val customDropDownAdapter = CustomDropDownAdapter(this@ActivityVideoLessons, classList)
                            contentView.spClass.adapter = customDropDownAdapter

                        } else {
                            Toast.makeText(
                                    this@ActivityVideoLessons,
                                    "Invalid error from server, please try again",
                                    Toast.LENGTH_SHORT
                            ).show()
                        }
                    }

                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressBar.dismiss()
                Toast.makeText(
                        this@ActivityVideoLessons,
                        "There has been error, please try again",
                        Toast.LENGTH_SHORT
                ).show()
            }


        })
    }

    private fun getSubjectByClass(class_id: String) {
        progressBar.show()
        val call = NetworkClient.create().getSubjectForClass(
                accessToken!!, class_id
        )
        call.enqueue(object : Callback<String> {

            override fun onResponse(call: Call<String>?, response: Response<String>?) {
                response?.let {
                    progressBar.dismiss()
                    if (response.isSuccessful) {
                        val responseString = response.body().toString();
                        if (responseString == "auth error") {
                            Toast.makeText(this@ActivityVideoLessons, "Authentication Error", Toast.LENGTH_SHORT).show()
                            return
                        }
                        val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject != null && jsonObject.has("status") &&
                                jsonObject.getString("status") == "success") {
                            val jsonArray = jsonObject.getJSONArray("data")
                            if (jsonArray != null && jsonArray.length() == 0) {
                                Toast.makeText(
                                        this@ActivityVideoLessons,
                                        "No Subject Available",
                                        Toast.LENGTH_SHORT
                                ).show()
                            }

                            subjectList = ArrayList();
                            subjectList.add(SpinnerModel("*** Select Subject ***", "0"))
                            for (i in 0 until jsonArray.length()) {
                                val data = jsonArray.getJSONObject(i)
                                val name = data.getString("subject_name")
                                val id = data.getString("id")
                                subjectList.add(SpinnerModel(name, id));

                            }
                            val customDropDownAdapter = CustomDropDownAdapter(this@ActivityVideoLessons, subjectList)
                            contentView.spSubject.adapter = customDropDownAdapter

                        } else {
                            Toast.makeText(
                                    this@ActivityVideoLessons,
                                    "Invalid error from server, please try again",
                                    Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressBar.dismiss()
                Toast.makeText(
                        this@ActivityVideoLessons,
                        "There has been error, please try again",
                        Toast.LENGTH_SHORT
                ).show()
            }


        })
    }

    private fun getChapterBySubject(subject_id: String) {
        progressBar.show()
        val call = NetworkClient.create().getVideoChapters(
                subject_id, accessToken!!
        )
        call.enqueue(object : Callback<String> {

            override fun onResponse(call: Call<String>?, response: Response<String>?) {
                response?.let {
                    progressBar.dismiss()
                    if (response.isSuccessful) {
                        val responseString = response.body().toString();
                        if (responseString == "auth error") {
                            Toast.makeText(this@ActivityVideoLessons, "Authentication Error", Toast.LENGTH_SHORT).show()
                            return
                        }
                        val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject != null && jsonObject.has("status") &&
                                jsonObject.getString("status") == "success") {
                            val jsonArray = jsonObject.getJSONArray("data")
                            if (jsonArray != null && jsonArray.length() == 0) {
                                Toast.makeText(
                                        this@ActivityVideoLessons,
                                        "No Chapter Available",
                                        Toast.LENGTH_SHORT
                                ).show()
                            }

                            chapterList = ArrayList();
                            chapterList.add(SpinnerModel("*** Select Chapter ***", "0"))
                            for (i in 0 until jsonArray.length()) {
                                val data = jsonArray.getJSONObject(i)
                                val name = data.getString("chapter_name")
                                val id = data.getString("id")
                                chapterList.add(SpinnerModel(name, id));

                            }
                            val customDropDownAdapter = CustomDropDownAdapter(this@ActivityVideoLessons, chapterList)
                            contentView.spChapter.adapter = customDropDownAdapter

                        } else {
                            Toast.makeText(
                                    this@ActivityVideoLessons,
                                    "Invalid error from server, please try again",
                                    Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressBar.dismiss()
                Toast.makeText(
                        this@ActivityVideoLessons,
                        "There has been error, please try again",
                        Toast.LENGTH_SHORT
                ).show()
            }


        })
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {

            android.R.id.home -> {
                finish()
                return true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }


}
