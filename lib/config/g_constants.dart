class GConstants {
  static const String API_VERSION = "api_v2";

  static const _SCHOOL_INFO_ROOT = "https://schools.stucarecloud.in/";
  static const _SCHOOL_INFO_SCHOOL_DATE_ROUTE = API_VERSION+ "/requests/school_info.php";
  static const _SUPER_USER_ROUTE = API_VERSION+ "/requests/login_super_user.php";
  static const _SUPER_USER_OTP_VERIFY = API_VERSION+ "/requests/verify_otp_super_user.php";

  static const _LOGIN_ROUTE = API_VERSION+ "/admin/requests/login.php";
  static const _OTP_VERIFY_ROUTE = API_VERSION+ "/admin/requests/verify_otp.php";
  static const _LOGIN_REPORT_ROUTE = API_VERSION+ "/admin/requests/login_report.php";
  static const _OTP_RESEND_ROUTE = API_VERSION+ "/admin/requests/resend_otp.php";
  static const _VALIDATE_LOGIN_ROUTE = API_VERSION+ "/admin/requests/validate_login_session.php";
  static const _GET_PROFILE = API_VERSION+ "/admin/requests/get_profile.php";
  static const _GET_STUDENT_PROFILE = API_VERSION+ "/student/requests/get_profile.php";
  static const _GET_ACTIVE_MODULES = API_VERSION+ "/admin/requests/get_active_modules.php";
  static const _ADD_REFERENCE_ROUTE = API_VERSION+ "/admin/requests/add_reference.php";
  static const _GET_CLASSES_ROUTE = API_VERSION+ "/admin/requests/get_all_classes.php";
  static const _GET_CLASSES_AND_SECTION_ROUTE = API_VERSION+ "/admin/requests/get_all_classes_sections.php";
  static const _GET_SYLLABUS_ROUTE = API_VERSION+ "/admin/requests/get_syllabus.php";
  static const _GET_SESSIONS_ROUTE = API_VERSION+ "/admin/requests/get_all_sessions.php";
  static const _STU_MSG_ROUTE = API_VERSION+ "/admin/requests/get_messages.php";
  static const _STAFF_MSG_ROUTE = API_VERSION+ "/admin/requests/get_messages_staff.php";
  static const _MESSAGES_ATTACHMENT_ROUTE = API_VERSION+ "/admin/requests/get_message_attaachments.php";
  static const _INBOX_MESSAGES_ROUTE = API_VERSION+ "/admin/requests/get_message_threads.php";
  static const _INBOX_ALL_MESSAGES_FOR_A_THREAD_ROUTE = API_VERSION+ "/admin/requests/get_thread_messages.php";
  static const _HOMEWORK_ROUTE = API_VERSION+ "/admin/requests/get_homework.php";
  static const _HOMEWORK_ATTACHMENT_ROUTE = API_VERSION+ "/admin/requests/homework_attachments.php";
  static const _PUT_HOMEWORK_ROUTE = API_VERSION+ "/admin/requests/put_homework.php";
  static const _STUDENTS_BY_SECTION = API_VERSION+ "/admin/requests/get_students_by_section.php";
  static const _STUDENTS_STRENGTH_BY_SECTION = API_VERSION+ "/admin/requests/section_wise_strength.php";
  static const _SEARCH_STUDENTS = API_VERSION+ "/admin/requests/search_student.php";
  static const _STUDENTS_DETAILS = API_VERSION+ "/admin/requests/get_student_details.php";
  static const _STUDENTS_EXAM_DATA = API_VERSION+ "/admin/requests/student_exam_data.php";
  static const _EVENTS = API_VERSION+ "/student/requests/get_events.php";
  static const _PHOTO_GALELRY = API_VERSION+ "/student/requests/get_gallery_data.php";
  static const _NORMAL_NEWS = API_VERSION+ "/student/requests/get_normal_news.php";
  static const _VIDEO_GALLERY = API_VERSION+ "/student/requests/get_video_gallery_data.php";
  static const _VOICE_CALL = API_VERSION+ "/student/requests/get_voice_calls.php";
  static const _HOMEWORK_SUBJECTS= API_VERSION+ "/admin/requests/get_homework_subjects.php";
  static const _STAFF_DEPARTMENT_STATS= API_VERSION+ "/admin/requests/get_staff_stats.php";
  static const _STAFF_DEPARTMENTS= API_VERSION+ "/admin/requests/get_staff_depart.php";
  static const _STAFF_BY_DEPARTMENTS= API_VERSION+ "/admin/requests/get_staff_by_depart.php";
  static const _STAFF_PROFILE = API_VERSION+ "/teacher/requests/get_profile.php";
  static const _USERLIST_FOR_SUPER_USER= API_VERSION+ "/admin/requests/get_users_for_super_user.php";
  static const _LOGIN_AS_ROUTE = API_VERSION+ "/admin/requests/set_login_as.php";
  static const _ATTENDANCE_STUDENTS = API_VERSION+ "/teacher/requests/get_students_by_section.php";
  static const _INSERT_STU_ATTENDANCE = API_VERSION+ "/teacher/requests/insert_stu_att.php";
  static const _ABSENTEES = API_VERSION+ "/teacher/requests/get_absentees_by_section.php";
  static const _ATT_REPORTS= API_VERSION+ "/teacher/requests/get_att_report_by_section.php";
  static const _ATT_LEAVE_DETAILS= API_VERSION+ "/teacher/requests/get_att_leave_details.php";
  static const _ADD_STU_LEAVE= API_VERSION+ "/teacher/requests/add_stu_leave.php";
  static const _UPDATE_STU_ATT= API_VERSION+ "/teacher/requests/update_stu_leave.php";
  static const _STU_FOR_ATT_UPDATE= API_VERSION+ "/admin/requests/get_att_to_update.php";
  static const _GET_DASH_SLIDER_ROUTE = API_VERSION+ "/student/requests/get_dash_sliders.php";
  static const _FLYERS = API_VERSION+ "/student/requests/get_flyer.php";
  static const _GET_REF_ROUTE = API_VERSION+ "/admin/requests/get_refs.php";
  static const _SET_FIREBASE_ID_ROUTE = API_VERSION+ "/student/requests/set_firebase_id.php";
  static const _CURRENT_HOMEWORK_ROUTE = API_VERSION+ "/admin/requests/get_homework_current.php";
  static const _TEACHER_WISE_HOMEWORK_ROUTE = API_VERSION+ "/admin/requests/get_homework_teacher_wise.php";
  static const _ONE_TEACHER_HOMEWORK_ROUTE = API_VERSION+ "/admin/requests/get_homework_one_teacher.php";
  static const _STAFF_CURRENT_ATTENDANCE = API_VERSION+ "/admin/requests/get_staff_attendance_current.php";
  static const _STAFF_CURRENT_MONTH = API_VERSION+ "/admin/requests/get_staff_attendance_month.php";
  static const _STAFF_CURRENT_DATE = API_VERSION+ "/admin/requests/get_staff_attendance_date.php";
  static const _STAFF_CURRENT_ATTENDANCE_DETAILED = API_VERSION+ "/admin/requests/get_staff_attendance_current_detailed.php";
  static const _STAFF_MONTH_ATTENDANCE_DETAILED = API_VERSION+ "/admin/requests/get_staff_attendance_month_detailed.php";
  static const _STAFF_DATE_ATTENDANCE_DETAILED = API_VERSION+ "/admin/requests/get_staff_attendance_date_detailed.php";
  static const _STUDENT_CURRENT_ATTENDANCE = API_VERSION+ "/admin/requests/get_student_attendance_current.php";
  static const _STUDENT_CURRENT_ATTENDANCE_DETAILED = API_VERSION+ "/admin/requests/get_student_attendance_current_detailed.php";
  static const _STUDENT_ATTENDANCE_MONTH = API_VERSION+ "/admin/requests/get_student_attendance_month.php";
  static const _STUDENT_ATTENDANCE_MONTH_DETAILED = API_VERSION+ "/admin/requests/get_student_attendance_month_detailed.php";
  static const _STUDENT_ATTENDANCE_DATE = API_VERSION+ "/admin/requests/get_student_attendance_date.php";
  static const _STUDENT_ATTENDANCE_DATE_DETAILED = API_VERSION+ "/admin/requests/get_student_attendance_date_detailed.php";
  static const _TC = API_VERSION+ "/admin/requests/get_tcs.php";
  static const _ENQUIRIES = API_VERSION+ "/admin/requests/get_enquiries.php";
  static const _FORM_SALE = API_VERSION+ "/admin/requests/get_form_sales.php";
  static const _REGISTRATION = API_VERSION+ "/admin/requests/get_registrations.php";
  static const _FEE_DASH_DATA = API_VERSION+ "/admin/requests/get_fee_dash_data.php";
  static const _FEE_COLLECTON = API_VERSION+ "/admin/requests/get_todays_collection.php";
  static const _FEE_DUES = API_VERSION+ "/admin/requests/get_months_dues.php";
  static const _FLASH_NEWS = API_VERSION+ "/student/requests/get_flash_news.php";
  static const _NOTIFICATIONS = API_VERSION+ "/admin/requests/get_notifications.php";
  static const _NOTIFICATIONS_PREFERENCES = API_VERSION+ "/admin/requests/get_notification_opt_out_status.php";
  static const _CHANGE_NOTIFICATIONS_PREFERENCES = API_VERSION+ "/admin/requests/notifications_opt_out.php";
  static const _STU_LEAVE = API_VERSION+ "/admin/requests/get_stu_leaves.php";
  static const _STU_LEAVE_CHANGE_STATUS = API_VERSION+ "/admin/requests/change_stu_leave_status.php";
  static const _AUDIENCE = API_VERSION+ "/admin/requests/get_audience.php";
  static const _MESSAGE_SENDERS = API_VERSION+ "/admin/requests/get_message_senders.php";
  static const _SEND_MEDIA_MESSAGE = API_VERSION+ "/admin/requests/add_media_message.php";
  static const _GET_ANNOUNCEMENT = API_VERSION+ "/admin/requests/get_announcements.php";
  static const _GET_ANNOUNCEMENT_DETAILS = API_VERSION+ "/admin/requests/get_announcements_details.php";
  static const _SEND_HIGH_PRIORITY_SMS = API_VERSION+ "/admin/requests/send_sms_high_priority.php";
  static const _SEND_LOW_PRIORITY_SMS = API_VERSION+ "/admin/requests/send_sms_low_priority.php";
  static const _GET_SCHOOL_INFO_ROUTE = API_VERSION+ "/admin/requests/get_school_info1.php";
  static const _ZOOM_AUTH = API_VERSION+ "/teacher/requests/get_zoom_auth.php";
  static const _GET_ZOOM_CLASSES = API_VERSION+ "/admin/requests/get_zoom_classes_v2.php";
  static const _GET_SECTION_FOR_CLASS = API_VERSION+ "/teacher/requests/get_section_for_class.php";
  static const _GET_SUBJECT_FOR_CLASS = API_VERSION+ "/teacher/requests/get_subject_for_class.php";
  static const _VALIDATE_MEETING_TIME = API_VERSION+ "/teacher/requests/validate_meeting_time.php";
  static const _PUT_MEETING = API_VERSION+ "/teacher/requests/add_live_class_v3.php";
  static const _APP_UPDATE = _SCHOOL_INFO_ROOT+API_VERSION+"/requests/app_updates.php";
  static const _MESSAGES_ROUTE = API_VERSION+ "/student/requests/get_messages.php";
  static const _MESSAGES_ALL_ROUTE = API_VERSION+ "/student/requests/get_messages_all_v2.php";

  static const _DAY_WISE_FEE_REPORT = "api/get_day_wise_fee_collection";
  static const _DAY_WISE_FEE_FILTER = "api/get_day_wise_fee_collection_filter";
  static const _USER_WISE_FEE_FILTER = "api/get_fee_collection_filter";
  static const _USER_WISE_FEE_REPORT = "api/get_user_wise_fee_collection";
  static const _GET_STUDENT_LEDGER = "api/get_student_ledger";
  static const _SAVE_STUDENT_REMARK = "api/save_student_remark";
  static const _GET_STUDENT_REMARK = "api/get_student_remark";
  static const _GET_CONCESSION_REQUESTS = "api/get_concession_request";
  static const _GET_DISCOUNT_REQUESTS = "api/get_fee_discount_request";
  static const _CHANGE_DISCOUNT_STATUS = "api/change_discount_request_status";
  static const _CHANGE_CONCESSION_STATUS = "api/change_concession_request_status";
  static const _GET_CONCESSION_MODES = "api/get_concession_list_of_student";
  static const _GET_CANCELED_RECEIPTS = "api/get-cancelled-recipt-records";
  static const _SAVE_POLL = "admin/save_poll_question";
  static const _GET_POLL_QUESTIONS = "admin/get_poll_question";

  static const _GET_REMARK_TYPE = "api/get_remark_type";
  static const _CHANGE_REMARK_STATUS = "api/change_remark_status";
  static const _SHOW_STUDENT_REMARK = "api/get_student_remark";
  static const _SHOW_ADMIN_REMARK = "api/get_student_remark_for_admin";
  static const _GET_FEE_DATA = "api/fee_payment_history";
  static const _GET_DUES_DATA = "api/get_due_fee";
  static const _GET_ADMIN_FEE_DUES = "api/get_fee_due_for_admin";
  static const _GET_ADMIN_FEE_DUES_FILTER = "api/get_feedue_fillter";
  static const _ATTENDANCE = API_VERSION+ "/student/requests/get_attendance.php";
  static const _MSG_THREAD_ROUTE = API_VERSION+ "/student/requests/get_message_threads.php";
  static const _EXAM_TERMS = API_VERSION+ "/student/requests/exam_terms.php";
  static const _SCHOLASTIC_EXAMS = API_VERSION+ "/student/requests/exam_scholastic_exams.php";
  static const _GET_STUDENT_LEAVE = API_VERSION+ "/teacher/requests/get_stu_leaves.php";
  static const _ADD_NEWS = "admin/add_news";
  static const _ADD_SYLLABUS = "admin/add_syllabus";
  static const _GET_EXAM_REMARK = "admin/get_student_for_exam_remark";

  static schoolDataRoute() => _SCHOOL_INFO_ROOT + _SCHOOL_INFO_SCHOOL_DATE_ROUTE;

  static superUserRoute() => _SCHOOL_INFO_ROOT + _SUPER_USER_ROUTE;

  static superUserOtpVerifyRoute() => _SCHOOL_INFO_ROOT + _SUPER_USER_OTP_VERIFY;

  static getUserListForSuperUser(String rootUrl) => rootUrl + _USERLIST_FOR_SUPER_USER;

  static getLoginAsRoute(String rootUrl) => rootUrl + _LOGIN_AS_ROUTE;

  static loginRoute(String rootUrl) => rootUrl + _LOGIN_ROUTE;

  static otpVerifyRoute(String rootUrl) => rootUrl + _OTP_VERIFY_ROUTE;

  static loginReportRoute(String rootUrl) => rootUrl + _LOGIN_REPORT_ROUTE;

  static resendOtpRoute(String rootUrl) => rootUrl + _OTP_RESEND_ROUTE;

  static validateLoginRoute(String rootUrl) => rootUrl + _VALIDATE_LOGIN_ROUTE;

  static getProfileRoute(String rootUrl) => rootUrl + _GET_PROFILE;

  static getStudentProfileRoute(String rootUrl) => rootUrl + _GET_STUDENT_PROFILE;

  static getActiveModulesRoute(String rootUrl) => rootUrl + _GET_ACTIVE_MODULES;

  static getAddReferenceRoute(String rootUrl) => rootUrl + _ADD_REFERENCE_ROUTE;

  static getAllClassesRoute(String rootUrl) => rootUrl + _GET_CLASSES_ROUTE;

  static getAllClassesAndSectionRoute(String rootUrl) => rootUrl + _GET_CLASSES_AND_SECTION_ROUTE;

  static getSyllabusRoute(String rootUrl) => rootUrl + _GET_SYLLABUS_ROUTE;

  static getSessionsRoute(String rootUrl) => rootUrl + _GET_SESSIONS_ROUTE;

  static getStuMsgRoute(String rootUrl) => rootUrl + _STU_MSG_ROUTE;

  static getStaffMsgRoute(String rootUrl) => rootUrl + _STAFF_MSG_ROUTE;

  static getMessagesAttachmentRoute(String rootUrl) => rootUrl + _MESSAGES_ATTACHMENT_ROUTE;

  static getInboxMessageThreadsRoute(String rootUrl) => rootUrl + _INBOX_MESSAGES_ROUTE;

  static getAllMessagesOfAThreadRoute(String rootUrl) => rootUrl + _INBOX_ALL_MESSAGES_FOR_A_THREAD_ROUTE;

  static getHomeworkRoute(String rootUrl) => rootUrl + _HOMEWORK_ROUTE;

  static getHomeworkAttachmentRoute(String rootUrl) => rootUrl + _HOMEWORK_ATTACHMENT_ROUTE;

  static getPutHomeworkRoute(String rootUrl) => rootUrl + _PUT_HOMEWORK_ROUTE;

  static getStudentsBySectionRoute(String rootUrl) => rootUrl + _STUDENTS_BY_SECTION;

  static getStudentsStrengthBySectionRoute(String rootUrl) => rootUrl + _STUDENTS_STRENGTH_BY_SECTION;

  static getSearchStudentRoute(String rootUrl) => rootUrl + _SEARCH_STUDENTS;

  static getStudentDetailsRoute(String rootUrl) => rootUrl + _STUDENTS_DETAILS;

  static getStudentExamDateRoute(String rootUrl) => rootUrl + _STUDENTS_EXAM_DATA;

  static getEventsRoute(String rootUrl) => rootUrl  + _EVENTS;

  static getPhotoGalleryRoute(String rootUrl) => rootUrl  + _PHOTO_GALELRY;

  static getNormalNewsRoute(String rootUrl) => rootUrl  + _NORMAL_NEWS;

  static getVideoGalleryRoute(String rootUrl) => rootUrl + _VIDEO_GALLERY;

  static getVoiceCallsRoute(String rootUrl) => rootUrl + _VOICE_CALL;

  static getHomeworkSubjectsRoute(String rootUrl) => rootUrl + _HOMEWORK_SUBJECTS;

  static getStaffDepartmentStatsRoute(String rootUrl) => rootUrl + _STAFF_DEPARTMENT_STATS;

  static getStaffDepartmentRoute(String rootUrl) => rootUrl + _STAFF_DEPARTMENTS;

  static getStaffByDepartmentRoute(String rootUrl) => rootUrl + _STAFF_BY_DEPARTMENTS;

  static getStaffProfileRoute(String rootUrl) => rootUrl + _STAFF_PROFILE;

  static getAttendanceStudentRoute(String rootUrl) => rootUrl + _ATTENDANCE_STUDENTS;

  static getInsertAttendanceRoute(String rootUrl) => rootUrl + _INSERT_STU_ATTENDANCE;

  static getAbsenteesRoute(String rootUrl) => rootUrl + _ABSENTEES;

  static getAttReportsRoute(String rootUrl) => rootUrl + _ATT_REPORTS;

  static getAttLeaveDetailsRoute(String rootUrl) => rootUrl + _ATT_LEAVE_DETAILS;

  static getAddStuLeaveRoute(String rootUrl) => rootUrl + _ADD_STU_LEAVE;

  static getUpdateStuAttRoute(String rootUrl) => rootUrl + _UPDATE_STU_ATT;

  static getAttUpdateRoute(String rootUrl) => rootUrl + _STU_FOR_ATT_UPDATE;

  static getDashSliderRoute(String rootUrl) => rootUrl + _GET_DASH_SLIDER_ROUTE;

  static getFlyersRoute(String rootUrl) => rootUrl + _FLYERS;

  static getRefRoute(String rootUrl) => rootUrl + _GET_REF_ROUTE;

  static getSetFirebaseIdRoute(String rootUrl) => rootUrl + _SET_FIREBASE_ID_ROUTE;

  static getHomeworkCurrentRoute(String rootUrl) => rootUrl + _CURRENT_HOMEWORK_ROUTE;

  static getHomeworkTeacherWiseRoute(String rootUrl) => rootUrl + _TEACHER_WISE_HOMEWORK_ROUTE;

  static getHomeworkOneTeacherRoute(String rootUrl) => rootUrl + _ONE_TEACHER_HOMEWORK_ROUTE;

  static getStaffCurrentRoute(String rootUrl) => rootUrl + _STAFF_CURRENT_ATTENDANCE;

  static getStaffMonthAttendanceRoute(String rootUrl) => rootUrl + _STAFF_CURRENT_MONTH;

  static getStaffDateAttendanceRoute(String rootUrl) => rootUrl + _STAFF_CURRENT_DATE;

  static getStaffCurrentDetailedRoute(String rootUrl) => rootUrl + _STAFF_CURRENT_ATTENDANCE_DETAILED;

  static getStaffMonthDetailedRoute(String rootUrl) => rootUrl + _STAFF_MONTH_ATTENDANCE_DETAILED;

  static getStaffDateDetailedRoute(String rootUrl) => rootUrl + _STAFF_DATE_ATTENDANCE_DETAILED;

  static getStudentCurrentRoute(String rootUrl) => rootUrl + _STUDENT_CURRENT_ATTENDANCE;

  static getStudentCurrentDetailedRoute(String rootUrl) => rootUrl + _STUDENT_CURRENT_ATTENDANCE_DETAILED;

  static getStudentMonthRoute(String rootUrl) => rootUrl + _STUDENT_ATTENDANCE_MONTH;

  static getStudentMonthDetailedRoute(String rootUrl) => rootUrl + _STUDENT_ATTENDANCE_MONTH_DETAILED;

  static getStudentDateRoute(String rootUrl) => rootUrl + _STUDENT_ATTENDANCE_DATE;

  static getStudentDateDetailedRoute(String rootUrl) => rootUrl + _STUDENT_ATTENDANCE_DATE_DETAILED;


  static getTcsRoute(String rootUrl) => rootUrl + _TC;

  static getEnquiriesRoute(String rootUrl) => rootUrl + _ENQUIRIES;

  static getFormSaleRoute(String rootUrl) => rootUrl + _FORM_SALE;

  static getRegistrationRoute(String rootUrl) => rootUrl + _REGISTRATION;

  static getFeeDashDataRoute(String rootUrl) => rootUrl + _FEE_DASH_DATA;

  static getFeeCollectionRoute(String rootUrl) => rootUrl + _FEE_COLLECTON;

  static getDayWiseFeesRoute(String rootUrl) => rootUrl + _DAY_WISE_FEE_REPORT;

  static getDayWiseFeesFilterRoute(String rootUrl) => rootUrl + _DAY_WISE_FEE_FILTER;

  static getUserWiseFeesRoute(String rootUrl) => rootUrl + _USER_WISE_FEE_REPORT;

  static getUserWiseFeesFilterRoute(String rootUrl) => rootUrl + _USER_WISE_FEE_FILTER;

  static getStudentLedgerRoute(String rootUrl) => rootUrl + _GET_STUDENT_LEDGER;

  static getStudentRemarkRoute(String rootUrl) => rootUrl + _GET_STUDENT_REMARK;

  static getSaveStudentRemarkRoute(String rootUrl) => rootUrl + _SAVE_STUDENT_REMARK;

  static getConcessionRequestRoute(String rootUrl) => rootUrl + _GET_CONCESSION_REQUESTS;

  static getDiscountRequestRoute(String rootUrl) => rootUrl + _GET_DISCOUNT_REQUESTS;

  static getChangeDiscountStatusRoute(String rootUrl) => rootUrl + _CHANGE_DISCOUNT_STATUS;

  static getChangeConcessionStatusRoute(String rootUrl) => rootUrl + _CHANGE_CONCESSION_STATUS;

  static getConcessionModesRoute(String rootUrl) => rootUrl + _GET_CONCESSION_MODES;

  static getCancelledReceiptsRoute(String rootUrl) => rootUrl + _GET_CANCELED_RECEIPTS;

  static getFeeDuesRoute(String rootUrl) => rootUrl + _FEE_DUES;

  static getFlashNewsRoute(String rootUrl) => rootUrl +_FLASH_NEWS;

  static getNotificationsRoute(String rootUrl) => rootUrl + _NOTIFICATIONS;

  static getNotificationsPrefsRoute(String rootUrl) => rootUrl + _NOTIFICATIONS_PREFERENCES;

  static getChangeNotificationsPrefsRoute(String rootUrl) => rootUrl + _CHANGE_NOTIFICATIONS_PREFERENCES;

  static getStuLeaveRoute(String rootUrl) => rootUrl + _STU_LEAVE;

  static getStuLeaveChangeStatusRoute(String rootUrl) => rootUrl + _STU_LEAVE_CHANGE_STATUS;

  static getAudienceRoute(String rootUrl) => rootUrl + _AUDIENCE;

  static getMsgSendersRoute(String rootUrl) => rootUrl + _MESSAGE_SENDERS;

  static getSendMediaMsgRoute(String rootUrl) => rootUrl + _SEND_MEDIA_MESSAGE;

  static getAnnouncementRoute(String rootUrl) => rootUrl + _GET_ANNOUNCEMENT;

  static getAnnouncementDetailsRoute(String rootUrl) => rootUrl + _GET_ANNOUNCEMENT_DETAILS;

  static getHighPrioritySmsRoute(String rootUrl) => rootUrl + _SEND_HIGH_PRIORITY_SMS;

  static getLowPrioritySmsRoute(String rootUrl) => rootUrl + _SEND_LOW_PRIORITY_SMS;

  static getSchoolInfoRoute(String rootUrl) => rootUrl  + _GET_SCHOOL_INFO_ROUTE;

  static getZoomClassRoute(String rootUrl) => rootUrl  + _GET_ZOOM_CLASSES;

  static getZoomAuthRoute(String rootUrl) => rootUrl  + _ZOOM_AUTH;

  static getSectionForClassRoute(String rootUrl) => rootUrl  + _GET_SECTION_FOR_CLASS;

  static getSubjectForClassRoute(String rootUrl) => rootUrl  + _GET_SUBJECT_FOR_CLASS;

  static getValidateMeetingTimeRoute(String rootUrl) => rootUrl  + _VALIDATE_MEETING_TIME;

  static getPutMeetingRoute(String rootUrl) => rootUrl  + _PUT_MEETING;

  static getAppUpdateRoute() => _APP_UPDATE;

  static getChangeRemarkStatusRoute(String rootUrl) => rootUrl  + _CHANGE_REMARK_STATUS;

  static getRemarkTypeRoute(String rootUrl) => rootUrl  + _GET_REMARK_TYPE;

  static getAdminRemarksRoute(String rootUrl) => rootUrl  + _SHOW_ADMIN_REMARK;

  static getFeeDataRoute(String rootUrl) => rootUrl  + _GET_FEE_DATA;

  static getDuesDataRoute(String rootUrl) => rootUrl  + _GET_DUES_DATA;

  static getAdminFeeDuesFilterRoute(String rootUrl) => rootUrl  + _GET_ADMIN_FEE_DUES_FILTER;

  static getAdminFeeDuesRoute(String rootUrl) => rootUrl  + _GET_ADMIN_FEE_DUES;

  static getAttendanceRoute(String rootUrl) => rootUrl  + _ATTENDANCE;

  static getExamTermsRoute(String rootUrl) => rootUrl  + _EXAM_TERMS;

  static getScholasticExamsRoute(String rootUrl) => rootUrl  + _SCHOLASTIC_EXAMS;

  static getMessageThreadsRoute(String rootUrl) => rootUrl + _MSG_THREAD_ROUTE;

  static getMessagesRoute(String rootUrl) => rootUrl + _MESSAGES_ROUTE;

  static getMessagesAllRoute(String rootUrl) => rootUrl + _MESSAGES_ALL_ROUTE;

  static getSavePollQuestionRoute(String rootUrl) => rootUrl + _SAVE_POLL;

  static getPollQuestionsRoute(String rootUrl) => rootUrl + _GET_POLL_QUESTIONS;

  static getStudentLeaveRoute(String rootUrl) => rootUrl + _GET_STUDENT_LEAVE;

  static getAddNewsRoute(String rootUrl) => rootUrl + _ADD_NEWS;

  static getAddSyllabusRoute(String rootUrl) => rootUrl + _ADD_SYLLABUS;

  static getExamRemarkRoute(String rootUrl) => rootUrl + _GET_EXAM_REMARK;

}
