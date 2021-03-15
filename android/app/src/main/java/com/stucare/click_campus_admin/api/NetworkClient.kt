package com.stucare.click_campus_admin.api;

import okhttp3.OkHttpClient
import okhttp3.RequestBody
import okhttp3.ResponseBody
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.http.*
import java.util.concurrent.TimeUnit


interface NetworkClient {

    @FormUrlEncoded
    @POST("api_v2/student/requests/get_live_classes.php")
    fun getLiveClasses(
        @Field("school_id") userId: Int,
        @Field("stucare_id") stucareId: Int,
        @Field("active_session") accessToken: String,
        @Field("upcoming") upcoming: String = ""
    ): Call<String>

    @FormUrlEncoded
    @POST("api_v2/admin/requests/get_tests_t.php")
    fun getSchoolTests(
        @Field("user_id") userId: String,
        @Field("class_id") classId: String,
        @Field("active_session") sessionToken: String
    ): Call<String>

    @FormUrlEncoded
    @POST("api_v2/teacher/requests/get_test_questions.php")
    fun getObjectiveTestQuestions(@Field("test_id") testId: String,
                                  @Field("active_session") accessToken: String): Call<String>

    @FormUrlEncoded
    @POST("api_v2/teacher/requests/get_subjective_question_paper.php")
    fun getSubjectiveTest(@Field("test_id") testId: String,
                          @Field("active_session") accessToken: String): Call<String>

    @FormUrlEncoded
    @POST("api_v2/admin/requests/get_all_classes.php")
    fun getAllClass(
            @Field("active_session") sessionToken: String
    ): Call<String>

    @FormUrlEncoded
    @POST("api_v2/teacher/requests/get_subject_for_class.php")
    fun getSubjectForClass(
            @Field("active_session") sessionToken: String,
            @Field("class_id") classId: String
    ): Call<String>

    @FormUrlEncoded
    @POST("api_v2/teacher/requests/get_video_chapters.php")
    fun getVideoChapters(
            @Field("subject_id") subjectId: String,
            @Field("active_session") accessToken: String
    ): Call<String>


    @FormUrlEncoded
    @POST("api_v2/teacher/requests/get_video_lessons.php")
    fun getVideoLessons(
            @Field("active_session") accessToken: String,
            @Field("chapter_id") subjectId: String
    ): Call<String>


    @GET
    fun downloadFile(@Url url: String): Call<ResponseBody>


    abstract fun getObjectiveTestQuestions(testId: String?): Call<String>

    companion object {
        var baseUrl: String = ""

        fun create(): NetworkClient {
            return getRetrofit().create(NetworkClient::class.java)
        }

        private fun getRetrofit(): Retrofit {
            val okHttpBuilder = OkHttpClient.Builder()
            val loggingInterceptor = HttpLoggingInterceptor()
            loggingInterceptor.level = HttpLoggingInterceptor.Level.BODY
            okHttpBuilder.addInterceptor(loggingInterceptor)
            okHttpBuilder.connectTimeout(60, TimeUnit.SECONDS)
            okHttpBuilder.writeTimeout(60, TimeUnit.SECONDS)
            okHttpBuilder.readTimeout(60, TimeUnit.SECONDS)


            return Retrofit.Builder()
                .baseUrl(baseUrl)
                .addConverterFactory(ToStringConverterFactory())
                .client(okHttpBuilder.build()).build()
        }
    }

}