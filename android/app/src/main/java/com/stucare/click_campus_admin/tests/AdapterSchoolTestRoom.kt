package com.stucare.click_campus_admin.tests

import android.app.Fragment
import android.app.FragmentManager
import android.os.Bundle
import android.view.View
import androidx.databinding.DataBindingUtil
import androidx.legacy.app.FragmentStatePagerAdapter
import com.stucare.click_campus_admin.model.ModelTestQuestion
import com.stucare.cloud_admin.R
import com.stucare.cloud_admin.databinding.CustomTabViewBinding


class AdapterSchoolTestRoom(fragmentManager: FragmentManager, val context: ActivityObjectiveTestRoom, val mData: MutableList<ModelTestQuestion>) : FragmentStatePagerAdapter(fragmentManager) {

  override fun getItem(position: Int): Fragment {
    val bundle = Bundle()
    bundle.putSerializable("data", mData[position])

    val fragment = FragmentSchoolTestRoom()
    fragment.arguments = bundle

    return fragment
  }

  override fun getCount(): Int {
    return mData.size
  }

  override fun getPageTitle(position: Int): CharSequence {
    return (position + 1).toString()
  }

  fun getTabView(position: Int): View {
    val view = DataBindingUtil.inflate<CustomTabViewBinding>(context.layoutInflater,
        R.layout.custom_tab_view, null, false)
    view.txtView.text = (position + 1).toString()
    view.imageView.visibility = View.GONE
    return view.root
  }
}
