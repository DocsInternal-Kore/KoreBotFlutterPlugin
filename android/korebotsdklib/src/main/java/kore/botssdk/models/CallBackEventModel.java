package kore.botssdk.models;

public class CallBackEventModel {
    private String eventCode;
    private String eventMessage;

    public CallBackEventModel(String eventCode, String eventName)
    {
        this.eventCode = eventCode;
        this.eventMessage = eventName;
    }

    public String getEventMessage() {
        return eventMessage;
    }

    public String getEventCode() {
        return eventCode;
    }

    public void setEventMessage(String eventName) {
        this.eventMessage = eventName;
    }

    public void setEventCode(String eventCode) {
        this.eventCode = eventCode;
    }
}
