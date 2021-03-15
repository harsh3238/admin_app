package com.stucare.click_campus_admin.zoom;

public interface AuthConstants {

	// TODO Change it to your web domain
	public final static String WEB_DOMAIN = "zoom.us";

	// TODO Change it to your APP Key
	public final static String SDK_KEY = "ZUOZtj3ccSiekn7I740OBMBb0HHKtmekLXHP";

	// TODO Change it to your APP Secret
	public final static String SDK_SECRET = "J56ijjLy4LhjOZhhOJm0B7q89SjVcKGXS7TZ";

	/**
	 * We recommend that, you can generate jwttoken on your own server instead of hardcore in the code.
	 * We hardcore it here, just to run the demo.
	 *
	 * You can generate a jwttoken on the https://jwt.io/
	 * with this payload:
	 * {
	 *     "appKey": "string", // app key
	 *     "iat": long, // access token issue timestamp
	 *     "exp": long, // access token expire time
	 *     "tokenExp": long // token expire time
	 * }
	 */
	public final static String SDK_JWTTOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBLZXkiOiJzWlVPWnRqM2NjU2lla243STc0ME9CTUJiMEhIS3RtZWtMWEhQIiwiaWF0IjoxNTg3NzExNzU1LCJleHAiOjE1ODc3MTM3NTUsInRva2VuRXhwIjoxODAwfQ.BIPX0il0UEsaJh0jksNnQW9WCRDE8Q2qSo7pIBUjyiQ";

}
