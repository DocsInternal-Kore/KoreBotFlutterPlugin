package kore.botssdk.net;

import java.util.HashMap;

import kore.botssdk.models.JWTTokenResponse;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Headers;
import retrofit2.http.POST;
import retrofit2.http.Url;

/**
 * Created by Ramachandra Pradeep on 15-Mar-17.
 */
public interface BotJWTRestAPI {
    @Headers({
            "alg:RS256",
            "typ:JWT"
    })
    @POST
    Call<JWTTokenResponse> getJWTToken(@Url String url, @Body HashMap<String, Object> jsonObject);
}
