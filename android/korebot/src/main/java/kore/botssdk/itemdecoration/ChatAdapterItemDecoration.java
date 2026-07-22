package kore.botssdk.itemdecoration;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import kore.botssdk.adapter.ChatAdapter;

public class ChatAdapterItemDecoration extends RecyclerView.ItemDecoration {

    private static final int FIRST_ITEM_MARGIN_TOP_DP = 12;
    private static final int COMMON_VERTICAL_MARGIN_DP = 6;
    private static final int MESSAGE_MARGIN_DP = 30;
    private static final int EDGE_MARGIN_DP = 4;

    public ChatAdapterItemDecoration() {
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);
        int position = parent.getChildAdapterPosition(view);
        ChatAdapter adapter = (ChatAdapter) parent.getAdapter();
        if (adapter == null) return;
        if (position < 0 || adapter.getItemCount() <= position) return;

        int commonVerticalMargin = toPixels(parent.getContext(), COMMON_VERTICAL_MARGIN_DP);
        int messageMargin = toPixels(parent.getContext(), MESSAGE_MARGIN_DP);
        int edgeMargin = toPixels(parent.getContext(), EDGE_MARGIN_DP);
        outRect.top = position == 0
                ? toPixels(parent.getContext(), FIRST_ITEM_MARGIN_TOP_DP)
                : commonVerticalMargin;
        outRect.bottom = commonVerticalMargin;

        boolean isRequest = adapter.getItemType(position) == ChatAdapter.TEMPLATE_BUBBLE_REQUEST;
        boolean isRtl = adapter.isItemRtl(position);
        // Requests use END and responses use START, so their physical edge changes in RTL.
        boolean bubbleAtLeftEdge = isRequest == isRtl;
        if (bubbleAtLeftEdge) {
            outRect.left = edgeMargin;
            outRect.right = messageMargin;
        } else {
            outRect.left = messageMargin;
            outRect.right = edgeMargin;
        }
    }

    public static int getMessageMargin(Context context) {
        return toPixels(context, MESSAGE_MARGIN_DP);
    }

    public static int getCommonVerticalMargin(Context context) {
        return toPixels(context, COMMON_VERTICAL_MARGIN_DP);
    }

    private static int toPixels(Context context, int dp) {
        return Math.round(dp * context.getResources().getDisplayMetrics().density);
    }
}
