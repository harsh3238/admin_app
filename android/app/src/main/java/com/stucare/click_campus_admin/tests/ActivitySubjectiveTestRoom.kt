package com.stucare.click_campus_admin.tests

import android.app.ProgressDialog
import android.content.Intent
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.squareup.picasso.Picasso
import com.stucare.click_campus_admin.api.NetworkClient
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.ActivitySubjectiveTestBinding
import okhttp3.ResponseBody
import org.json.JSONException
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.File
import java.io.FileOutputStream

class ActivitySubjectiveTestRoom : AppCompatActivity() {

    private lateinit var mContentView: ActivitySubjectiveTestBinding
    private lateinit var progressBar: ProgressDialog
    private val SUBMISSION_REQUEST_CODE = 155


    private lateinit var mAdapter: AppCommonRvAdapter<String>
    private var mUserId: String = ""



    override fun onCreate(savedInstanceState: Bundle?) {
        window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
        )
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        super.onCreate(savedInstanceState)
        mContentView = DataBindingUtil.setContentView(this, R.layout.activity_subjective_test)

        supportActionBar?.setTitle("Subjective Test Preview");
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)

        mUserId = intent.getStringExtra("user_id") ?: ""

        progressBar = ProgressDialog(this)
        progressBar.setCancelable(false)
        progressBar.isIndeterminate = true
        progressBar.setMessage("Please wait...")

        getQuestionPaper()
    }


    private fun loadImageQuestionPaper(imageUrl: String){
        if(imageUrl.startsWith("http")){
            Picasso.get().load(imageUrl).into(mContentView.ivQuestionPaper)
        }else{
            val f = File(imageUrl)
            Picasso.get().load(f).fit().centerInside().into(mContentView.ivQuestionPaper)
        }
    }

    private fun loadPDFQuestionPaper(filePath: String) {

        /*mContentView.pdfView.getSettings().setJavaScriptEnabled(true)
        mContentView.pdfView.loadUrl("https://drive.google.com/viewerng/viewer?embedded=true&url=$filePath")*/

        mContentView.pdfView.fromFile(File(filePath))
            .defaultPage(0)
            .enableAnnotationRendering(true)
            .spacing(10)
            .load()
    }

    private fun getQuestionPaper() {
        progressBar.show()

        val call = NetworkClient.create().getSubjectiveTest(
                intent.getStringExtra("test_id"),
                intent.getStringExtra("accessToken")
        )
        call.enqueue(object : Callback<String> {

            override fun onResponse(call: Call<String>?, response: Response<String>?) {
                response?.let {
                    
                    if (response.isSuccessful) {
                        var responseString = response.body().toString()
                        
                        var jsonObject = JSONObject()
                        try {
                            jsonObject = JSONObject(response.body().toString())
                        } catch (e: JSONException) {
                            Toast.makeText(this@ActivitySubjectiveTestRoom,
                                    "Invalid response from server", Toast.LENGTH_LONG).show()
                            return;
                        }
                        //val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject.has("status") && jsonObject.getString("status") == "success") {
                            val jsonArray = jsonObject.getJSONObject("data")
                            if (jsonArray.getString("media_type") == "image") {
                                val fileUrl = jsonArray.getString("file_url")

                                mContentView.ivQuestionPaper.visibility = View.VISIBLE;
                                mContentView.pdfView.visibility = View.GONE;

                                loadImageQuestionPaper(fileUrl)

                                /*val d = DialogPhotoViewer(
                                    this@ActivitySubjectiveTestRoom,
                                    R.style.Theme_AppCompat_NoActionBar,
                                    jsonArray.getString("file_url")
                                )
                                d.show()*/
                                progressBar.dismiss()
                            } else if (jsonArray.getString("media_type") == "pdf") {

                                mContentView.ivQuestionPaper.visibility = View.GONE;
                                mContentView.pdfView.visibility = View.VISIBLE;

                                val fileUrl = jsonArray.getString("file_url")
                                val fileName = fileUrl.substring(fileUrl.lastIndexOf('/') + 1, fileUrl.length)
                                val imageCacheDir = File(cacheDir.absolutePath + "/" + fileName)

                                if (imageCacheDir.exists()) {
                                    /* val intent = Intent(
                                        this@ActivitySubjectiveTestRoom,
                                        PDFViewActivity::class.java
                                    )
                                    intent.putExtra("file", imageCacheDir.absolutePath)
                                    intent.putExtra("hash", "")
                                    startActivity(intent) */

                                    loadPDFQuestionPaper(imageCacheDir.absolutePath)
                                    //loadPDFQuestionPaper(fileUrl)
                                    progressBar.dismiss()
                                    return@let
                                } 
                                
                                val downloadCall = NetworkClient.create().downloadFile(fileUrl)
                                downloadCall.enqueue(object : Callback<ResponseBody?> {
                                    override fun onFailure(
                                            call: Call<ResponseBody?>,
                                            t: Throwable
                                    ) {
                                        Toast.makeText(
                                                this@ActivitySubjectiveTestRoom,
                                                "Download failed",
                                                Toast.LENGTH_SHORT
                                        )
                                                .show()
                                    }

                                    override fun onResponse(
                                            call: Call<ResponseBody?>,
                                            response: Response<ResponseBody?>
                                    ) {
                                        if (response.isSuccessful) {
                                            val imageCacheDir =
                                                    File(cacheDir.absolutePath + "/" + fileName)
                                            if (imageCacheDir.exists()) {
                                                imageCacheDir.delete()
                                            }

                                            val input = response.body()?.byteStream()
                                            val fileOutputStream = FileOutputStream(imageCacheDir)
                                            input?.copyTo(fileOutputStream)

                                            /* val intent = Intent(
                                                this@ActivitySubjectiveTestRoom,
                                                PDFViewActivity::class.java
                                            )
                                            intent.putExtra("file", imageCacheDir.absolutePath)
                                            intent.putExtra("hash", "")
                                            startActivity(intent)*/
                                            loadPDFQuestionPaper(imageCacheDir.absolutePath)
                                            progressBar.dismiss()
                                        }
                                    }
                                })
                            }
                        } else {
                            Toast.makeText(
                                    this@ActivitySubjectiveTestRoom,
                                    "Unable to  load Question Paper, Please contact school...",
                                    Toast.LENGTH_SHORT
                            ).show()
                            progressBar.dismiss()
                        }

                    } else {
                        progressBar.dismiss()
                    }
                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressBar.dismiss()
                Toast.makeText(
                        this@ActivitySubjectiveTestRoom,
                        "There has been error, Please try again...",
                        Toast.LENGTH_SHORT
                ).show()
            }


        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(requestCode == SUBMISSION_REQUEST_CODE && resultCode == RESULT_OK){
            var finishStatus: String =  data!!.getStringExtra("finish_status")
            if(finishStatus=="0"){
                finish()
            }

        }
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
