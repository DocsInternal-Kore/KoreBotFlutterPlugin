package kore.botssdk.activity;

import static android.view.View.VISIBLE;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowInsetsController;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.LayoutRes;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import java.io.Console;
import java.util.Objects;

import kore.botssdk.R;
import kore.botssdk.models.BotResponse;
import kore.botssdk.net.SDKConfig;
import kore.botssdk.utils.BundleConstants;
import kore.botssdk.utils.StringUtils;
import kore.botssdk.utils.ToastUtils;

@SuppressLint("UnknownNullness")
public class BotAppCompactActivity extends AppCompatActivity {

    protected final String LOG_TAG = getClass().getSimpleName();
    private ProgressDialog mProgressDialog;
    private FrameLayout contentContainer;
    private View statusBarLayout;
    private SharedPreferences sharedPreferences;

    public void finish() {
        super.finish();
    }

    protected void onCreate(Bundle data) {
        super.onCreate(data);
        setContentView(R.layout.activity_base);
        contentContainer = findViewById(R.id.content_container);
        statusBarLayout = findViewById(R.id.status_bar_bg);
        sharedPreferences = getSharedPreferences(BotResponse.THEME_NAME, Context.MODE_PRIVATE);
        configureEdgeToEdge();

//        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.base_frame), (view, windowInsets) -> {
//            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
//            view.setPadding(insets.left, 0, insets.right, insets.bottom);
//            if (sharedPreferences.getInt(BundleConstants.STATUS_BAR_HEIGHT, 0) == 0)
//                sharedPreferences.edit().putInt(BundleConstants.STATUS_BAR_HEIGHT, insets.top).apply();
//            view.setBackgroundColor(ContextCompat.getColor(view.getContext(), R.color.black));
//            return WindowInsetsCompat.CONSUMED;
//        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.base_frame), (view, windowInsets) -> {
            Insets ime = windowInsets.getInsets(WindowInsetsCompat.Type.ime());
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout());
            int bottom = ime.bottom;
            if (bottom == 0) bottom = insets.bottom;
            view.setPadding(insets.left, 0, insets.right, bottom);
            if (sharedPreferences.getInt(BundleConstants.STATUS_BAR_HEIGHT, 0) != insets.top)
                sharedPreferences.edit().putInt(BundleConstants.STATUS_BAR_HEIGHT, insets.top).apply();
            if (statusBarLayout != null) {
                statusBarLayout.setVisibility(VISIBLE);
                ViewGroup.LayoutParams params = statusBarLayout.getLayoutParams();
                params.height = insets.top;
                statusBarLayout.setLayoutParams(params);
                statusBarLayout.setBackgroundColor(resolveStatusBarColor(""));
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                Objects.requireNonNull(getWindow().getInsetsController()).setSystemBarsAppearance(
                        WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS,
                        WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS
                );
            }
            return WindowInsetsCompat.CONSUMED;
        });
    }

    private void configureEdgeToEdge() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) return;

        Window window = getWindow();
        WindowCompat.setDecorFitsSystemWindows(window, false);
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.setStatusBarColor(Color.TRANSPARENT);
        window.setNavigationBarColor(Color.TRANSPARENT);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.setStatusBarContrastEnforced(false);
            window.setNavigationBarContrastEnforced(false);
        }

        updateSystemBarAppearance("");
    }


    // Method for child activities to set their layout inside the base layout
    protected void setContentLayout(@LayoutRes int layoutResId) {
        LayoutInflater.from(this).inflate(layoutResId, contentContainer, true);
    }

    protected void changeStatusBarColor(String color) {
        int statusBarColor = resolveStatusBarColor(color);
        statusBarLayout.setVisibility(VISIBLE);
        ViewGroup.LayoutParams params = statusBarLayout.getLayoutParams();
        params.height = sharedPreferences.getInt(BundleConstants.STATUS_BAR_HEIGHT, 0);
        statusBarLayout.setLayoutParams(params);
        statusBarLayout.setBackgroundColor(statusBarColor);
        updateSystemBarAppearance(color);

        if (Build.VERSION.SDK_INT >= 35) {
            return;
        } else {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(statusBarColor);
        }
    }

    private int resolveStatusBarColor(String color) {
        if (StringUtils.isNullOrEmpty(color)) {
            String storedColor = sharedPreferences.getString(BundleConstants.STATUS_BAR_COLOR, "");
            if (!StringUtils.isNullOrEmpty(storedColor)) return Color.parseColor(storedColor);
            return ContextCompat.getColor(BotAppCompactActivity.this, R.color.colorPrimary);
        }

        return Color.parseColor(color);
    }

    private void updateSystemBarAppearance(String statusBarColor) {
        WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        controller.setAppearanceLightStatusBars(isLightColor(StringUtils.isNullOrEmpty(statusBarColor) ? "#000000" : statusBarColor));
        controller.setAppearanceLightNavigationBars(true);
    }

    private boolean isLightColor(String color) {
        try {
            int parsedColor = Color.parseColor(color);
            double luminance = (0.299 * Color.red(parsedColor) + 0.587 * Color.green(parsedColor) + 0.114 * Color.blue(parsedColor)) / 255;
            return luminance > 0.5;
        } catch (IllegalArgumentException ignored) {
            return false;
        }
    }

    protected void changeStatusBarColorWithHeight() {
        if (Build.VERSION.SDK_INT >= 35) {
            ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.base_frame), (view, windowInsets) -> {
                Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                view.setPadding(insets.left, insets.top, insets.right, insets.bottom);
                view.setBackgroundColor(ContextCompat.getColor(view.getContext(), R.color.black));
                return WindowInsetsCompat.CONSUMED;
            });
        }
        else {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(ContextCompat.getColor(BotAppCompactActivity.this, R.color.black));
        }
    }

    // Optional: get container reference
    protected FrameLayout getContentContainer() {
        return contentContainer;
    }

    protected void showProgress(String msg, boolean isCancelable) {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            return;
        }

        mProgressDialog = ProgressDialog.show(this, getResources().getString(R.string.app_name), msg);
        mProgressDialog.setCancelable(isCancelable);
        mProgressDialog.setContentView(R.layout.progress_indicator);
        ((TextView) mProgressDialog.findViewById(R.id.loadingText)).setText(TextUtils.isEmpty(msg) ? "please wait" : msg);
        mProgressDialog.show();
    }

    protected void dismissProgress() {
        if (mProgressDialog == null || !mProgressDialog.isShowing()) {
            return;
        }
        mProgressDialog.dismiss();
        mProgressDialog = null;
    }

    protected final void showToast(String message) {
        if (message != null && !message.equals("INVALID_ACCESS_TOKEN"))
            ToastUtils.showToast(this, message);
    }

    protected final void showToast(String msg, int length) {
        ToastUtils.showToast(this, msg, length);
    }

}
