package com.stucare.click_campus_admin.tests
import android.app.ProgressDialog
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.stucare.click_campus_admin.api.NetworkClient
import com.stucare.click_campus_teacher.model.SpinnerModel
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.ActivitySchoolTestsBinding
import org.json.JSONException
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class FrgSchoolTests : Fragment() {

    private lateinit var progressBar: ProgressDialog
    lateinit var contentView: ActivitySchoolTestsBinding
    private lateinit var classList: ArrayList<SpinnerModel>

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        contentView =
            DataBindingUtil.inflate(inflater, R.layout.activity_school_tests, container, false)
        contentView.recyclerView.layoutManager = LinearLayoutManager(activity)

        progressBar = ProgressDialog(activity)
        progressBar.setCancelable(false)
        progressBar.isIndeterminate = true
        progressBar.setMessage("Please wait...")


        return contentView.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        contentView.spClass?.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {

            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
               // if(position>0){
                    getSchoolTests(classList[position].id)
               // }

            }

        }

    }
    override fun onResume() {
        super.onResume()
            getAllClass()
    }

    private fun getSchoolTests(classId: String) {
        progressBar.show()
        val parentActivity = activity as OnlineTestsActivity
        val call = NetworkClient.create().getSchoolTests(
            parentActivity.stucareId!!,
                classId!!,
                parentActivity.accessToken!!
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
                            Toast.makeText(activity,
                                    "Invalid response from server", Toast.LENGTH_LONG).show()
                            //this is work around to handle situation when response contain 
                            // raw html string along with json
                            jsonObject = JSONObject(responseString.substring(responseString.indexOf("{"), responseString.lastIndexOf("}") + 1))
                        }

                        //val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject!= null && jsonObject.has("status") &&
                            jsonObject.getString("status") == "success") {
                            val jsonArray = jsonObject.getJSONArray("data")
                            if(jsonArray!=null && jsonArray.length()==0){
                                Toast.makeText(
                                        activity!!,
                                        "No Data Available",
                                        Toast.LENGTH_SHORT
                                ).show()
                            }
                            contentView.recyclerView.adapter = AdapterSchoolTestsMain(
                                activity!!,
                                jsonArray,
                                parentActivity.stucareId!!,
                                parentActivity.accessToken!!
                            )
                        }else{
                            Toast.makeText(
                                activity!!,
                                "Invalid error from server, please try again",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                    progressBar.dismiss()
                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressBar.dismiss()
                Toast.makeText(
                    activity!!,
                    "There has been error, please try again",
                    Toast.LENGTH_SHORT
                ).show()
            }


        })
    }


    private fun getAllClass() {
        progressBar.show()
        val parentActivity = activity as OnlineTestsActivity
        val call = NetworkClient.create().getAllClass(
                parentActivity.accessToken!!
        )
        call.enqueue(object : Callback<String> {

            override fun onResponse(call: Call<String>?, response: Response<String>?) {
                response?.let {
                    if (response.isSuccessful) {
                        val responseString = response.body().toString();
                        if(responseString=="auth error"){
                            Toast.makeText(requireContext(), "Authentication Error", Toast.LENGTH_SHORT).show()
                            return
                        }
                        val jsonObject = JSONObject(response.body().toString())
                        if (jsonObject!= null && jsonObject.has("status") &&
                                jsonObject.getString("status") == "success") {
                            val jsonArray = jsonObject.getJSONArray("data")
                            if(jsonArray!=null && jsonArray.length()==0){
                                Toast.makeText(
                                        activity!!,
                                        "No Data Available",
                                        Toast.LENGTH_SHORT
                                ).show()
                                return
                            }

                            classList = ArrayList();
                            //classList.add(ClassModel("*** Select Class ***", "0"))
                            for (i in 0 until jsonArray.length()) {
                                val data = jsonArray.getJSONObject(i)
                                 val name= data.getString("class_name")
                                 val id= data.getString("id")
                                classList.add(SpinnerModel(name, id));
                                
                            }
                            val customDropDownAdapter = CustomDropDownAdapter(activity!!, classList)
                            contentView.spClass.adapter = customDropDownAdapter

                        }else{
                            Toast.makeText(
                                    activity!!,
                                    "Invalid error from server, please try again",
                                    Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                    progressBar.dismiss()
                }
            }

            override fun onFailure(call: Call<String>?, t: Throwable?) {
                progressBar.dismiss()
                Toast.makeText(
                        activity!!,
                        "There has been error, please try again",
                        Toast.LENGTH_SHORT
                ).show()
            }


        })
    }

}