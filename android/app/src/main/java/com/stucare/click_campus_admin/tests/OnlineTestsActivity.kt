package com.stucare.click_campus_admin.tests

import android.os.Bundle
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.stucare.cloud_admin.R

class OnlineTestsActivity : AppCompatActivity() {
    //var schoolId: Int? = null
    var stucareId: String? = null
    var accessToken: String? = null
    var classId: String? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.online_test_activity)
        supportActionBar?.setTitle("Available Tests");
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)

        //schoolId = intent.getIntExtra("schoolId", -1)
        stucareId = intent.getStringExtra("stucareId")
        classId = intent.getStringExtra("classId")
        accessToken = intent.getStringExtra("sessionToken")

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